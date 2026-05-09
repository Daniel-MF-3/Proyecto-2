`timescale 1ns/1ps

module tb_top;

    logic clk;
    logic reset;          // En top, reset externo es activo en 0.
    logic [3:0] filas;
    logic [3:0] columnas;
    logic [3:0] anodos;
    logic [6:0] siete_seg;
    logic led_externo_contacto;
    logic led_externo_pulso;
    logic led_externo_bit0;

    top dut (
        .clk(clk),
        .reset(reset),
        .filas(filas),
        .columnas(columnas),
        .anodos(anodos),
        .siete_seg(siete_seg),
        .led_externo_contacto(led_externo_contacto),
        .led_externo_pulso(led_externo_pulso),
        .led_externo_bit0(led_externo_bit0)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Inyección directa al punto donde top ya recibiría una tecla limpia.
    // Esto evita esperar el debounce N=21 y separa la prueba de integración de la prueba física del scanner.
    task automatic inyectar_tecla(input [3:0] key);
        begin
            @(negedge clk);
            force dut.tecla_ok = key;
            force dut.pulse_ok = 1'b1;
            @(negedge clk);
            force dut.pulse_ok = 1'b0;
            @(negedge clk);
            release dut.pulse_ok;
            release dut.tecla_ok;
            repeat (3) @(posedge clk);
        end
    endtask

    task automatic revisar_top(
        input [13:0] exp_n1,
        input [13:0] exp_n2,
        input [13:0] exp_suma,
        input [3:0] exp_estado
    );
        begin
            #1;
            $display("estado=%0d n1=%0d n2=%0d suma=%0d visibles=%h%h%h%h",
                     dut.s_est, dut.n1_bin, dut.n2_bin, dut.suma_res, dut.v4, dut.v3, dut.v2, dut.v1);
            if (dut.n1_bin !== exp_n1)      $error("ERROR top n1 esperado=%0d obtenido=%0d", exp_n1, dut.n1_bin);
            if (dut.n2_bin !== exp_n2)      $error("ERROR top n2 esperado=%0d obtenido=%0d", exp_n2, dut.n2_bin);
            if (dut.suma_res !== exp_suma)  $error("ERROR top suma esperada=%0d obtenida=%0d", exp_suma, dut.suma_res);
            if (dut.s_est !== exp_estado)   $error("ERROR top estado esperado=%0d obtenido=%0d", exp_estado, dut.s_est);
        end
    endtask

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        filas = 4'b1111;
        reset = 1'b0; // reset activo
        repeat (5) @(posedge clk);
        reset = 1'b1; // libera reset
        repeat (5) @(posedge clk);

        // 999 + 999 = 1998
        inyectar_tecla(4'h9);
        inyectar_tecla(4'h9);
        inyectar_tecla(4'h9);
        revisar_top(14'd999, 14'd0, 14'd999, 4'd3);

        inyectar_tecla(4'hA);
        revisar_top(14'd999, 14'd0, 14'd999, 4'd4);

        inyectar_tecla(4'h9);
        inyectar_tecla(4'h9);
        inyectar_tecla(4'h9);
        revisar_top(14'd999, 14'd999, 14'd1998, 4'd7);

        inyectar_tecla(4'hA);
        revisar_top(14'd999, 14'd999, 14'd1998, 4'd8);

        // Espera a que bin_to_bcd convierta 1998 y top prepare los valores visibles.
        repeat (150) @(posedge clk);
        $display("Resultado BCD visible esperado 1998, obtenido %h%h%h%h", dut.v4, dut.v3, dut.v2, dut.v1);
        if ({dut.v4, dut.v3, dut.v2, dut.v1} !== {4'd1,4'd9,4'd9,4'd8}) begin
            $error("ERROR top resultado visible no es 1998");
        end

        $display("FIN tb_top");
        $finish;
    end

endmodule
