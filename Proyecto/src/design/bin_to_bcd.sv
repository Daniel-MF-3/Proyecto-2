module bin_to_bcd (
    input  logic clk,
    input  logic reset,
    input  logic [10:0] binario, // Rango esperado: 0 a 1998
    output logic [3:0] millar,
    output logic [3:0] centena,
    output logic [3:0] decena,
    output logic [3:0] unidad
);

    typedef enum logic [2:0] {
        S_IDLE,
        S_INIT,
        S_MILLAR,
        S_CENTENA,
        S_DECENA,
        S_UNIDAD,
        S_DONE
    } estado_t;

    estado_t state;

    logic [10:0] bin_reg;
    logic [10:0] temp;

    logic [3:0] millar_work;
    logic [3:0] centena_work;
    logic [3:0] decena_work;
    logic [3:0] unidad_work;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_IDLE;

            bin_reg <= 11'd0;
            temp    <= 11'd0;

            millar_work  <= 4'd0;
            centena_work <= 4'd0;
            decena_work  <= 4'd0;
            unidad_work  <= 4'd0;

            millar  <= 4'd0;
            centena <= 4'd0;
            decena  <= 4'd0;
            unidad  <= 4'd0;
        end else begin
            case (state)

                S_IDLE: begin
                    if (binario != bin_reg) begin
                        state <= S_INIT;
                    end
                end

                S_INIT: begin
                    temp <= binario;

                    millar_work  <= 4'd0;
                    centena_work <= 4'd0;
                    decena_work  <= 4'd0;
                    unidad_work  <= 4'd0;

                    state <= S_MILLAR;
                end

                S_MILLAR: begin
                    if (temp >= 11'd1000) begin
                        temp <= temp - 11'd1000;
                        millar_work <= millar_work + 4'd1;
                    end else begin
                        state <= S_CENTENA;
                    end
                end

                S_CENTENA: begin
                    if (temp >= 11'd100) begin
                        temp <= temp - 11'd100;
                        centena_work <= centena_work + 4'd1;
                    end else begin
                        state <= S_DECENA;
                    end
                end

                S_DECENA: begin
                    if (temp >= 11'd10) begin
                        temp <= temp - 11'd10;
                        decena_work <= decena_work + 4'd1;
                    end else begin
                        state <= S_UNIDAD;
                    end
                end

                S_UNIDAD: begin
                    unidad_work <= temp[3:0];
                    state <= S_DONE;
                end

                S_DONE: begin
                    millar  <= millar_work;
                    centena <= centena_work;
                    decena  <= decena_work;
                    unidad  <= unidad_work;

                    bin_reg <= binario;
                    state <= S_IDLE;
                end

                default: begin
                    state <= S_IDLE;
                end

            endcase
        end
    end

endmodule