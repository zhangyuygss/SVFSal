% get saliency maps from trained models 
% modify tmpdir to change dir to save saliency maps
addpath(genpath('/usr/local/caffe-master/matlab'))

datasets = {'DUT-O','bsd','ECSSD','MSRA10K'};

% model loop should be outside the dataset loop, or GPU memory will be running out soon
model_list = dir('../data/snap/*.caffemodel');
for i = 1:length(model_list)
    caffe.reset_all();
    caffe.set_mode_gpu();
    gpu_id = 2;
    caffe.set_device(gpu_id);
    model_dir = '../data/snap/';
    % def_dir = '/home/zhangyu/codes/caffe_codes/saliency-hed/';
    phase = 'test'; % run with phase test (so that dropout isn't applied)
    net_model = ['unsupervised_dhsbased_deploy.prototxt'];
    modelname = model_list(i).name;
    net_weights = [model_dir modelname];
    net = caffe.Net(net_model, net_weights, phase);
    for j = 1:length(datasets)
        imgdir = strcat('/home/zhangyu/data/database/',datasets{j},'/images/');
        tmpdir = ['../data/modelRst/0/' datasets{j} '/'];        %mkdir 2 arguments max
        mkdir(tmpdir, model_list(i).name(1:end-11));
        smdir = strcat(tmpdir, model_list(i).name(1:end-11));
        disp(['Get saliency map: ' datasets{j} ' ' model_list(i).name]);
        imglist = dir([imgdir '*.jpg']);
        for idx = 1:length(imglist)
            img = imread([imgdir imglist(idx).name]);
            im = prepare_img(img);
            mask = im(:,:,1);
            sm = predict_sm(net,im,size(img,1),size(img,2));
            %sm = sm>0.3;
            if ~mod(idx,100)
                disp([num2str(idx) '/' num2str(length(imglist))]);
            end
            imwrite(sm,[smdir '/' imglist(idx).name]);
        end
    end
end
caffe.reset_all();