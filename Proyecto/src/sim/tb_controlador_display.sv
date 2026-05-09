`timescale 1ns/1ps

module tb_controlador_display;

    logic clk;
    logic reset;
    logic [3:0] val1, val2, val3, val4;
    logic [3:0] anodos;
    logic [6:0] siete_seg;

    controlador_display_total dut (
        .clk(clk),
        .reset(reset),
        .val1(val1),
        .val2(val2),
        .val3(val3),
        .val4(val4),
        .anodos(anodos),
        .siete_seg(siete_seg)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    function automatic [6:0] seg_esperado(input [3:0] n);
        begin
            case (n)
                4'h0: seg_esperado = 7'b0111111;
                4'h1: seg_esperado = 7'b0000110;
                4'h2: seg_esperado = 7'b1011011;
                4'h3: seg_esperado = 7'b1001111;
                4'h4: seg_esperado = 7'b1100110;
                4'h5: seg_esperado = 7'b1101101;
                4'h6: seg_esperado = 7'b1111101;
                4'h7: seg_esperado = 7'b0000111;
                4'h8: seg_esperado = 7'b1111111;
                4'h9: seg_esperado = 7'b1101111;
                4'hA: seg_esperado = 7'b1110111;
                4'hB: seg_esperado = 7'b1111100;
                4'hC: seg_esperado = 7'b0111001;
                4'hD: seg_esperado = 7'b1011110;
                4'hE: seg_esperado = 7'b1111001;
                default: seg_esperado = 7'b0000000;
            endcase
        end
    endfunction

    task automatic revisar_digito(input [3:0] anodo_exp, input [3:0] valor_exp);
        begin
            // Espera a salir de la ventana de apagado fantasma.
            wait (anodos == anodo_exp);
            repeat (2) @(posedge clk);
            $display("anodos=%b siete_seg=%b", anodos, siete_seg);
            if (siete_seg !== seg_esperado(valor_exp)) begin
                $error("ERROR display anodo=%b valor=%h seg esperado=%b obtenido=%b",
                       anodo_exp, valor_exp, seg_esperado(valor_exp), siete_seg);
            end
        end
    endtask

    initial begin
        $dumpfile("tb_controlador_display.vcd");
        $dumpvars(0, tb_controlador_display);

        reset = 1'b1;
        val1 = 4'h1;
        val2 = 4'h2;
        val3 = 4'h3;
        val4 = 4'h4;
        repeat (3) @(posedge clk);
        reset = 1'b0;

        revisar_digito(4'b1000, 4'h1);
        revisar_digito(4'b0100, 4'h2);
        revisar_digito(4'b0010, 4'h3);
        revisar_digito(4'b0001, 4'h4);

        $display("FIN tb_controlador_display");
        $finish;
    end

endmodule
