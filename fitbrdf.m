%% 
% Params for fminsearch scalexyz, position of the sphere, ro_s, ro_d, light
% Pass the function handle to fminsearch:

% start_params = [0.3];

start_params = [0.05; 0.1; 0.2; 0; 0; 2.2];
LB = [0.0; 0.0; 0.0; -Inf; -Inf; 2];
UB = [1.0; 1.0; 1.0; Inf; Inf; 2.5];

% start_params = [50; 50; 10; 0; 0; 200];
% LB = [0; 0; 0; -Inf; -Inf; 100];
% UB = [100; 100; 100; Inf; Inf; 300];

opt = optimset('MaxFunEvals', 2400);
[var,fval,exitflag, output] = fminsearchbnd(@(var) renderIm(var),start_params,LB,UB,opt);
% [var,fval,exitflag, output] = fmincon(@(var) renderIm(var),start_params,A,b,LB,UB);
