module scanner (
    input logic clk,               
    input logic reset,             // AHORA ES ACTIVE HIGH (Se lleva bien con top.sv)
    input logic stop_scanning,     
    input logic [3:0] filas,       
    output logic [3:0] columnas,   
    output logic tecla_detectada,  
    output logic [3:0] pos_tecla   
);

    logic [14:0] div_clk;
    logic [1:0] cuenta_col;

    // Barrido de columnas con Reset Positivo
    always @(posedge clk or posedge reset) begin // CORREGIDO A POSEDGE
        if (reset) begin                         // CORREGIDO A (reset)
            div_clk <= 0;
            cuenta_col <= 2'b00;
        end else if (!stop_scanning) begin
            if (div_clk == 17999) begin 
                div_clk <= 0;
                cuenta_col <= cuenta_col + 1'b1;
            end else begin
                div_clk <= div_clk + 1'b1;
            end
        end
    end

    // Activación física de Columnas
    always @(*) begin
        case (cuenta_col)
            2'b00: columnas = 4'b1110; 
            2'b01: columnas = 4'b1101; 
            2'b10: columnas = 4'b1011; 
            2'b11: columnas = 4'b0111; 
            default: columnas = 4'b1111;
        endcase
    end

    // Mapeo lógico de teclas
    always @(*) begin
        if (filas != 4'b1111) begin
            tecla_detectada = 1'b1;
            case ({columnas, filas})
                8'b1110_1110: pos_tecla = 4'h1; 
                8'b1110_1101: pos_tecla = 4'h4; 
                8'b1110_1011: pos_tecla = 4'h7; 
                8'b1110_0111: pos_tecla = 4'hE; // *
                8'b1101_1110: pos_tecla = 4'h2; 
                8'b1101_1101: pos_tecla = 4'h5; 
                8'b1101_1011: pos_tecla = 4'h8; 
                8'b1101_0111: pos_tecla = 4'h0; 
                8'b1011_1110: pos_tecla = 4'h3; 
                8'b1011_1101: pos_tecla = 4'h6; 
                8'b1011_1011: pos_tecla = 4'h9; 
                8'b1011_0111: pos_tecla = 4'hF; // #
                8'b0111_1110: pos_tecla = 4'hA; // A
                8'b0111_1101: pos_tecla = 4'hB; // B
                8'b0111_1011: pos_tecla = 4'hC; // C
                8'b0111_0111: pos_tecla = 4'hD; // D
                default: pos_tecla = 4'h0;
            endcase 
        end else begin
            tecla_detectada = 1'b0;
            pos_tecla = 4'h0;
        end
    end
endmodule