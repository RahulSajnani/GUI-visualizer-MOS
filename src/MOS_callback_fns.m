function f = MOS_callback_fns(func)
    
    f = str2func(func);
end

function set_globals()
    
    global eps_0 q; 
    % Permittivity of free space
    eps_0 = 8.85e-12;
    % Charge value
    q = 1.6e-19;
    
end

function W = get_depletion_width(K_s, phi_s, N_a)
    % Function to return depletion width of MOS junction
    
    % set global variables
    set_globals();
    global eps_0 q;
    
    % Width of depletion layer
    W = sqrt(2 * K_s * eps_0 * phi_s / (q * N_a));
    
end

function E_field = get_electric_field(N_a, K_s, K_ox, L, T_ox, phi_s)
    % Function to get electric field at MOS junction
    
    ticks = 1000;
    x_step = (2*L) / ticks;
    x_axis = -L:x_step:L;

    s = size(x_axis);
    s = s(2);
    
    mid_point = int16(s/2);
    
    E_field = zeros(1, s);
    W = get_depletion_width(K_s, phi_s, N_a);
    
    % junction position and depletion width in steps
    junction_position = int16(mid_point - (T_ox / (x_step)));
    W_position = int16(mid_point + ((W) / (x_step)));
    
    % set global variables
    set_globals();
    % get global values for eps and q
    global eps_0 q;

    E_field(junction_position:mid_point) = q * N_a * x_axis(W_position) / (K_ox * eps_0);
    E_field(mid_point:W_position) =  -q * N_a * (x_axis(mid_point:W_position) - x_axis(W_position)) / (eps_0 * K_s);
end
    

    