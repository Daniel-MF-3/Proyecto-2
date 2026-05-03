module debounce #(parameter N = 21 )
(
 //Entradas
    input logic clk,  //reloj
    input logic rst, //reset
    input logic valido, //señal del teclado
    input logic [3:0] tecla, //valor de la tecla


 //Salidas
    output logic limpio, // pulso cunado una tecla es válida
    output logic [3:0] seleccion // valor de la tecla valida
);


logic DFF1, DFF2; // Son 2 flip-flops 


// Esto ejecuta cuando en cada subida del relo o cuando hay un reset
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin  //Si hay reset, es cero
        DFF1 <= 0;
        DFF2 <= 0;
    end else begin
       DFF1 <= valido; // guarda valido
       DFF2 <= DFF1; // guarde el valor anterior de DFF1 (DDF2 es una versión estable y sincronizada de la señal)
    end
    
end


logic [N-1:0] q_reg, q_next; // q_reg: valor actual del contador. q_next: es el siguiente valor.

wire q_reset; //reinicia el contador
wire q_add; // inidca si debe seguir contando



assign q_reset = (DFF1 ^ DFF2); // La XOR detecta cambios, si la señal cambia, es 1 y si es estable es 0. Si hay rebote, se reinicia el contador.

assign q_add = ~q_reg[N-1]; // Mientras el bit significativo sea 0, va seguir contando y cuando sea 1, deja de contar


//Logica combinacional del contador (sin memoria)
always_comb begin 
     if (q_reset) // Si hay rebote, reinicia el contador
        q_next = '0;
    else if (q_add) // Si no hay robote, suma 1
        q_next = q_reg + 1;
    else // Si llega al máximo, se queda igual.
        q_next = q_reg;
  
end

//Registro del contador
always_ff @(posedge clk or posedge rst) begin
    if (rst)
    q_reg <= '0; // si se resetea, el contador es 0
    else
    q_reg <= q_next; // guarda el siguiente valor
    
end

logic valido_limpio; //Señal ya filtrada

always_ff @(posedge clk or posedge rst) begin
 if (rst) // si se resetea, el valor_limpio es 0
        valido_limpio <= 0;
    else if (q_reg[N-1]) //Si el contador llegó al máximo, la señal ya es estable y se acepta como válida
        valido_limpio <= DFF2;
    else
        valido_limpio <= valido_limpio; // Se mantiene el valor anterior
end
// Detecta si está limpio

logic valido_prev; //guarda el valor anterior

always_ff @(posedge clk or posedge rst) begin
if(rst) // si se resetea, el valor_prev es 0
valido_prev <=0;
else
valido_prev <= valido_limpio; //Se actualiza
end

assign limpio = valido_limpio & ~valido_prev; // Esto detecta cuando pasa de 0 a 1 y genera un pulos de 1 ciclo de reloj


logic [3:0] tecla_sync; //Se registra la tecla

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        tecla_sync <= 0;
    else
        tecla_sync <= tecla; // Copia la tecla al reloj
end



always_ff @(posedge clk or posedge rst) begin // Bloque secuencial
    if(rst) // Si hay reseteo, no hay tecla
    seleccion <=0;
    else if(limpio) //Guarda la tecla si está valida
    seleccion <= tecla_sync;
end


endmodule 