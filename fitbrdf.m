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
LB = [0.001; 0.001; 0.001];
UB = [1.0; 1.0; 1.0];
NumDiv = [5 5 5];
MinDeltaX = [1e-5 1e-5 1e-5];

% grid search
[XBest,BestF,Iters] = Grid_Search(3, LB', UB', NumDiv, MinDeltaX, 1e-7, 1000, 'renderIm_3params');

%% fitting 2 parameters: rho_s, rho_d while alpha is fixed to a value

LB = [0.001; 0.001];
UB = [1.0; 1.0];
NumDiv = [5 5];
MinDeltaX = [1e-5 1e-5];

% grid search
[XBest,BestF,Iters] = Grid_Search(2, LB', UB', NumDiv, MinDeltaX, 1e-7, 1000, 'renderIm_3params');

%% fitting 1 parameter: alpha. rho_s and rho_d are fixed to the value from the previous fitting pass

LB = 0.001;
UB = 1.0;
NumDiv = 5;
MinDeltaX = 1e-5;

% grid search
[XBest,BestF,Iters] = Grid_Search(1, LB, UB, NumDiv, MinDeltaX, 1e-7, 1000, 'renderIm_3params');

%% Loop through two fits 
% Step 1: Start from alphau = 0.2, fit ro_s and ro_d
% Step 2: Get the XBest from above fit and fix them, fit only alphau
iter = 15;
setGlobalalpha(0.2);

% init 2 param fitting
LB_2 = [0.001; 0.001];
UB_2 = [1.0; 1.0];
NumDiv_2 = [5 5];
MinDeltaX_2 = [1e-5 1e-5];

% init 1 param fitting
LB_1 = 0.001;
UB_1 = 1.0;
NumDiv_1 = 5;
MinDeltaX_1 = 1e-5;

bestRhos = [];
bestAlphas = [];
bestfit_2pr = [];
bestfit_1pr = [];

for i = 1:iter
    
    [XBest2,BestF2,Iters2] = Grid_Search(2, LB_2', UB_2', NumDiv_2, MinDeltaX_2, 1e-7, 1000, 'renderIm_2params');
    sprintf('This is XBest2:');
    XBest2;
    setGlobalros(XBest2(1))
    setGlobalrod(XBest2(2))
    bestRhos = [bestRhos;XBest2];
    bestfit_2pr = [bestfit_2pr;BestF2];
    sprintf('Fix rho_s: %f and rho_d: %f and fit alpha',XBest2(1),XBest2(2));
    [XBest1,BestF1,Iters1] = Grid_Search(1, LB_1, UB_1, NumDiv_1, MinDeltaX_1, 1e-7, 1000, 'renderIm_1params');
    sprintf('This is best alpha: %f',XBest1);
    setGlobalalpha(XBest1(1))
    bestAlphas = [bestAlphas;XBest1];
    bestfit_1pr = [bestfit_1pr;BestF1];
    sprintf('Fix alphau: %f and fit rho_s and rho_d', XBest1);

    
end
