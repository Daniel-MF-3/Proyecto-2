module FSM_control (
    input  logic clk,
    input  logic reset,
    input  logic pulse_tecla,
    input  logic [3:0] pos_tecla,

    output logic [13:0] n1_bin,
    output logic [13:0] n2_bin,
    output logic [13:0] suma,
    output logic [3:0] estado_vis,

    output logic [3:0] c1_o, d1_o, u1_o,
    output logic [3:0] c2_o, d2_o, u2_o
);

    typedef enum logic [3:0] {
        S_N1_D1      = 4'd0,
        S_N1_D2      = 4'd1,
        S_N1_D3      = 4'd2,
        S_N1_ENTER   = 4'd3,
        S_N2_D1      = 4'd4,
        S_N2_D2      = 4'd5,
        S_N2_D3      = 4'd6,
        S_N2_ENTER   = 4'd7,
        S_RESULTADO  = 4'd8
    } estado_t;

    estado_t state;

    logic [3:0] c1, d1, u1;
    logic [3:0] c2, d2, u2;

    // Función explícita para aceptar solo teclas 0-9.
    // Esto evita cualquier problema raro con comparaciones tipo <= 9.
    function automatic logic es_digito(input logic [3:0] tecla);
        begin
            unique case (tecla)
                4'h0, 4'h1, 4'h2, 4'h3, 4'h4,
                4'h5, 4'h6, 4'h7, 4'h8, 4'h9: es_digito = 1'b1;
                default: es_digito = 1'b0;
            endcase
        end
    endfunction

    function automatic logic es_enter(input logic [3:0] tecla);
        begin
            es_enter = (tecla == 4'hA);
        end
    endfunction

    // Conversión cdu decimal a binario: c*100 + d*10 + u
    function automatic logic [13:0] dec3_to_bin(
        input logic [3:0] c,
        input logic [3:0] d,
        input logic [3:0] u
    );
        logic [13:0] cw, dw, uw;
        begin
            cw = {10'd0, c};
            dw = {10'd0, d};
            uw = {10'd0, u};

            // 100 = 64 + 32 + 4
            // 10  = 8 + 2
            dec3_to_bin = (cw << 6) + (cw << 5) + (cw << 2) +
                          (dw << 3) + (dw << 1) + uw;
        end
    endfunction

    // Salidas hacia top/display
    assign c1_o = c1;
    assign d1_o = d1;
    assign u1_o = u1;

    assign c2_o = c2;
    assign d2_o = d2;
    assign u2_o = u2;

    assign estado_vis = state;

    // Valores binarios siempre calculados desde los dígitos visibles
    assign n1_bin = dec3_to_bin(c1, d1, u1);
    assign n2_bin = dec3_to_bin(c2, d2, u2);
    assign suma   = n1_bin + n2_bin;

    // FSM y ruta de datos juntas
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_N1_D1;

            c1 <= 4'd0;
            d1 <= 4'd0;
            u1 <= 4'd0;

            c2 <= 4'd0;
            d2 <= 4'd0;
            u2 <= 4'd0;
        end else begin
            if (pulse_tecla) begin
                unique case (state)

                    // -------------------------
                    // Número 1
                    // -------------------------
                    S_N1_D1: begin
                        if (es_digito(pos_tecla)) begin
                            c1 <= d1;
                            d1 <= u1;
                            u1 <= pos_tecla;
                            state <= S_N1_D2;
                        end
                    end

                    S_N1_D2: begin
                        if (es_digito(pos_tecla)) begin
                            c1 <= d1;
                            d1 <= u1;
                            u1 <= pos_tecla;
                            state <= S_N1_D3;
                        end else if (es_enter(pos_tecla)) begin
                            state <= S_N2_D1;
                        end
                    end

                    S_N1_D3: begin
                        if (es_digito(pos_tecla)) begin
                            c1 <= d1;
                            d1 <= u1;
                            u1 <= pos_tecla;
                            state <= S_N1_ENTER;
                        end else if (es_enter(pos_tecla)) begin
                            state <= S_N2_D1;
                        end
                    end

                    S_N1_ENTER: begin
                        if (es_enter(pos_tecla)) begin
                            state <= S_N2_D1;
                        end
                        // Cualquier dígito extra se ignora.
                    end

                    // -------------------------
                    // Número 2
                    // -------------------------
                    S_N2_D1: begin
                        if (es_digito(pos_tecla)) begin
                            c2 <= d2;
                            d2 <= u2;
                            u2 <= pos_tecla;
                            state <= S_N2_D2;
                        end
                    end

                    S_N2_D2: begin
                        if (es_digito(pos_tecla)) begin
                            c2 <= d2;
                            d2 <= u2;
                            u2 <= pos_tecla;
                            state <= S_N2_D3;
                        end else if (es_enter(pos_tecla)) begin
                            state <= S_RESULTADO;
                        end
                    end

                    S_N2_D3: begin
                        if (es_digito(pos_tecla)) begin
                            c2 <= d2;
                            d2 <= u2;
                            u2 <= pos_tecla;
                            state <= S_N2_ENTER;
                        end else if (es_enter(pos_tecla)) begin
                            state <= S_RESULTADO;
                        end
                    end

                    S_N2_ENTER: begin
                        if (es_enter(pos_tecla)) begin
                            state <= S_RESULTADO;
                        end
                        // Cualquier dígito extra se ignora.
                    end

                    // -------------------------
                    // Resultado
                    // -------------------------
                    S_RESULTADO: begin
                        // Se queda mostrando resultado.
                        // Para empezar otra operación, usar reset físico.
                        state <= S_RESULTADO;
                    end

                    default: begin
                        state <= S_N1_D1;

                        c1 <= 4'd0;
                        d1 <= 4'd0;
                        u1 <= 4'd0;

                        c2 <= 4'd0;
                        d2 <= 4'd0;
                        u2 <= 4'd0;
                    end

                endcase
            end
        end
    end

endmodule