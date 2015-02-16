%% 
% Params for fminsearch scalexyz, position of the sphere, ro_s, ro_d, light
% Pass the function handle to fminsearch:

start_params = [0.5; 0.5; 0.1; 0; 0; 1];
[var,fval,exitflag, output] = fminsearch(@(var) renderIm(var),start_params);
