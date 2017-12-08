% Run saliency detection model on nultiple datasets with 
% datasets saved in proper location(modify if you'd like to run)
% And do evaluation
% *Zhang Yu, NWPU, 2017*

roundnumber = 5;
addpath(genpath('/usr/local/caffe-master/matlab/'));
datasets = {'DUT-O','PASCAL-S','BSD','ECSSD','SED1'};%'MSRA10K','DUT-O','PASCAL-S','BSD','ECSSD','SED1','DAVIS'
savePath = ['/disk2/zhangyu/supervision/extern/modelRst/round' num2str(roundnumber) '/'];
% model loop should be outside the dataset loop to save usage of GPU memory 
model_dir = ['/disk2/zhangyu/supervision/extern/snap/round' num2str(roundnumber) '/select/'];
model_list = dir([model_dir '.caffemodel']);
for i = 1:length(model_list);
    caffe.reset_all();
    caffe.set_mode_gpu();
    gpu_id = 1;
    caffe.set_device(gpu_id);
    phase = 'test'; 
    net_model = ['models/supervision_model/SVFSal_deploy.prototxt'];
    modelname = model_list(i).name;
    net_weights = [model_dir modelname];
    net = caffe.Net(net_model, net_weights, phase);
    for j = 1:length(datasets)
        imgdir = strcat('/home/zhangyu/data/saliency/',datasets{j},'/images/');
        tmpdir = [savePath datasets{j} '/'];
        mkdir(tmpdir, model_list(i).name(1:end-11));
        smdir = strcat(tmpdir, model_list(i).name(1:end-11));
        disp(['Get saliency map: ' datasets{j} ' ' model_list(i).name]);
        imglist = dir([imgdir '*.jpg']);
        for idx = 1:length(imglist)
            img = imread([imgdir imglist(idx).name]);
            im = prepare_img(img);
            sm = predict_sm(net,im,size(img,1),size(img,2));
            if ~mod(idx,100)
                disp([num2str(idx) '/' num2str(length(imglist))]);
            end
            imwrite(sm,[smdir '/' imglist(idx).name(1:end-4) '.png']);
        end
    end
end
caffe.reset_all();
% Evalute saliency results
run('evaluate_net.m');


