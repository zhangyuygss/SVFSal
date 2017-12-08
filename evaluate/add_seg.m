clear;
addpath('../segment/');
dataroot = '/home/zhangyu/data/saliency/';
datasetName = 'DAVIS';
dataset = [dataroot datasetName '/'];

load('seg_map.mat');
imgdir = [dataset '/images/'];
imglist = dir([imgdir '*jpg']);
for img_iter = 1:length(imglist)
	imgname = imglist(img_iter).name;
	im = imread([imgdir imgname]);
	imsegs = im2superpixels( im, 'pedro', [0.5 120 100] );
	imgfullname = [datasetName '-' imgname];
	seg_map(imgfullname) = imsegs;
end


save (['seg_map1.mat'],'seg_map', '-v7.3');

