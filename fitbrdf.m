%% 
% Params for fminsearch scalexyz, position of the sphere, ro_s, ro_d, light
% Pass the function handle to fminsearch:

start_params = [0.56; 0.56; 0.56];
[var,fval, exitflag] = fminsearch(@(var) renderIm(var),start_params,optimset('MaxIter',10));
