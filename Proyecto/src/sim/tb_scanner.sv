`timescale 1ns/1ps

module tb_scanner;

    logic clk;
    logic reset;
    logic stop_scanning;
    logic [3:0] filas;
    logic [3:0] columnas;
    logic tecla_detectada;
    logic [3:0] pos_tecla;

    scanner dut (
        .clk(clk),
        .reset(reset),
        .stop_scanning(stop_scanning),
        .filas(filas),
        .columnas(columnas),
        .tecla_detectada(tecla_detectada),
        .pos_tecla(pos_tecla)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic esperar_columna(input [3:0] col);
        begin
            wait (columnas == col);
            repeat (2) @(posedge clk);
        end
    endtask

    task automatic probar_tecla(input [3:0] col, input [3:0] fila, input [3:0] esperado);
        begin
            filas = 4'b1111;
            stop_scanning = 1'b0;
            esperar_columna(col);
            filas = fila;
            #1;
            $display("col=%b fila=%b -> detectada=%b tecla=%h", columnas, filas, tecla_detectada, pos_tecla);
            if (!tecla_detectada) $error("ERROR no detectó tecla esperada=%h", esperado);
            if (pos_tecla !== esperado) $error("ERROR tecla esperada=%h obtenida=%h", esperado, pos_tecla);
            filas = 4'b1111;
            repeat (3) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_scanner.vcd");
        $dumpvars(0, tb_scanner);

        reset = 1'b1;
        stop_scanning = 1'b0;
        filas = 4'b1111;
        repeat (3) @(posedge clk);
        reset = 1'b0;

        // Primera columna: 1, 4, 7, *
        probar_tecla(4'b1110, 4'b1110, 4'h1);
        probar_tecla(4'b1110, 4'b1101, 4'h4);
        probar_tecla(4'b1110, 4'b1011, 4'h7);
        probar_tecla(4'b1110, 4'b0111, 4'hE);

        // Segunda columna: 2, 5, 8, 0
        probar_tecla(4'b1101, 4'b1110, 4'h2);
        probar_tecla(4'b1101, 4'b1101, 4'h5);
        probar_tecla(4'b1101, 4'b1011, 4'h8);
        probar_tecla(4'b1101, 4'b0111, 4'h0);

        // Tercera columna: 3, 6, 9, #
        probar_tecla(4'b1011, 4'b1110, 4'h3);
        probar_tecla(4'b1011, 4'b1101, 4'h6);
        probar_tecla(4'b1011, 4'b1011, 4'h9);
        probar_tecla(4'b1011, 4'b0111, 4'hF);

        // Cuarta columna: A, B, C, D
        probar_tecla(4'b0111, 4'b1110, 4'hA);
        probar_tecla(4'b0111, 4'b1101, 4'hB);
        probar_tecla(4'b0111, 4'b1011, 4'hC);
        probar_tecla(4'b0111, 4'b0111, 4'hD);

        filas = 4'b1111;
        #1;
        if (tecla_detectada !== 1'b0) $error("ERROR detecta tecla cuando filas=1111");

        $display("FIN tb_scanner");
        $finish;
    end

endmodule
