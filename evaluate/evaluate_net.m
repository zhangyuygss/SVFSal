% Do evaluation on saliency detection results
% Metric including 'AUC','AP','Fm','MAE','SOV'
% *Zhang Yu, NWPU, 2017*

clear;
roundnumber = 5;
addpath('../evaluate/');
save_path = ['/disk2/zhangyu/supervision/extern/performance/round' num2str(roundnumber) '/'];
mkdir(save_path);
datadir = '/home/zhangyu/data/saliency/';
datasets={'MSRA10K','DUT-O','PASCAL-S','BSD','ECSSD'};%'BSD','ECSSD','MSRA10K','DUT-O','PASCAL-S''SED1',
salMapRootDir=['/disk2/zhangyu/supervision/extern/modelRst/round' num2str(roundnumber) '/'];
model_dir = ['/disk2/zhangyu/supervision/extern/snap/round' num2str(roundnumber) '/select/'];
model_list = dir([model_dir '*.caffemodel']);
allModel = cell(length(model_list), 1);
for i = 1:length(model_list)
    allModel{i} = model_list(i).name(1:end-11);
end
ext='.png';
perfWrite={'AUC','AP','Fm','MAE','SOV'};
for datasetIdx=1:length(datasets)
    results=[];
    datasetName=datasets{datasetIdx};
    disp(datasetName);
    mkdir([save_path datasetName]);
    maskPath=[datadir datasets{datasetIdx} '/GT/'];
    imgPath = [datadir datasets{datasetIdx} '/images/'];
    for modelIdx=1:length(allModel)
        modelName=allModel{modelIdx};
        disp(modelName);
        results(modelIdx).modelName=modelName;
        salMapDir=[salMapRootDir datasetName '/' modelName];
        if exist(salMapDir,'dir')==7 && length(dir(salMapDir))>10
            Performance=evaluate_SO(datasetName, imgPath, maskPath,salMapDir,ext);
            results(modelIdx).Performance=Performance;
        else
            results(modelIdx).Performance=[];
        end
        
    end
    save([save_path '/' datasetName '/' datasetName  '_results.mat'],'results');

    % plotFigure(datasetName,allModel,results);
    fid=fopen([save_path '/' datasetName '/' datasetName '_results.txt'],'a+');
    for modelIdx= 1:length(allModel)
        fprintf(fid, '%s', [allModel{modelIdx} ':  ']);
        for i=1:length(perfWrite)
            if ~isempty(results(modelIdx).Performance)
                eval(['fprintf(fid,''%.4f  '', results(modelIdx).Performance.' perfWrite{i} ');']);
            else
                fprintf(fid,'%.4f  ', 0);
            end
        end
        fprintf(fid,'\r\n');
    end
    fclose(fid);   
end

rmpath('../evaluate/');




