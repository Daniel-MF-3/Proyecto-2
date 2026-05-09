`timescale 1ns/1ps

module tb_FSM_datos;

    logic clk;
    logic reset;
    logic pulse_tecla;
    logic [3:0] pos_tecla;
    logic [13:0] n1_bin, n2_bin, suma;
    logic [3:0] estado_vis;
    logic [3:0] c1_o, d1_o, u1_o;
    logic [3:0] c2_o, d2_o, u2_o;

    FSM_control dut (
        .clk(clk),
        .reset(reset),
        .pulse_tecla(pulse_tecla),
        .pos_tecla(pos_tecla),
        .n1_bin(n1_bin),
        .n2_bin(n2_bin),
        .suma(suma),
        .estado_vis(estado_vis),
        .c1_o(c1_o), .d1_o(d1_o), .u1_o(u1_o),
        .c2_o(c2_o), .d2_o(d2_o), .u2_o(u2_o)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic press(input [3:0] key);
        begin
            @(negedge clk);
            pos_tecla = key;
            pulse_tecla = 1'b1;
            @(negedge clk);
            pulse_tecla = 1'b0;
            pos_tecla = 4'h0;
            repeat (2) @(posedge clk);
        end
    endtask

    task automatic revisar(
        input [13:0] exp_n1,
        input [13:0] exp_n2,
        input [13:0] exp_suma,
        input [3:0] exp_estado
    );
        begin
            #1;
            $display("estado=%0d n1=%0d n2=%0d suma=%0d | n1dig=%0d%0d%0d n2dig=%0d%0d%0d",
                     estado_vis, n1_bin, n2_bin, suma, c1_o, d1_o, u1_o, c2_o, d2_o, u2_o);
            if (n1_bin !== exp_n1)     $error("ERROR n1 esperado=%0d obtenido=%0d", exp_n1, n1_bin);
            if (n2_bin !== exp_n2)     $error("ERROR n2 esperado=%0d obtenido=%0d", exp_n2, n2_bin);
            if (suma   !== exp_suma)   $error("ERROR suma esperada=%0d obtenida=%0d", exp_suma, suma);
            if (estado_vis !== exp_estado) $error("ERROR estado esperado=%0d obtenido=%0d", exp_estado, estado_vis);
        end
    endtask

    initial begin
        $dumpfile("tb_FSM_datos.vcd");
        $dumpvars(0, tb_FSM_datos);

        reset = 1'b1;
        pulse_tecla = 1'b0;
        pos_tecla = 4'h0;
        repeat (3) @(posedge clk);
        reset = 1'b0;
        repeat (2) @(posedge clk);

        // Caso principal: 123 + 456 = 579
        press(4'h1);
        press(4'h2);
        press(4'h3);
        revisar(14'd123, 14'd0, 14'd123, 4'd3);

        // Dígito extra debe ignorarse antes de Enter.
        press(4'h9);
        revisar(14'd123, 14'd0, 14'd123, 4'd3);

        press(4'hA); // Enter para pasar a número 2.
        revisar(14'd123, 14'd0, 14'd123, 4'd4);

        press(4'h4);
        press(4'h5);
        press(4'h6);
        revisar(14'd123, 14'd456, 14'd579, 4'd7);

        press(4'hA); // Enter para resultado.
        revisar(14'd123, 14'd456, 14'd579, 4'd8);

        // En resultado se queda allí.
        press(4'h1);
        revisar(14'd123, 14'd456, 14'd579, 4'd8);

        $display("FIN tb_FSM_datos");
        $finish;
    end

endmodule
