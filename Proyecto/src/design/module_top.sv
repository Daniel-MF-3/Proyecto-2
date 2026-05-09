module top (
    input  logic clk,
    input  logic reset,
    input  logic [3:0] filas,
    output logic [3:0] columnas,
    output logic [3:0] anodos,
    output logic [6:0] siete_seg,
    output logic led_externo_contacto,
    output logic led_externo_pulso,
    output logic led_externo_bit0
);

    // Se conserva la convención previa: reset externo activo en 0.
    logic rst_high;
    assign rst_high = ~reset;

    logic tecla_v_raw;
    logic [3:0] tecla_p_raw;
    logic pulse_ok;
    logic [3:0] tecla_ok;
    logic pulse_fsm;//Esta vara es porque 9 tarda mas que las otras teclas, por lo que se necesita un pulso extra para que la FSM avance

    logic [13:0] n1_bin, n2_bin, suma_res;
    logic [3:0] s_est;

    logic [3:0] c1, d1, u1, c2, d2, u2;
    logic [3:0] res_m, res_c, res_d, res_u;
    logic [3:0] v1, v2, v3, v4;

    assign led_externo_contacto = ~tecla_v_raw;
    assign led_externo_bit0     = ~tecla_ok[0];
    assign led_externo_pulso    = ~pulse_ok;

    scanner u_scan (
        .clk(clk),
        .reset(rst_high),
        .stop_scanning(tecla_v_raw),
        .filas(filas),
        .columnas(columnas),
        .tecla_detectada(tecla_v_raw),
        .pos_tecla(tecla_p_raw)
    );

    debounce #(.N(21)) u_debounce (
        .clk(clk),
        .rst(rst_high),
        .valido(tecla_v_raw),
        .tecla(tecla_p_raw),
        .limpio(pulse_ok),
        .seleccion(tecla_ok)
    );

    always_ff @(posedge clk or posedge rst_high) begin
    if (rst_high)
        pulse_fsm <= 1'b0;
    else
        pulse_fsm <= pulse_ok;
    end

    FSM_control u_fsm (
    .clk(clk),
    .reset(rst_high),
    .pulse_tecla(pulse_fsm),
    .pos_tecla(tecla_ok),
    .n1_bin(n1_bin),
    .n2_bin(n2_bin),
    .suma(suma_res),
    .estado_vis(s_est),
    .c1_o(c1), .d1_o(d1), .u1_o(u1),
    .c2_o(c2), .d2_o(d2), .u2_o(u2)
    );

    bin_to_bcd u_bcd (
    .clk(clk),
    .reset(rst_high),
    .binario(suma_res[10:0]),
    .millar(res_m),
    .centena(res_c),
    .decena(res_d),
    .unidad(res_u)
    );

    assign {v4, v3, v2, v1} = (s_est == 4'd8) ? {res_m, res_c, res_d, res_u} :
                          (s_est <  4'd4) ? {4'hF, c1, d1, u1} :
                                             {4'hF, c2, d2, u2};
    

    // --- 6. CONTROLADOR DE DISPLAYS ---
    controlador_display_total u_disp (
        .clk(clk),
        .reset(rst_high),
        .val1(v1),
        .val2(v2),
        .val3(v3),
        .val4(v4),
        .anodos(anodos),
        .siete_seg(siete_seg)
    );
    endmodule