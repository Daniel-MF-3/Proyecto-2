`timescale 1ns/1ps

module tb_debounce;

    logic clk;
    logic rst;
    logic valido;
    logic [3:0] tecla;
    logic limpio;
    logic [3:0] seleccion;

    // N pequeño para que la simulación sea rápida.
    debounce #(.N(4)) dut (
        .clk(clk),
        .rst(rst),
        .valido(valido),
        .tecla(tecla),
        .limpio(limpio),
        .seleccion(seleccion)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic rebote_presion(input [3:0] t);
        begin
            tecla = t; valido = 1'b1; repeat (2) @(posedge clk);
            valido = 1'b0; repeat (1) @(posedge clk);
            valido = 1'b1; repeat (1) @(posedge clk);
            tecla = 4'h0; repeat (1) @(posedge clk);
            tecla = t; valido = 1'b1;
        end
    endtask

    task automatic esperar_pulso(input [3:0] esperado);
        integer k;
        logic visto;
        begin
            visto = 1'b0;
            for (k = 0; k < 40; k = k + 1) begin
                @(posedge clk);
                if (limpio) begin
                    visto = 1'b1;
                    $display("pulso limpio tecla=%h", seleccion);
                    if (seleccion !== esperado)
                        $error("ERROR seleccion esperada=%h obtenida=%h", esperado, seleccion);
                end
            end
            if (!visto)
                $error("ERROR no apareció pulso limpio para tecla=%h", esperado);
        end
    endtask

    task automatic soltar_y_rearmar;
        begin
            valido = 1'b0;
            tecla = 4'h0;
            repeat (30) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_debounce.vcd");
        $dumpvars(0, tb_debounce);

        rst = 1'b1;
        valido = 1'b0;
        tecla = 4'h0;
        repeat (3) @(posedge clk);
        rst = 1'b0;

        rebote_presion(4'h9);
        esperar_pulso(4'h9);

        // Mantener presionado no debe generar más pulsos.
        repeat (30) @(posedge clk);
        if (limpio) $error("ERROR generó más de un pulso sin soltar");

        soltar_y_rearmar();

        rebote_presion(4'hA);
        esperar_pulso(4'hA);

        $display("FIN tb_debounce");
        $finish;
    end

endmodule
