function f = MOS_callback_fns(func)
    
    f = str2func(func);
end

function W = depletion_width(K_s, phi_s, N_a)
    % Function to return depletion width of MOS junction
     
    % Permittivity of free space
    eps_0 = 8.85e-12;
    % Charge value
    q = 1.6e-19;
    
    W = sqrt(2 * K_s * eps_0 * phi_s / (q * N_a));
    
end
    
    