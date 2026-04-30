`timescale 1 ns / 100 ps

module debounce_tb()

reg clk;
reg rst;
reg valido;
reg [3:0] tecla;

wire limpio;
mire [3:0] seleccion;

debounce (.N10) UUT(
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
    tecla 4'd0;

    #100 rst = 0;

end

always #10 clk = ~clk; // Un period de 20 ns

initial begin

   #200;

    
    tecla = 4'd5;

  
    #50  valido = 1;
    #20  valido = 0;
    #20  valido = 1;
    #20  valido = 0;
    #20  valido = 1;

    
    #5000 valido = 1;

    
    #2000 valido = 0;

    
    #2000;
    tecla = 4'd7;

    // Simula un rebote
    #50  valido = 1;
    #20  valido = 0;
    #20  valido = 1;

    
    #5000 valido = 1;

    
    #2000 valido = 0;

    
    #1000;
    tecla = 4'd3;

    #20 valido = 1;
    #20 valido = 0;
    #20 valido = 1;
    #20 valido = 0;

   

    #5000;

    $finish;
end 


    

endmodule