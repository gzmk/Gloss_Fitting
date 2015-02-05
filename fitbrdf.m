%% 
% Params for fminsearch scalexyz, position of the sphere, ro_s, ro_d, light
% source
banana = @(x)100*(x(2)-x(1)^2)^2+(1-x(1))^2;
% Pass the function handle to fminsearch:

[x,fval] = fminsearch(banana,[-1.2, 1])

gloss70 = imread('DSC_0111_70gloss.pgm');