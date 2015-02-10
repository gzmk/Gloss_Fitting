%fitting brdf to images

% Idea: I might be able to store the params in an array and write them into
% the conditions file at each iteration - take a look at this
function costIm = renderIm(var)

% titles of the parameters in the Conditions File
param1 = 'ro_s'; 
param2 = 'ro_d';
param3 = 'lightColor';

sprintf('The new variables are: ro_s: %f ro_d: %f lightColor: %f', var(1), var(2), var(3))

% these are going to be passed by the function
ro_s = var(1);
ro_d = var(2);
lightColor = var(3);
%% to write new conditions file with replaced params - always need to start with an initial conditions file
% % open files
fidIn = fopen('test_sphereConditions.txt','r');

% read in file
tline = fgets(fidIn);% gets the title line so skip it
tline = fgets(fidIn);% this is the line we want to replace with the params
index = 1; 
params_line{index} = tline

fclose(fidIn);
% replace first row
str_params = sprintf('%.2f\t%.2f\t%.2f\t',ro_s, ro_d, lightColor);
params_line{1,1} = str_params

fidOut = fopen('test_sphereConditions.txt','w');
str_title = sprintf('%s\t%s\t%s\t', param1, param2, param3)
% write to second file
fprintf(fidOut, '%s\n', str_title)
fprintf(fidOut,'%s\n', params_line{1,1});


fclose(fidOut);
%% Rendering bit

% Set preferences
setpref('RenderToolbox3', 'workingFolder', '/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos');

% use this scene and condition file. 
parentSceneFile = 'test_sphere.dae';
% WriteDefaultMappingsFile(parentSceneFile); % After this step you need to edit the mappings file

conditionsFile = 'test_sphereConditions.txt';
mappingsFile = 'test_sphereDefaultMappings.txt';

% Make sure all illuminants are added to the path. 
addpath(genpath(pwd))

%% Choose batch renderer options.

hints.imageWidth = 4012;
hints.imageHeight = 6034;
% hints.imageWidth = 600;% these are for quick rendering
% hints.imageHeight = 800;
hints.renderer = 'Mitsuba';

datetime=datestr(now);
datetime=strrep(datetime,':','_'); %Replace colon with underscore
datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
datetime=strrep(datetime,' ','_');%Replace space with underscore
hints.recipeName = ['Test-SphereFit' datetime];

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
im2 = im2uint16(multispectralImage);

%% calculate the ssd (error) between two images
gloss70 = imread('DSC_0111_70gloss.pgm');

ssd = 0
for i = 1:hints.imageHeight
    for j = 1:hints.imageWidth
        diff = gloss70(i,j) - im2(i,j);
        ssd = ssd + diff^2;
    end
end
costIm = ssd;
