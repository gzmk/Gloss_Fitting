%fitting brdf to images

% Idea: I might be able to store the params in an array and write them into
% the conditions file at each iteration - take a look at this
function costIm = renderIm_3params(var)

% check rho_s+rho_d <1, if this is bigger than 1, renderer will scale both.
% We don't want the renderer to scale as that messes up fminsearch
% parameters. 

if (var(1)+var(2) > 1) % check if there is any negative number in input variable
    costIm = 1e+10;    % give a big value to the result
    return;           % return to fminsearch - do not execute the rest of the code
end

if var(1)<0 || var(2)<0 || var(3)<0
    costIm = 1e+10;
    return;
end

% past_params = [];
% cost_arr = [];

persistent past_params; 
persistent cost_arr;
if isempty(past_params) 
    past_params = []; 
end
if isempty(cost_arr)
    cost_arr = [];
end

% print the new values of parameters for every fminsearch iteration
sprintf('The new variables are: ro_s: %f ro_d: %f alphau: %f', var(1), var(2), var(3))

% empty = isempty(past_params);
if ~isempty(past_params)
    sprintf('BBBBBBB')
%     idx = find(ismember(past_params,var','rows'))
    idx = find(ismember(past_params,var,'rows'))
    if ~isempty(idx)
        costIm = cost_arr(idx(1));
        return; 
    end
end

%% to write new conditions file with replaced params
% write to file in tabular form
% var = XBest; % this is to re-render the best fits

% var = [0.0760; 0.2168; 0.0472]; % this is for test
ro_s = var(1);
ro_d = var(2);
alphau = var(3); % alphau and alphav should always be the same value for isotropic brdf

T = table(ro_s,ro_d, alphau);
writetable(T,'/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/test_sphere_3params_Conditions.txt','Delimiter','\t')
%% Rendering bit

% Set preferences
setpref('RenderToolbox3', 'workingFolder', '/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos');

% use this scene and condition file. 
parentSceneFile = 'test_sphere.dae';
% WriteDefaultMappingsFile(parentSceneFile); % After this step you need to edit the mappings file

conditionsFile = 'test_sphere_3params_Conditions.txt';
mappingsFile = 'test_sphere_3params_DefaultMappings.txt';

% Make sure all illuminants are added to the path. 
addpath(genpath(pwd))

% Choose batch renderer options.

% hints.imageWidth = 4012;
% hints.imageHeight = 6034;
% hints.imageWidth = 600;% these are for quick rendering
% hints.imageHeight = 800;
hints.imageWidth = 668;% these are for quick rendering
hints.imageHeight = 1005;
hints.renderer = 'Mitsuba';

datetime=datestr(now);
datetime=strrep(datetime,':','_'); %Replace colon with underscore
datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
datetime=strrep(datetime,' ','_');%Replace space with underscore
%hints.recipeName = ['Test-SphereFit' datetime];
hints.recipeName = ['Test-SphereFit' date];

ChangeToWorkingFolder(hints);

% nativeSceneFiles = MakeSceneFiles(parentSceneFile, '', mappingsFile, hints);
nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);

%comment all this out
toneMapFactor = 10;
isScale = true;
montageName = sprintf('%s (%s)', 'Test-SphereFit', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);

% load the monochromatic image and display it
imPath = ['/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/', hints.recipeName, '/renderings/Mitsuba/test_sphere-001.mat']
load(imPath, 'multispectralImage');
im2 = multispectralImage;
imshow(im2/255)

sprintf('AAAAAAA')
imwrite(im2, '/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/im2.pgm','pgm');
%% calculate the ssd (error) between two images
% dcraw command: -4 -d -v -w -b 3.0 DSC_0111_70gloss.pgm
% -b 3.0 makes it 3 times brighter
% gloss40 = imread('registered_photo.pgm','pgm');
gloss = imread('registered40.pgm','pgm'); % turn this into a variable
photo = double(gloss)/255;

black = imread('DSC_0112.pgm')';
imblack = imresize(black, [1005,668]);
imblack2 = double(imblack)/65535;
image1 = photo-imblack2;

image2 = multispectralImage/255;
% renderedIm = imread('im2.pgm','pgm');
% image2 = double(renderedIm)/255;


diff = image1-image2;
costIm = sum(sum(diff.^2))

cost_arr = [cost_arr;costIm];
% past_params = [past_params;var'];
past_params = [past_params;var]; % this for grid search as it takes in row arrays

return;



