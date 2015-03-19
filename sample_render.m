% Render sample spheres for each gloss level photo
% author @ gizem
% created March 2015

function sample_render(var, percent_gloss)
% variables:

% var: parameter array with 3 values [rho_s, rho_d, alpha]
%      the values in the array are float numbers

% percent_gloss: 0-100, represents the percent glossiness of the photo


%% first let's read the pgm image
% the goal is the render a sample image that looks similar to the photo (pgm file)

imname = ['pgms/',num2str(percent_gloss), 'gloss.pgm'];
glossim = imread(imname, 'pgm');

figure;imshow(double(glossim)/65535)

%%
% var = [0; 0; 0]; % for gloss0
% var = [0.04; 0.2; 0.3]; % for gloss10
% var = [0.03; 0.3; 0.18]; % for gloss20
% var = [0.05; 0.25; 0.2]; % for gloss30
% var = [0.4; 0.6; 0.2]; % for gloss40 
% var = [0.06; 0.2; 0.15]; % for gloss50
% var = [0.06; 0.2; 0.15]; % for gloss60
% var = [0.07; 0.3; 0.15]; % for gloss70
% var = [0.06; 0.2; 0.10]; % for gloss80
% var = []; % for gloss90
% var = [0.09; 0.2; 0.15]; % for gloss100

ro_s = ['300:',num2str(var(1)),' 800:',num2str(var(1))];
ro_d = ['300:', num2str(var(2)), ' 800:', num2str(var(1))];
alphau = var(3); % alphau and alphav should always be the same value for isotropic brdf
mycell = {ro_s, ro_d, alphau}

T = cell2table(mycell, 'VariableNames', {'ro_s' 'ro_d' 'alphau'})
writetable(T,'/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/sample_render_Conditions.txt','Delimiter','\t')
%% Rendering bit

% Set preferences
setpref('RenderToolbox3', 'workingFolder', '/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos');

% use this scene and condition file. 
parentSceneFile = 'test_sphere.dae';
% WriteDefaultMappingsFile(parentSceneFile); % After this step you need to edit the mappings file

conditionsFile = 'sample_render_Conditions.txt';
% mappingsFile = 'test_sphere_3params_DefaultMappings.txt';
mappingsFile = 'multispec_3params_DefaultMappings.txt';

% Make sure all illuminants are added to the path. 
addpath(genpath(pwd))

%% Choose batch renderer options.

% hints.imageWidth = 4012;
% hints.imageHeight = 6034;
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
toneMapFactor = 1;
isScale = false;
montageName = sprintf('%s (%s)', 'Test-SphereFit', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);

% load the monochromatic image and display it
imPath = ['/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/', hints.recipeName, '/renderings/Mitsuba/test_sphere-001.mat']
load(imPath, 'multispectralImage');
sampleim = multispectralImage;
max_pixel = max(sampleim(:));
figure;imshow(sampleim(:,:,1))

imtosave = sampleim(:,:,1);

sample_name = ['sample_render', int2str(percent_gloss),'.mat'];
imname = strcat('/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/sample_renders/', sample_name);
save(imname, 'imtosave');
