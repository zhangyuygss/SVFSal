% Run this demo to generate saliency maps using our caffe model
% Zhang Yu, NWPU, 2017
% Make sure you've installed caffe and matcaffe and set your path below
% and downloaded our pretrained caffemodel file

addpath(genpath('/your/path/caffe-master/matlab/'));
addpath(genpath('./'));
imgDir = 'data/images/';
modelDef = 'models/supervision_model/SVFSal_deploy.prototxt';
weigthDir = 'data/SVFSal_round5_iter_34500.caffemodel';
phase = 'test';
gpuID = 0; % Set gpuID to your GPU number if you want to run with GPU

% Set caffe
caffe.reset_all();
if gpuID >= 0
	caffe.set_mode_gpu();
	caffe.set_device(gpuID);
else
	caffe.set_mode_cpu();
end
net = caffe.Net(modelDef, weigthDir, phase);

% Predict saliency maps
imgList = dir([imgDir '*.jpg']);
for idx = 1:length(imgList)
	disp(['Processing image: ' num2str(idx) '/' num2str(length(imgList))]);
	imgName = imgList(idx).name;
	img = imread([imgDir imgName]);
	[h, w, ch] = size(img);
	img = prepare_img(img);
	saliency = predict_sm(net, img, h, w);
	imwrite(saliency, ['data/output/' imgName(1:end-4) '.png']);
end

caffe.reset_all();
