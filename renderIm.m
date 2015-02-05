%fitting brdf to images
% gloss70 = imread('DSC_0111_70gloss.pgm');
% black = imread('DSC_0112.pgm');
% 
% imshow(gloss70)
% 
% gloss70_residual = gloss70-black';

% Idea: I might be able to store the params in an array and write them into
% the conditions file at each iteration - take a look at this
function renderIm(ro_s, ro_d, lightColor)

% params = [ro_s, ro_d, lightColor];
params = [1 2 3];%test
paramName = ['ro_s' 'ro_d' 'lightColor'];

% dlmwrite('test_sphere2Conditions.txt',paramName, 'newline', 'unix')
dlmwrite('test_sphere2Conditions.txt',params,'-append','delimiter',' ')
type('test_sphere2Conditions.txt')

%% to write new conditions file with replaced params
% % open files
% fidIn = fopen('test.txt');
% fidOut = fopen('test2.txt','w');
% 
% % read in file
% tline = fgets(fidIn);
% index = 1; 
% while ischar(tline)
%     data{index} = tline;     
%     tline = fgets(fid);         
%     index = index + 1;
% end
% 
% % replace first row
% data{1,1} = 'Something else';
% 
% % write to second file
% for l = data
%     fprintf(fidOut,'%s\n', l{1,1});
% end
% 
% fclose(fidIn);
% fclose(fidOut);
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

% hints.imageWidth = 4012/2;
% hints.imageHeight = 6034/2;
hints.imageWidth = 600;% these are for quick rendering
hints.imageHeight = 800;
hints.renderer = 'Mitsuba';
datetime=datestr(now);
datetime=strrep(datetime,':','_'); %Replace colon with underscore
datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
datetime=strrep(datetime,' ','_');%Replace space with underscore
hints.recipeName = ['Test-SphereFit' datetime];


ChangeToWorkingFolder(hints);

nativeSceneFiles = MakeSceneFiles(parentSceneFile, '', mappingsFile, hints);
% nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);

%comment all this out
toneMapFactor = 10;
isScale = true;
montageName = sprintf('%s (%s)', 'Test-SphereFit', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
% ShowXYZAndSRGB([], SRGBMontage, montageName);

% imwrite(SRGBMontage, 'test_rendered70.png','BitDepth',16);

%% Convert spectral image to sRGB:
S = [400 10 31];
[sRGBImage, XYZImage, rawRGBImage] = MultispectralToSRGB(multispectralImage, S, toneMapFactor, isScale);
ShowXYZAndSRGB([], sRGBImage)

gray70 = rgb2gray(sRGBImage);
imshow(gray70)

