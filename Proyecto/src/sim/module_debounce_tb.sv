`timescale 1 ns / 100 ps

module debounce_tb;

logic clk;
logic rst;
logic valido;
logic [3:0] tecla;

wire limpio;
wire [3:0] seleccion;

debounce #(.N(4)) UUT(
    .clk(clk),
    .rst(rst),
    .valido(valido),
    .tecla(tecla),
    .limpio(limpio),
    .seleccion(seleccion)
);

initial begin
    clk = 0;
    rst = 1;
    valido = 0;
    tecla = 4'd0;

    #100 rst = 0;

end

always #10 clk = ~clk; // Un period de 20 ns

initial begin

   #200;

    
    tecla = 4'd5; //Se presiona la tecla 5

    //Simulación de rebote
    #50  valido = 1;
    #20  valido = 0;
    #20  valido = 1;
    #20  valido = 0;
    #20  valido = 1;

    
    #30000 valido = 1; //Mantiene la señal estable

    
    #2000 valido = 0;

    
    #2000;
    tecla = 4'd7; //Se presiona otra tecla (7) y el mismo proceso.

    // Simula un rebote
    #50  valido = 1;
    #20  valido = 0;
    #20  valido = 1;

    
    #30000 valido = 1;

    
    #2000 valido = 0;

    
    #1000;
    tecla = 4'd3;

    #20 valido = 1;
    #20 valido = 0;
    #20 valido = 1;
    #20 valido = 0;

    #200 valido = 1; 


   

    #30000;

    $finish;
end 
initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0,debounce_tb);
    end


    

endmodule