% Convert saliency maps to masks using grabcut, masks will be used later to train CNN
function saliency2mask(roundnumber, imgdir, saldir, maskdir)
	%% saldir: Directory of saliency map
	%% maskdir: Directoey to save binaried maps
	%% imgdir: Directory of images of saliency maps

	% % addpath('../grabcut');
	% savePath = ['/disk1/zhangyu/ICCV/selectedSal/round' num2str(roundnumber) '/'];
	% % imgdir = [savePath 'img/'];
	% saldir_loc = [savePath 'localSal/'];
	% saldir_glb = [savePath 'globSal/'];
	% % saldir_mean = [savePath 'meanSal/'];
	% locSavedir = [savePath 'mask_loc/'];
	% % maskdir = [savePath 'mask_mean/'];

	% mkdir(locSavedir);
	rmpath(genpath('../vlfeat-0.9.20'));
	mkdir(maskdir);

	imgList = dir([imgdir '*jpg']);
	maxIterations = 3;
	for i = 1:length(imgList)
		if(~mod(i,200))
			disp(i);
		end
		im = imread([imgdir imgList(i).name]);
		% locSal = im2double(imread([saldir_loc imgList(i).name]));
		% threshold = graythresh(locSal);
		% % 有些图会有问题，threshold会出现0无法继续，这里continue跳过去
		% if(threshold==0)
		% 	continue;
		% end
		% loc_mask = st_segment(im, locSal, threshold, maxIterations);
		% imwrite(loc_mask, [locSavedir imgList(i).name]);
		imgname = imgList(i).name;
		sal = im2double(imread([saldir imgname(1:end-4) '.png']));
		threshold = graythresh(sal);
		mask = st_segment_modif2(im, sal, threshold, maxIterations);
		imwrite(mask, [maskdir imgname(1:end-4) '.png']);
	end
	
	addpath(genpath('../vlfeat-0.9.20'));

	% 调用数据增强函数
	% maskpath_save = ['/disk1/zhangyu/ICCV/masks/round' num2str(roundnumber) 'glb/mask224/'];
	% mkdir(maskpath_save);
	% data_enhance(saldir_glb,maskpath_save,roundnumber);
	
	% maskpath_save = ['/disk1/zhangyu/ICCV/masks/round' num2str(roundnumber) 'loc/mask224/'];
	% mkdir(maskpath_save);
	% data_enhance(saldir_loc,maskpath_save,roundnumber);
	% maskpath_save = ['../data/masks/round' num2str(roundnumber) '/mask224loc/'];
	% mkdir(maskpath_save);
	% data_enhance(locSavedir,maskpath_save,roundnumber);

	% run('resize_img.m');
	% run('separateh5_2.m');


	% 找出对应 ground truth
	% gtdir = '../data/MSRA10K/GT/';
	% gtsavedir = '../data/selectedSal/gt/';
	% maskList = dir(['../data/selectedSal/mask_glb/*jpg']);
	% for i = 1:length(maskList)
	% 	gtruth = imread([gtdir maskList(i).name(1:end-4) '.png']);
	% 	imwrite(gtruth, [gtsavedir maskList(i).name]);
	% end

	% mkdir('../data/gt/');
	% maskpath_save = '../data/gt/';
	% mkdir(maskpath_save);
	% data_enhance(gtsavedir,maskpath_save);
end
