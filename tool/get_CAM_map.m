% This script is used to get CAM attention maps and object number
% for MSRA10K traning set. The results are used to improve the
% curriculum of our unsupervised saliency detection framwork

addpath('/usr/local/caffe-master/matlab');
CAM_path = '/home/zhangyu/codes/paperCode/CAM/CAM/';
addpath(CAM_path);
img_path = '/disk2/zhangyu/data/saliency_data/MSRA10K/images/';
data_root = '/disk2/zhangyu/supervision/with_CAM/';
map_save_path = [data_root 'at_maps/MSRA10K/'];
mkdir(map_save_path);
gpuID = 3;
topNum = 5;

net_weights = [CAM_path 'models/imagenet_googleletCAM_train_iter_120000.caffemodel'];
net_model = [CAM_path 'models/deploy_googlenetCAM.prototxt'];
net = caffe.Net(net_model, net_weights, 'test'); 
caffe.set_device(gpuID);
weights_LR = net.params('CAM_fc',1).get_data();% get the softmax layer of the network

imgList = dir([img_path '*.jpg']);

std_dic = containers.Map; % map contains image name to topX_prob_std
threshold_dic = containers.Map; % map contains image name to prob_morethan_0.05_number
for idx = 1:length(imgList)
    disp(idx)
	img_name = imgList(idx).name;
	img_name_non_fix = img_name(1:end-4);
	img = imread([img_path img_name]);
	img = imresize(img, [256 256]);
    scores_prob = net.forward({prepare_image(img)});% extract conv features online
    scores_prob = scores_prob{1};
    activation_lastconv = net.blobs('CAM_conv').get_data();
	
    scores_prob_mean = mean(scores_prob, 2);
    [value_category, IDX_category] = sort(scores_prob_mean,'descend');

    std_dic(img_name_non_fix) = std(value_category(1:topNum));
    threshold_dic(img_name_non_fix) = sum(value_category > 0.05);

    % sprintf('Top5 scores: %f %f %f %f %f', value_category(1:5)) 
    % sprintf('Top5 score std: %f', std(value_category(1:5)))
    % sprintf('Object number: %d', sum(value_category > 0))
    [curCAMmapAll] = returnCAMmap(activation_lastconv, weights_LR(:,IDX_category(1:1)));
    cur_map_crops = squeeze(curCAMmapAll(:,:,1,:));
    cur_crops_large = imresize(cur_map_crops, [224, 224]);
    cur_map = mergeTenCrop(cur_crops_large);
    cur_map_gray = mat2gray(cur_map);

    cur_save_path = [map_save_path img_name_non_fix '.png'];
    imwrite(cur_map_gray, cur_save_path);

    % cur_heat_map = map2jpg(cur_map, [], 'jet');
    % figure;
    % subplot(1,2,1); imshow(cur_heat_map);
    % subplot(1,2,2); imshow(img);
end
save([data_root 'scores_dic.mat'], 'std_dic', 'threshold_dic', '-v7.3');

caffe.reset_all();
