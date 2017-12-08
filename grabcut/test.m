%% Test file for evaluating the proper form of modified grabcut
addpath(genpath('../'));
rmpath(genpath('../vlfeat-0.9.20'));
picRoot = '/disk2/zhangyu/supervisionPAMI1/selectedSal/round6/';
savePath = 'rst/';
imgPath = fullfile(picRoot, 'img/');
sal1Path = fullfile(picRoot, 'meanSal/');
sal2Path = fullfile(picRoot, 'sal2');

prePath = fullfile(picRoot, 'mask0/');
motionPath2 = fullfile(picRoot, 'mask_motion/');
motionPath = fullfile(picRoot, 'mask');

% sal1Path = [picRoot 'sal1/'];
dataSet = 'DAVIS';
datadir = '/home/zhangyu/data/saliency/';
maskPath=[datadir dataSet '/GT/'];
ext = '.png';
% imgPath = [datadir dataSet '/images/'];

original = fullfile(savePath, 'original'); mkdir(original);
modif2Savesal2 = fullfile(savePath, 'modif2Savesal2'); mkdir(modif2Savesal2);
modif2Savemean = fullfile(savePath, 'modif2Savemean_no_eng_init'); mkdir(modif2Savemean);
modif2mask2 = fullfile(savePath, 'modif2mask2'); mkdir(modif2mask2);
modif2mask2_2 = fullfile(savePath, 'modif2mask2_2'); mkdir(modif2mask2_2);


imList = dir(fullfile(sal1Path, '*png'));
% for idx = 2836:length(imList)
% 	disp(idx)
% 	imgName = imList(idx).name;
% 	im = im2double(imread(fullfile(imgPath, [imgName(1:end-4), '.jpg'])));
% 	sal1 = im2double(imread(fullfile(sal1Path, [imgName(1:end-4), '.png']))); 
% 	threshold_sal1 = graythresh(sal1);
% 	% sal2 = im2double(imread(fullfile(sal2Path, [imgName(1:end-4), '.png'])));
% 	% threshold_sal2 = graythresh(sal2);

% 	% meanSal = mat2gray(sal1+sal2);
% 	% threshold_mean = graythresh(meanSal);


% 	seg1 = st_segment(im, sal1, threshold_sal1, 3);
% 	imwrite(seg1, fullfile(original, [imgName(1:end-4), '.png']));
% 	% seg2 = st_segment_modif2(im, sal2, threshold_sal2, 4);
% 	% imwrite(seg2, fullfile(modif2Savesal2, [imgName(1:end-4), '.png']));
% 	% seg3 = st_segment_modif2(im, meanSal, threshold_mean, 4);
% 	% imwrite(seg3, fullfile(modif2Savemean, [imgName(1:end-4), '.png']));
% 	% seg4 = st_segment2mask(im,sal1, sal2,threshold_sal1, threshold_sal2, 4);
% 	% imwrite(seg4, fullfile(modif2mask2, [imgName(1:end-4), '.png']));
% 	% seg5 = st_segment2mask_2(im,sal1, sal2,threshold_sal1, threshold_sal2, 4);
% 	% imwrite(seg5, fullfile(modif2mask2_2, [imgName(1:end-4), '.png']));
% end

per_sal0 = evaluate_SO(dataSet, imgPath, maskPath, motionPath2, ext)
per_sal1 = evaluate_SO(dataSet, imgPath, maskPath, prePath, ext)
% modif = [picRoot 'mask/'];
per_sal2 = evaluate_SO(dataSet, imgPath, maskPath, motionPath, ext)
% perf_orig = evaluate_SO(dataSet, imgPath, maskPath, modif2Savemean, ext)
% perf_modify = evaluate_SO(dataSet, imgPath, maskPath, modif2mask2, ext)
% per_sal2 = evaluate_SO(dataSet, imgPath, maskPath, modif2mask2_2, ext)
