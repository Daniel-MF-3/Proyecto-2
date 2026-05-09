module debounce #(parameter N = 21) (
    input  logic clk,
    input  logic rst,
    input  logic valido,
    input  logic [3:0] tecla,
    output logic limpio,
    output logic [3:0] seleccion
);

    // Sincronización de entrada asíncrona
    logic valido_s1, valido_s2;
    logic [3:0] tecla_s1, tecla_s2;
    

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            valido_s1 <= 1'b0;
            valido_s2 <= 1'b0;
            tecla_s1  <= 4'd0;
            tecla_s2  <= 4'd0;
        end else begin
            valido_s1 <= valido;
            valido_s2 <= valido_s1;

            tecla_s1 <= tecla;
            tecla_s2 <= tecla_s1;
        end
    end

    // Se estabiliza el paquete completo: valido + tecla
    logic [4:0] muestra_actual;
    logic [4:0] muestra_anterior;

    assign muestra_actual = {valido_s2, tecla_s2};

    logic [N-1:0] contador;
    logic estable;
    logic armado;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            muestra_anterior <= 5'd0;
            contador         <= '0;
            estable          <= 1'b0;
            armado           <= 1'b1;
            limpio           <= 1'b0;
            seleccion        <= 4'd0;
        end else begin
            limpio <= 1'b0;

            // Si cambia valido o cambia la tecla, se reinicia el conteo
            if (muestra_actual != muestra_anterior) begin
                muestra_anterior <= muestra_actual;
                contador         <= '0;
                estable          <= 1'b0;
            end else begin
                if (!contador[N-1]) begin
                    contador <= contador + {{(N-1){1'b0}}, 1'b1};
                end else begin
                    estable <= 1'b1;
                end
            end

            // Cuando hay una tecla estable y el sistema está armado,
            // se genera un solo pulso.
            if (estable && muestra_anterior[4] && armado) begin
                seleccion <= muestra_anterior[3:0];
                limpio    <= 1'b1;
                armado    <= 1'b0;
            end

            // Cuando se libera la tecla de forma estable, se rearma.
            if (estable && !muestra_anterior[4]) begin
                armado <= 1'b1;
            end
        end
    end

endmodule
