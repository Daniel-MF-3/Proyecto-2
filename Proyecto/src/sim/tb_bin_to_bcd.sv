`timescale 1ns/1ps

module tb_bin_to_bcd;

    logic clk;
    logic reset;
    logic [10:0] binario;
    logic [3:0] millar, centena, decena, unidad;

    bin_to_bcd dut (
        .clk(clk),
        .reset(reset),
        .binario(binario),
        .millar(millar),
        .centena(centena),
        .decena(decena),
        .unidad(unidad)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic esperar_conversion;
        begin
            // El peor caso 1998 tarda varios ciclos por restas sucesivas.
            repeat (130) @(posedge clk);
        end
    endtask

    task automatic probar(
        input [10:0] valor,
        input [3:0] exp_m,
        input [3:0] exp_c,
        input [3:0] exp_d,
        input [3:0] exp_u
    );
        begin
            binario = valor;
            esperar_conversion();
            $display("bin=%0d -> %0d%0d%0d%0d", valor, millar, centena, decena, unidad);

            if ({millar, centena, decena, unidad} !== {exp_m, exp_c, exp_d, exp_u}) begin
                $error("ERROR bin=%0d esperado %0d%0d%0d%0d obtenido %0d%0d%0d%0d",
                       valor, exp_m, exp_c, exp_d, exp_u, millar, centena, decena, unidad);
            end
        end
    endtask

    initial begin
        $dumpfile("tb_bin_to_bcd.vcd");
        $dumpvars(0, tb_bin_to_bcd);

        reset = 1'b1;
        binario = 11'd0;
        repeat (3) @(posedge clk);
        reset = 1'b0;
        repeat (2) @(posedge clk);

        probar(11'd1,    4'd0, 4'd0, 4'd0, 4'd1);
        probar(11'd9,    4'd0, 4'd0, 4'd0, 4'd9);
        probar(11'd10,   4'd0, 4'd0, 4'd1, 4'd0);
        probar(11'd99,   4'd0, 4'd0, 4'd9, 4'd9);
        probar(11'd100,  4'd0, 4'd1, 4'd0, 4'd0);
        probar(11'd999,  4'd0, 4'd9, 4'd9, 4'd9);
        probar(11'd1000, 4'd1, 4'd0, 4'd0, 4'd0);
        probar(11'd1998, 4'd1, 4'd9, 4'd9, 4'd8);

        $display("FIN tb_bin_to_bcd");
        $finish;
    end

endmodule
