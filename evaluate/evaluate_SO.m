function Performance = evaluate_SO(datasetName, imgPath,maskPath,salMapDir,ext)
% Get metics of saliency results from fold
    addpath('../segment/');
    NT=100; %有多少级灰度阈值

    sms=dir([salMapDir '/*' ext]);
    imgNum=length(sms);
    
    TPR=zeros(imgNum,NT);
    FPR=TPR;
    Pre=TPR;
    allFm=TPR;
%     AUC=zeros(imgNum,1);
%     AP=AUC;
    TPR1=zeros(imgNum,1);
    Pre1=TPR1;
    MAE = TPR1;
    SOV = TPR1;
    Fm=TPR1;
    
    wTPR=TPR1;
    wPre=TPR1;
    wFm=TPR1;
    load('/disk2/zhangyu/supervision/seg_map.mat');
    %parfor i=1:imgNum
    for i=1:imgNum
        %disp(i/imgNum)
        im = imread([imgPath sms(i).name(1:end-4) '.jpg']);
        imname = [sms(i).name(1:end-4) '.jpg'];
        sm=mat2gray(imread([salMapDir '/' sms(i).name]));
        threshold = mean2(sm);
        binarysm = sm >= threshold;
        gt = imread([maskPath  sms(i).name(1:end-4) '.png']);
        [TPR(i,:), FPR(i,:), Pre(i,:), ~, ~, allFm(i,:)] = QXL_ROC( sm, gt, NT );
        [TPR1(i,:), Pre1(i,:), Fm(i,:)] = Fmeasure( sm, gt );
        MAE(i,:) = get_mae(gt, binarysm);
        setname_imname = [datasetName '-' imname];
        % if(datasetName(1:3) == 'BSD')
        %     setname_imname = ['bsd' setname_imname(4:end)];
        % end
        imgseg = seg_map(setname_imname);
        SOV(i,:) = seg_overlap(imgseg, im, sm, gt);
        % [wFm(i,:),wPre(i,:),wTPR(i,:),]= WFb(sm,logical(gt));
    end
    
    % Remove NaN
    Fm = Fm(~any(isnan(Fm), 2), :);
    TPR = TPR(~any(isnan(TPR), 2), :);
    FPR = FPR(~any(isnan(FPR), 2), :);

    Performance.TPR=mean(TPR,1);
    Performance.FPR=mean(FPR,1);
    Performance.Pre=mean(Pre,1);

    Performance.AUC = -trapz([1,Performance.FPR,0], [1,Performance.TPR,0]);
    Performance.AP = -trapz([1,Performance.TPR,0], [0,Performance.Pre,1]);
    
    Performance.allFm=mean(allFm,1);

    Performance.Pre1=mean(Pre1);
    Performance.TPR1=mean(TPR1);
    Performance.Fm=mean(Fm);
    
    Performance.wPre=mean(wPre);
    Performance.wTPR=mean(wTPR);
    Performance.wFm=mean(wFm);

    Performance.MAE = mean(MAE);
    Performance.SOV = mean(SOV);

    rmpath('../segment/');
