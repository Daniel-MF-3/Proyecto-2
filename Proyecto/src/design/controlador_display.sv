module controlador_display_total (
    input  logic clk,
    input  logic reset,
    input  logic [3:0] val1,     // Display derecho
    input  logic [3:0] val2,
    input  logic [3:0] val3,
    input  logic [3:0] val4,     // Display izquierdo
    output logic [3:0] anodos,   // NPN/base activa en 1. Se conserva el nombre externo.
    output logic [6:0] siete_seg // Cátodo común: segmento activo en 1
);

    logic [15:0] clk_div;
    logic [1:0]  sel;
    logic [3:0]  num_actual;
    logic [6:0]  seg_temp;

    // Refresco aproximado: 27 MHz / 27000 = 1 kHz por avance de dígito.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div <= 16'd0;
            sel     <= 2'd0;
        end else begin
            if (clk_div == 16'd26999) begin
                clk_div <= 16'd0;
                sel     <= sel + 2'd1;
            end else begin
                clk_div <= clk_div + 16'd1;
            end
        end
    end

    // Multiplexado. Durante unos ciclos se apagan los NPN para reducir fantasma.
    always @(*) begin
        if (clk_div < 500) begin
            anodos     = 4'b0000;  // todos los NPN apagados
            num_actual = 4'hF;     // segmentos apagados
        end else begin
            case(sel)
            2'b00: begin anodos = 4'b1000; num_actual = val1; end // derecha
            2'b01: begin anodos = 4'b0100; num_actual = val2; end // centro-derecha
            2'b10: begin anodos = 4'b0010; num_actual = val3; end // centro-izquierda
            2'b11: begin anodos = 4'b0001; num_actual = val4; end // izquierda
            default: begin anodos = 4'b0000; num_actual = 4'hF; end
        endcase
        end
    end

    // Orden asumido: siete_seg[6:0] = {g,f,e,d,c,b,a}
    // Cátodo común: 1 enciende el segmento.
    always_comb begin
        case (num_actual)
            4'h0: seg_temp = 7'b0111111;
            4'h1: seg_temp = 7'b0000110;
            4'h2: seg_temp = 7'b1011011;
            4'h3: seg_temp = 7'b1001111;
            4'h4: seg_temp = 7'b1100110;
            4'h5: seg_temp = 7'b1101101;
            4'h6: seg_temp = 7'b1111101;
            4'h7: seg_temp = 7'b0000111;
            4'h8: seg_temp = 7'b1111111;
            4'h9: seg_temp = 7'b1101111;
            4'hA: seg_temp = 7'b1110111;
            4'hB: seg_temp = 7'b1111100;
            4'hC: seg_temp = 7'b0111001;
            4'hD: seg_temp = 7'b1011110;
            4'hE: seg_temp = 7'b1111001;
            4'hF: seg_temp = 7'b0000000; // blanco
            default: seg_temp = 7'b0000000;
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            siete_seg <= 7'b0000000;
        else
            siete_seg <= seg_temp;
    end

endmodule