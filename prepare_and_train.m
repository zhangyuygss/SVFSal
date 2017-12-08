% This script contains the training procedure of our
% supervision by fusion saliency detection framework.
% It's not recommend to run this script since there are plenty
% of directories to modify. 
% But if you would like to run it, be free to ask me if you've
% got any question.
% *Zhang Yu, NWPU, 2017*

clear;
addpath(genpath('./'));
modelnum = 3;
roundnumber = 5;
use_means = [1, 1, 0, 0, 0];
use_mean = use_means(roundnumber)
big_glbs = [1, 1, 1, 0, 0]; 
big_glb = big_glbs(roundnumber)
selectRates = [0.35, 0.38, 0.44, 0.52, 0.62];
selectRate = selectRates(roundnumber)
trDataset = 'MSRA10K';
disp(['roundnumber: ' num2str(roundnumber)]);
rootpath_pre =  ['/disk2/zhangyu/supervision/extern/'];
rootpath =  ['/disk2/zhangyu/supervision/with_CAM/'];
CAM_wt = [rootpath 'scores_dic.mat'];
atMapDir = [rootpath 'at_maps/MSRA10K/'];
salsrootdir = [rootpath_pre 'saliencys/round' num2str(roundnumber) '/'];
emrst_dir = [rootpath 'EmRst/round' num2str(roundnumber) '/'];
disp('Running global em...')
    global_em(roundnumber, salsrootdir, emrst_dir, modelnum);
selectdir = [rootpath 'selectedSal/round' num2str(roundnumber) '/' ];
tr_img = ['/disk2/zhangyu/data/saliency/' trDataset '/images/'];
disp('Running global select...');
    global_slct(roundnumber, selectRate, selectdir, salsrootdir, emrst_dir, CAM_wt, tr_img);
disp('Running local fusion...');
    local_fusion(roundnumber, selectdir, atMapDir, 1, 1, emrst_dir);

select_imgdir = [selectdir 'img/'];
select_maskdir = [selectdir 'mask/']; mkdir(select_maskdir);
mean_saldir = [selectdir 'meanSal/'];

disp('Running data_enhance...');
enhanced_maskdir = [rootpath 'masks/round' num2str(roundnumber) '/mask224/'];
genweight = 1;
weightpath = [emrst_dir 'loss_weight' num2str(roundnumber) '.mat'];
maskpath = [rootpath 'masks/round' num2str(roundnumber) '/'];
disp('Fusing global and local saliencys...');
    mean_img(selectdir, atMapDir, mean_saldir);
if(use_mean)
    data_enhance(select_imgdir, mean_saldir, ...
        enhanced_maskdir, genweight, weightpath, maskpath, trDataset);
else
    disp('Running saliency2mask...');
    % remove vlfeat path for matlab kmeans instead of vlfeat kmeans in grabcut
    rmpath(genpath('./vlfeat-0.9.20')); 
    saliency2mask(roundnumber, select_imgdir, mean_saldir, select_maskdir);
    data_enhance(select_imgdir, select_maskdir, ...
        enhanced_maskdir, genweight, weightpath, maskpath, trDataset);
end
disp('Running resize image...');
    resize_img(maskpath);
selected_number = length(dir([select_imgdir '*.jpg']));
disp('Running separateh5...');      
    separateh5([maskpath 'weight/'], selected_number);

disp('Running convert image...');
mkdir([rootpath 'leveldb/round' num2str(roundnumber) '/'])
system(['sh ./tool/convert_image.sh ' rootpath 'masks/round' num2str(roundnumber) ...
    '/ ' rootpath 'leveldb/round' num2str(roundnumber) '/']);
mkdir([rootpath 'snap/round' num2str(roundnumber) '/']);
mkdir([rootpath 'log/']);

disp('training');
train_str = ['sh ./models/supervision_model/train.sh ' rootpath 'log/' ' tr_with_CAM_wt']
system(train_str);


