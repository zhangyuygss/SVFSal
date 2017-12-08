clear;
imgDir = '/home/zhangyu/disk1Link/supervisionPAMI/saliencys/round1/HS/';
imgList = dir([imgDir '*.png']);
for idx = 1:length(imgList)
	imgName = imgList(idx).name;
	im = imread([imgDir imgName]);
	imwrite(im, [imgDir imgName(1:end-8) '.png']);
end
