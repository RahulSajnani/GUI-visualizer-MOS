function f = MOS_callback_fns(func)
    
    f = str2func(func);
end

function set_globals()
    
    global eps_0 q ticks k E_g A_ox; 
    % Permittivity of free space
    eps_0 = 8.85e-12;
    % Charge value
    q = 1.6e-19;
    % ticks
    ticks = 1e4;
    % boltzmann constant
    k = 1.38e-23;
    % Energy band gap for Silicon
    E_g = 1.14 * q;
    
    % Cross section area
    A_ox = 1e-7;
end

function W = get_depletion_width(K_s, phi_s, N_a)
    % Function to return depletion width of MOS junction
    
    % set global variables
    set_globals();
    global eps_0 q;
    
    % Width of depletion layer
    W = sqrt(2 * K_s * eps_0 * phi_s / (q * N_a));

    if W ~= real(W)
        W = sqrt(2 * K_s * eps_0 * -phi_s / (q * N_a));
    end
    
end

function [E_field, x_axis] = get_electric_field(N_a, K_s, K_ox, L, T_ox, Temp, phi_m, phi_p, V_g, type_si)
    % Function to get electric field at MOS junction
    
    % set global variables
    set_globals();
    % get global values for eps and q
    global eps_0 q ticks k n_i;
    
    
    % flatband voltage
    V_fb = phi_m - phi_p;
    

    % Solving quadrtic equation in the given link to get surface potential: https://engineering.purdue.edu/~ee606/downloads/ECE606_f12_Lecture21.pdf
    phi_s = get_phi_s(V_g, V_fb, K_s, N_a, T_ox, K_ox, type_si);
    n_i = 1.5 * 10^10 * (100)^3;
    
    if type_si == 0
        % P type substrate
        phi_f = (k * Temp / q) * log(N_a / n_i);
    else
        % N type substrate
        phi_f = -(k * Temp / q) * log(N_a / n_i);
    end

    if (phi_s > 2 * phi_f) && type_si == 0
        phi_s = 2 * phi_f;

    elseif (phi_s < 2 * phi_f) && type_si == 1
        phi_s = 2 * phi_f;
    end
    [x_axis, mid_point, x_step, s] = initialize(L);
    
    E_field = zeros(1, s);
    % n_i = 5.29 * 10^(19) * (Temp / 300);
    W = get_depletion_width(K_s, phi_s, N_a);
    
    % junction position and depletion width in steps
    junction_position = int16(mid_point - (T_ox / (x_step)));
    W_position = int16(mid_point + ((W) / (x_step)));
    
    
    E_field(junction_position:mid_point) = q * N_a * x_axis(W_position) / (K_ox * eps_0);
    E_field(mid_point:W_position) =  -q * N_a * (x_axis(mid_point:W_position) - x_axis(W_position)) / (eps_0 * K_s);
    
end
    
function potential = get_voltage_junction(N_a, K_s, K_ox, L, T_ox, Temp, V_a, phi_m, phi_p, V_g, type_si)
    % Function to get voltage plot for MOS junction
    
    % set global variables
    set_globals();
    % get global values for eps and q
    global eps_0 q ticks k;

    
    [x_axis, mid_point, x_step, s] = initialize(L);

    
    % flatband voltage
    V_fb = phi_m - phi_p;
    potential = zeros(1, s);

    % Solving quadrtic equation in the given link to get surface potential: https://engineering.purdue.edu/~ee606/downloads/ECE606_f12_Lecture21.pdf
    phi_s = get_phi_s(V_g, V_fb, K_s, N_a, T_ox, K_ox, type_si);
    n_i = 1.5 * 10^10 * (100)^3;
    
    if type_si == 0
        % P type substrate
        phi_f = (k * Temp / q) * log(N_a / n_i);
    else
        % N type substrate
        phi_f = -(k * Temp / q) * log(N_a / n_i);
    end
    
    if (phi_s > 2 * phi_f) && type_si == 0
        phi_s = 2 * phi_f;

    elseif (phi_s < 2 * phi_f) && type_si == 1
        phi_s = 2 * phi_f;
    end

    % n_i = 5.29 * 10^(19) * (Temp / 300);
    W = get_depletion_width(K_s, phi_s, N_a);
    E = get_electric_field(N_a, K_s, K_ox, L, T_ox, Temp, phi_m, phi_p, V_g, type_si);

    
    
    % junction position and depletion width in steps
    junction_position = int16(mid_point - (T_ox / (x_step)));
    W_position = int16(mid_point + ((W) / (x_step)));

    %potential(junction_position:mid_point) = q * N_a * x_axis(W_position) / (K_ox * eps_0);
    potential(mid_point:W_position) =  q * N_a * (x_axis(W_position) - x_axis(mid_point:W_position)).^2 / (eps_0 * K_s * 2);
    m = (V_a - potential(mid_point)) / (x_axis(junction_position) - x_axis(mid_point));
    c = V_a - m * x_axis(junction_position);
    potential(junction_position:mid_point) = m * (x_axis(junction_position:mid_point)) + c; 
    potential(1:junction_position) = V_a;
    
end

