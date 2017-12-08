%% do glad for every superpixel in image im
% Input: RGB image im; Different saliency maps of im, priorBeta
% Output: saliency map from local glad

function[salRst, betas, labelerStats] = local_em(im, sals, priorBeta)

    height = size(im,1);
    width = size(im,2);
    paras.theta =15;
    paras.alpha = 0.99;
    paras.gamma =3;
    % addpath('../segment/');
    % addpath('localfuc/');
    labelerNum = length(sals);

    for i = 1:labelerNum
        sals{i} = im2double(sals{i});
    end

    imsegs = im2superpixels( im, 'pedro', [0.5 120 100] );
    segments = imsegs.segimage;
    regions = regionprops(segments, 'PixelIdxList');
    regionNum = length(regions);    
    pixelList = cell(regionNum,1);
    for i = 1:regionNum
       pixelList{i} = regions(i).PixelIdxList;
    end

    ASM = cell(regionNum, 1);
    DSM = zeros(regionNum, labelerNum);
    for i = 1:regionNum
        pixels = cell(labelerNum, 1);
        for ii = 1:labelerNum
            pixels{ii} = sals{ii}(pixelList{i});
            if(ii==1)
                ASM{i} = pixels{ii};        % 初始赋值
            else
                ASM{i} = ASM{i} + pixels{ii};
            end
        end
        % average saliency map
        ASM{i} = ASM{i}/labelerNum;

        % distances to ASM of three different model(labeler)
        tmpsumden = sum(ASM{i});
        if(tmpsumden==0)            % 防止除以0出现NaN
            DSM(i,:) = 0;
        else
            for ii = 1:labelerNum
                tmp = abs(pixels{ii} - ASM{i});
                tmpsumnum = sum(tmp);
                DSM(i,ii) = tmpsumnum/tmpsumden;
            end
        end
    end

    % thresholding
    threshold = sum(sum(DSM))/(regionNum*labelerNum);

    % configure labels 
    labels = zeros(regionNum, labelerNum);
    % parameter preparation
    labeleridx = zeros(regionNum*labelerNum ,1);
    regionidx = zeros(regionNum*labelerNum, 1);
    given_labels = zeros(regionNum*labelerNum, 1);
    idx = 1;
    for i = 1:regionNum
        for j = 1:labelerNum
            labels(i,j) = DSM(i,j)<=threshold;
            given_labels(idx) = labels(i,j);
            labeleridx(idx) = j;
            regionidx(idx) = i;
            idx = idx+ 1;
        end
    end

    P_Z1 = zeros(regionNum,1);
    for i = 1:(regionNum)
        thisLabels = labels(i,:);
        trueLbNum = sum(thisLabels);
        trueLbPos = find(thisLabels == 1);
        falseLbNum = labelerNum - trueLbNum;
        falseLbPos = find(thisLabels == 0);
        if(trueLbNum > falseLbNum)
            P_Z1(i) = sum(DSM(i, trueLbPos))/trueLbNum;
        elseif falseLbNum > trueLbNum
            P_Z1(i) = sum(DSM(i, falseLbPos))/falseLbNum;
        else
            P_Z1(i) = sum(DSM(i,:))/labelerNum;
        end
    end 

    % 防止em函数出现段错误，有大于1的值时会这样。
    tmpfact = max(P_Z1);
    for j = 1:regionNum
        P_Z1(j) = P_Z1(j)/(tmpfact+0.1);
        % divided by 1.1 in case of too many one
        P_Z1(j) = (1 - P_Z1(j))/1.1;  
    end

    [regionStats, labelerStats] = em(regionidx, ...
        labeleridx, given_labels, P_Z1, 1, priorBeta);

    salRst = zeros(height, width);
    betas = salRst;
    labeler = labelerStats{2};
    difficulty = regionStats{3};
    % 处理标签能力
    for ii = 1:labelerNum
        if(labeler(ii) < 0)
            labeler(ii) = 0;
        end
    end
    if(sum(labeler) == 0) % All labelers are negetive
        labeler = 1./abs(labelerStats{2});
    end 
    for i = 1:regionNum
        for jj = 1:labelerNum
            if(jj == 1)
                regionVal = (labeler(jj)/sum(labeler))*...
                            sals{jj}(pixelList{i});
            else
                regionVal = regionVal + ...
                    (labeler(jj)/sum(labeler))*...
                    sals{jj}(pixelList{i});
            end
        end
        salRst(pixelList{i}) = regionVal;
        betas(pixelList{i}) = difficulty(i);
    end
end

