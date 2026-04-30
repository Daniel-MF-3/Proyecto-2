module debounce (parameter N = 21 )
(
 //Entradas
    input logic clk, 
    input logic rst,
    input logic valido,
    input logic [3:0] tecla,


 //Salidas
    output logic limpio,
    output logic seleccion [3:0]
);


logic DFF1, DFF2;


// Evita problemas al traer señales externas al clok y ayuda a detectar cambios
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        DFF1 <= 0;
        DFF2 <= 0;
    end else begin
       DFF1 <= valido;
       DFF2 <= DFF1;
    end
    
end


logic [N-1:0] q_reg, q_next;

wire q_reset;
wire q_add;


//Detecta el cambio en la señal (rebote)
assign q_reset = DFF1 ^ DFF2;

//Cuenta mientras no haya llegado al máximo
assign q_add = ~q_reg[N-1];


//Logica combinacional del contador
always_comb begin 

    case ({q_reset, q_add})
    2'b00 : q_next = q_reg
    2'b01 : q_next = q_reg + 1;
    default: q_next ='0
    endcase  
end

//Registro del contador
always_ff @(posedge clk or posedge rst) begin
    if (rst)
    q_reg <= '0;
    else
    q_reg <= q_next; //acumula el tiempo
    
end


// Señal limpia

logic valido_limpio;

always_ff @(posedge clk or posedge rst) begin
if (rst)
            valido_limpio <= 0;
        else if (q_reg[N-1])   // cuando pasa el tiempo y la señal esta estable
            valido_limpio <= DFF2;

end

// Detecta si está limpio

logic valido_prev;

always_ff @(posedge clk or posedge rst) begin
if(rst)
valido_prev <=0;
else
valido_prev <= valido_limpio;
end

assign limpio = valido_limpio & ~valido_prev;

//Se registra la tecla

always_ff @(posedge clk or posedge rst) begin
    if(rst)
    seleccion <=0;
    else if(limpio) //Guarda la tecla se está valida
    selección <= tecla;
end


endmodule 