function Q_density = get_charge_density(N_a, K_s, K_ox, L, T_ox, phi_m, phi_p, Temp, V_g, type_si)
    
    set_globals();
    global q ticks k;
    
    [x_axis, mid_point, x_step, s] = initialize(L);
    
    Q_density = zeros(1, s);

    V_fb = phi_m - phi_p;
    phi_s = get_phi_s(V_g, V_fb, K_s, N_a, T_ox, K_ox, type_si);
    
    n_i = 1.5 * 10^10 * (100)^3;
    % n_i = 5.29 * 10^(19) * (Temp / 300);
    if type_si == 0
        % P type substrate
        phi_f = (k * Temp / q) * log(N_a / n_i);
    else
        % N type substrate
        phi_f = -(k * Temp / q) * log(N_a / n_i);
    end

    % Obtain depletion width
    
    if (phi_s > 2 * phi_f) && type_si == 0
        phi_s = 2 * phi_f;

    elseif (phi_s < 2 * phi_f) && type_si == 1
        phi_s = 2 * phi_f;
    end
    W = get_depletion_width(K_s, phi_s, N_a);
    
    % junction position and depletion width in steps
    junction_position = int16(mid_point - (T_ox / (x_step)));
    W_position = int16(mid_point + ((W) / (x_step)));
    
    Q_d = -q * N_a * W;
    
    Q_density(1:junction_position) = q * N_a * W / (x_axis(junction_position) - x_axis(1) + 0.00000001);
    Q_density(mid_point:W_position) =  -q * N_a; 

    if W < 1e-17
        Q_density = zeros(1, s);
    end
    
end


function [x_axis, mid_point, x_step, s] = initialize(L)


    set_globals();
    % get global values for eps and q
    global eps_0 q ticks k;
    x_step = (2 * L) / ticks;
    x_axis = -L:x_step:L;
    s = size(x_axis);
    s = s(2);
    mid_point = int16(s / 2);

end


function [root_1, root_2] = solve_quadratic_equation(a, b, c)

    d = sqrt(b.^2 - 4 * a * c);

    root_1 = (-b + d) / (2 * a);
    root_2 = (-b - d) / (2 * a);
end


function phi_s = get_phi_s(V_g, V_fb, K_s, N_a, T_ox, K_ox, type_si)

    set_globals()
    global eps_0 q A_ox;

    C_ox = K_ox * eps_0 * A_ox / T_ox;

    % phi_s = (q * N_a * K_s * eps_0) / (2 * C_ox^2) * (sqrt(1 + 2 * C_ox^2 * (V_g - V_fb) / (q * N_a * K_s * eps_0)) - 1)^2; 
    a = 1.0;
    b = -2 * (V_g - V_fb) - (2 * q * N_a * K_s * T_ox.^2) / (K_ox^2 * eps_0);
    c = (V_g - V_fb).^2;
    
    [root_1, root_2] = solve_quadratic_equation(a, b, c);
    if type_si == 0

        phi_s = root_2;
    else
        phi_s = root_1;
    end

end

function [E_f, E_c, E_i, E_v, E_f_metal, V_th, phi_s, phi_f, W] = get_energy_band(N_a, K_s, K_ox, L, T_ox, phi_m, phi_p, Temp, V_g, type_si)
    
    set_globals();
    
    global q ticks k eps_0 E_g A_ox;
    
    [x_axis, mid_point, x_step, s] = initialize(L);
    
    % flatband voltage
    V_fb = phi_m - phi_p;

    % applied voltage
    V_a = V_g - V_fb;
    
    E_f = q * phi_p  * ones(1,s);
    E_i = E_f;
    potential = get_voltage_junction(N_a, K_s, K_ox, L, T_ox, Temp, V_a, phi_m, phi_p, V_g, type_si);
    n_i = 1.5 * 10^10 * (100)^3; 
    %5.29 * 10^(19) * (Temp / 300);

    if type_si == 0
        % P type substrate
        phi_f = (k * Temp / q) * log(N_a / n_i);
    else
        % N type substrate
        phi_f = -(k * Temp / q) * log(N_a / n_i);
    end
        E_i(mid_point:end) = -q * potential(mid_point:end) + q * phi_f + E_f(mid_point:end);
    
        C_ox_per_area = K_ox * eps_0 / (T_ox);

    C_ox = C_ox_per_area * A_ox;

    E_f_metal = E_f - q * (V_g - V_fb);
   
    % Solving quadrtic equation in the given link to get surface potential: https://engineering.purdue.edu/~ee606/downloads/ECE606_f12_Lecture21.pdf 
    phi_s = get_phi_s(V_g, V_fb, K_s, N_a, T_ox, K_ox, type_si);


    
    if (phi_s > 2 * phi_f) && type_si == 0
        phi_s = 2 * phi_f;   
    
    elseif (phi_s < 2 * phi_f) && type_si == 1
        phi_s = 2 * phi_f;
    end


    W = get_depletion_width(K_s, phi_s, N_a);
    
    if type_si == 0
        V_th = V_fb + sqrt(2 * q * K_s * eps_0 * N_a * 2 * phi_f) / C_ox_per_area + 2 * phi_f;
    else
        V_th = V_fb - sqrt(2 * q * K_s * eps_0 * -N_a * 2 * abs(phi_f)) / C_ox_per_area + 2 * phi_f;
    end
    % junction position and depletion width in steps
    junction_position = int16(mid_point - (T_ox / (x_step)));
    W_position = int16(mid_point + ((W) / (x_step)));

    
    E_v = E_i - E_g / 2;
    E_v(1:mid_point) = E_i(1:mid_point);
    E_c = E_i + E_g / 2;
    E_c(1:mid_point) = E_i(1:mid_point);
     
end