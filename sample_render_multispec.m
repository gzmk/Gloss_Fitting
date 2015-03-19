% Render sample spheres for each gloss level photo
function sample_render_result = sample_render(percent_gloss)
%% first let's read all the pgm images
% gloss0 = imread();
gloss10 = imread('DSC_0107_10gloss.pgm','pgm');
gloss20 = imread('DSC_0106_20gloss.pgm','pgm');
gloss30 = imread('DSC_0103_30gloss.pgm','pgm');
gloss40 = imread('DSC_0102_40gloss.pgm','pgm');
gloss50 = imread('DSC_0104_50gloss.pgm','pgm');
gloss60 = imread('DSC_0105_60gloss.pgm','pgm');
gloss70 = imread('DSC_0111_70gloss.pgm','pgm');
gloss80 = imread('DSC_0110_80gloss.pgm','pgm');
% gloss90 = imread('DSC_0107_10gloss.pgm','pgm');
gloss100 = imread('DSC_0109_100gloss.pgm','pgm');

%%
% var = [0; 0; 0]; % for gloss0
% var = [0.04; 0.2; 0.3]; % for gloss10
% var = [0.03; 0.3; 0.18]; % for gloss20
% var = [0.05; 0.25; 0.2]; % for gloss30
var = [0.4; 0.6; 0.2]; % for gloss40 
% var = [0.06; 0.2; 0.15]; % for gloss50
% var = [0.06; 0.2; 0.15]; % for gloss60
% var = [0.07; 0.3; 0.15]; % for gloss70
% var = [0.06; 0.2; 0.10]; % for gloss80
% var = []; % for gloss90
% var = [0.09; 0.2; 0.15]; % for gloss100

ro_s = var(1);
ro_d = var(2);
alphau = var(3); % alphau and alphav should always be the same value for isotropic brdf

T = table(ro_s,ro_d, alphau);
writetable(T,'/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/sample_render_Conditions.txt','Delimiter','\t')
%% Rendering bit

% Set preferences
setpref('RenderToolbox3', 'workingFolder', '/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos');

% use this scene and condition file. 
parentSceneFile = 'test_sphere.dae';
% WriteDefaultMappingsFile(parentSceneFile); % After this step you need to edit the mappings file

conditionsFile = 'sample_render_Conditions.txt';
mappingsFile = 'test_sphere_3params_DefaultMappings.txt';

% Make sure all illuminants are added to the path. 
addpath(genpath(pwd))

%% Choose batch renderer options.

% hints.imageWidth = 4012;
% hints.imageHeight = 6034;
hints.imageWidth = 600;% these are for quick rendering
hints.imageHeight = 800;
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
sampleim = multispectralImage;
imshow(sampleim)

percent_gloss = 40;
sample_name = ['sample_render', int2str(percent_gloss),'.pgm'];
imname = ['/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/', sample_name];
imwrite(sampleim, imname,'pgm');
