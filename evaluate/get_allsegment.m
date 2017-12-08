clear;
addpath('../segment/');
dataroot = '/home/zhangyu/data/saliency/';
datasets = dir(dataroot);

seg_map = containers.Map;
for set_iter = 3:length(datasets)
	imgdir = [dataroot datasets(set_iter).name '/images/'];
	imglist = dir([imgdir '*jpg']);
	for img_iter = 1:length(imglist)
		imgname = imglist(img_iter).name;
		im = imread([imgdir imgname]);
		imsegs = im2superpixels( im, 'pedro', [0.5 120 100] );
		imgfullname = [datasets(set_iter).name '-' imgname];
		seg_map(imgfullname) = imsegs;
	end
end

save (['seg_map.mat'],'seg_map', '-v7.3');

