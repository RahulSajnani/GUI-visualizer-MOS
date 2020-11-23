function f = MOS_callback_fns(func)
    
    f = str2func(func);
end

function set_globals()
    
    global eps_0 q ticks k; 
    % Permittivity of free space
    eps_0 = 8.85e-12;
    % Charge value
    q = 1.6e-19;
    % ticks
    ticks = 1e4;
    % boltzmann constant
    k = 1.38e-23;
    
end

function W = get_depletion_width(K_s, phi_s, N_a)
    % Function to return depletion width of MOS junction
    
    % set global variables
    set_globals();
    global eps_0 q;
    
    % Width of depletion layer
    W = sqrt(2 * K_s * eps_0 * phi_s / (q * N_a));
    
end

function [E_field, x_axis] = get_electric_field(N_a, K_s, K_ox, L, T_ox, Temp)
    % Function to get electric field at MOS junction
    
    % set global variables
    set_globals();
    % get global values for eps and q
    global eps_0 q ticks k;

    x_step = (2*L) / ticks;
    x_axis = -L:x_step:L;

    s = size(x_axis);
    s = s(2);
    
    mid_point = int16(s/2);
    
    E_field = zeros(1, s);
    n_i = 5.29 * 10^(19) * (Temp / 300);
    phi_b = (k * Temp / q) * log(N_a / n_i);
    W = get_depletion_width(K_s, phi_b, N_a);
    
    % junction position and depletion width in steps
    junction_position = int16(mid_point - (T_ox / (x_step)));
    W_position = int16(mid_point + ((W) / (x_step)));
    
   
    E_field(junction_position:mid_point) = q * N_a * x_axis(W_position) / (K_ox * eps_0);
    E_field(mid_point:W_position) =  -q * N_a * (x_axis(mid_point:W_position) - x_axis(W_position)) / (eps_0 * K_s);
    
end
    
function potential = get_voltage_junction(N_a, K_s, K_ox, L, T_ox, Temp, V_a)
    % Function to get voltage plot for MOS junction
    
    % set global variables
    set_globals();
    % get global values for eps and q
    global eps_0 q ticks k;

    x_step = (2*L) / ticks;
    x_axis = -L:x_step:L;
    s = size(x_axis);
    s = s(2);
    mid_point = int16(s/2);
    
    potential = zeros(1, s);
    n_i = 5.29 * 10^(19) * (Temp / 300);
    phi_b = (k * Temp / q) * log(N_a / n_i);
    W = get_depletion_width(K_s, phi_b, N_a);
    
    E = get_electric_field(N_a, K_s, K_ox, L, T_ox, Temp);

    
    
    % junction position and depletion width in steps
    junction_position = int16(mid_point - (T_ox / (x_step)));
    W_position = int16(mid_point + ((W) / (x_step)));

    %potential(junction_position:mid_point) = q * N_a * x_axis(W_position) / (K_ox * eps_0);
    potential(mid_point:W_position) =  q * N_a * (x_axis(W_position) - x_axis(mid_point:W_position)).^2 / (eps_0 * K_s * 2);
    m = (V_a - potential(mid_point)) / (x_axis(junction_position) - x_axis(mid_point) + 0.00000000000000000001);
    c = V_a - m * x_axis(junction_position);
    potential(junction_position:mid_point) = m * (x_axis(junction_position:mid_point)) + c; 
    potential(1:junction_position) = V_a;
    
end

function Q_density = get_charge_density(N_a, K_s, K_ox, L, T_ox, phi_m, Temp)
    
    set_globals();
    global q ticks k;
    
    x_step = (2*L) / ticks;
    x_axis = -L:x_step:L;
    s = size(x_axis);
    s = s(2);
    mid_point = int16(s/2);
    
    
    Q_density = zeros(1, s);
    
    n_i = 5.29 * 10^(19) * (Temp / 300);
    phi_b = (k * Temp / q) * log(N_a / n_i);
    % Obtain depletion width
    
    W = get_depletion_width(K_s, phi_b, N_a);
    
    % junction position and depletion width in steps
    junction_position = int16(mid_point - (T_ox / (x_step)));
    W_position = int16(mid_point + ((W) / (x_step)));
    
    Q_d = -q * N_a * W;
    
    Q_density(1:junction_position) = q * N_a * W / (x_axis(junction_position) - x_axis(1) + 0.00000001);
    Q_density(mid_point:W_position) =  -q * N_a; 
    
end

function [E_c, E_i, E_v, E_f] = get_energy_band(N_a, K_s, K_ox, L, T_ox, phi_m, Temp, V_a)
    
    set_globals();
    global q ticks k;
    
    x_step = (2*L) / ticks;
    x_axis = -L:x_step:L;
    s = size(x_axis);
    s = s(2);
    mid_point = int16(s/2);
    
    % Energy band gap for Silicon
    E_g = 1.14 * q;
    
    n_i = 5.29 * 10^(19) * (Temp / 300);
    phi_b = (k * Temp / q) * log(N_a / n_i);
    V_fb = phi_m - phi_b;
    
    Ef_metal = q * (V_a + V_fb);
    
    E_f = ones(1, s) * Ef_metal;
    
    E_i = E_f;
    potential = get_voltage_junction(N_a, K_s, K_ox, L, T_ox, Temp, V_a);
    
    E_i(mid_point:end) = E_i(mid_point:end) - q*potential(mid_point:end) + q*phi_b;
    
    
    E_v = E_i - E_g / 2;
    
    E_v(1:mid_point) = E_i(1:mid_point);
    E_c = E_i + E_g / 2;
    E_c(1:mid_point) = E_i(1:mid_point);
    
    % Obtain depletion width
    W = get_depletion_width(K_s, phi_b, N_a);
    
    % junction position and depletion width in steps
    junction_position = int16(mid_point - (T_ox / (x_step)));
    W_position = int16(mid_point + ((W) / (x_step)));

  
    
end