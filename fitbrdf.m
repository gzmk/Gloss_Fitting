%% 
% Params for fminsearch scalexyz, position of the sphere, ro_s, ro_d, light
% Pass the function handle to fminsearch:

%% fitting 6 parameters: rho_s, rho_d, alphauv, locx, locy, scalex
start_params = [0.05; 0.1; 0.2; 0; 0; 2.2];
LB = [0.0; 0.0; 0.0; -1; -1; 2];
UB = [1.0; 1.0; 1.0; 1; 1; 2.5];
NumDiv = [10 10 10 10 10 10];
MinDeltaX = [1e-5 1e-5 1e-5 1e-5 1e-5 1e-5];

% start_params = [50; 50; 10; 0; 0; 200];
% LB = [0; 0; 0; -Inf; -Inf; 100];
% UB = [100; 100; 100; Inf; Inf; 300];

% opt = optimset('MaxFunEvals', 2400);
% [var,fval,exitflag, output] = fminsearchbnd(@(var) renderIm(var),start_params,LB,UB);
% [var,fval,exitflag, output] = fmincon(@(var) renderIm(var),start_params,A,b,LB,UB);
[XBest,BestF,Iters] = Grid_Search(6, LB', UB', NumDiv, MinDeltaX, 1e-7, 1000, 'renderIm');


%% fitting 3 parameters: rho_s, rho_d, alphauv

% init parameters
% start_params = [0.05; 0.1; 0.2];
LB = [0.0; 0.0; 0.0];
UB = [1.0; 1.0; 1.0];
NumDiv = [5 5 5];
MinDeltaX = [1e-5 1e-5 1e-5];

% grid search
[XBest,BestF,Iters] = Grid_Search(3, LB', UB', NumDiv, MinDeltaX, 1e-7, 1000, 'renderIm_3params');
