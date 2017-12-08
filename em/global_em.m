function global_em(roundnumber, salsrootdir, rstsavedir, modelnum)
    %% salsrootdir: directory of different saliency maps
    %% rstsavedir: diretory to save global em result
    % roundnumber = 6;
    % savedir = ['/disk1/zhangyu/ICCV/EmRst/'];
    savedir = rstsavedir;
    if(~exist(savedir))
        mkdir(savedir);
    end
    % salpath = ['../data/saliency/saliency' num2str(roundnumber) '/'];
    salpath = salsrootdir;
    % modelnum = 3;               % labeler number
    subpaths = dir([salpath]);
    imglist = cell(modelnum ,1);
    for i = 3:length(subpaths)
        imglist{i-2} = dir([salpath subpaths(i).name '/*.png']);
    end
    salnum = length(imglist{1});        % img number
    priorBeta = 1.5;

    ASM = cell(salnum, 1);
    DSM = zeros(salnum, modelnum);
    for i = 1:salnum
        imgs = cell(modelnum, 1);
        for ii = 3:length(subpaths)
            tmp = imread([salpath subpaths(ii).name '/' imglist{ii-2}(i).name]);
            imgs{ii-2} = im2double(tmp);
            if(ii==3)
                ASM{i} = imgs{ii-2};        % 初始赋值
            else
                ASM{i} = ASM{i} + imgs{ii-2};
            end
        end
        clear tmp ii;
        % average saliency map
        ASM{i} = ASM{i}/modelnum;

        % distances to ASM of three different model(labeler)
        tmpsumden = sum(sum(ASM{i}));
        for ii = 1:modelnum
            tmp = abs(imgs{ii} - ASM{i});
            tmpsumnum = sum(sum(tmp));
            DSM(i,ii) = tmpsumnum/tmpsumden;
        end
    end

    % thresholding
    threshold = sum(sum(DSM))/(salnum*modelnum);

    % configure labels 
    labels = zeros(salnum, modelnum);
    % parameter preparation
    labeleridx = zeros(salnum*modelnum, 1);
    imgidx = zeros(salnum*modelnum, 1);
    given_labels = zeros(salnum*modelnum, 1);
    idx = 1;
    for i = 1:salnum
        for j = 1:modelnum
            labels(i,j) = DSM(i,j)<=threshold;
            given_labels(idx) = labels(i,j);
            labeleridx(idx) = j;
            imgidx(idx) = i;
            idx = idx+ 1;
        end
    end

    % prior p_z
    % 目前最好的结果出现在使用下面简单的P_Z先验概率, 使用统一的priorBeta, 
    P_Z1 = zeros(salnum,1);
    % priorBeta = P_Z1;
    for i = 1:(salnum)
        % if(labels(i,1)==labels(i,2) & labels(i,2)==labels(i,3))
        %     P_Z1(i) = sum(DSM(1,:))/3;
        %     % priorBeta(i) = max(P_Z1(i), 1-P_Z1(i)) + 0.5;
        % else
        %     if(sum(labels(i,:))==2)
        %         tmpsum = 0;
        %         for ii = 1:3
        %             if(DSM(i,ii)<=threshold)
        %                 tmpsum = tmpsum + DSM(i,ii);
        %             end
        %         end
        %         P_Z1(i) = tmpsum/2;
        %         % priorBeta(i) = min(P_Z1(i), 1-P_Z1(i))+0.2;
        %     else
        %         tmpsum = 0;
        %         for ii = 1:3
        %             if(DSM(i,ii)>threshold)
        %                 tmpsum = tmpsum + DSM(i,ii);
        %             end
        %         end
        %         P_Z1(i) = tmpsum/2;
        %         % priorBeta(i) = min(P_Z1(i), 1-P_Z1(i))+0.2;
        %     end
        % end
        thisLabels = labels(i,:);
        trueLbNum = sum(thisLabels);
        trueLbPos = find(thisLabels == 1);
        falseLbNum = modelnum - trueLbNum;
        falseLbPos = find(thisLabels == 0);
        if(trueLbNum > falseLbNum)
            P_Z1(i) = sum(DSM(i, trueLbPos))/trueLbNum;
        elseif falseLbNum > trueLbNum
            P_Z1(i) = sum(DSM(i, falseLbPos))/falseLbNum;
        else
            P_Z1(i) = sum(DSM(i,:))/modelnum;
        end
    end

    % 防止em函数出现错误，有大于1的值时会这样。
    tmpfact = max(P_Z1);
    for j = 1:salnum
        P_Z1(j) = P_Z1(j)/(tmpfact+0.1);
        P_Z1(j) = 1 - P_Z1(j);
    end

    [ imageStats, labelerStats ] = em(imgidx, labeleridx, given_labels, P_Z1, 1, priorBeta);

    % if(exist('globalEmResult2.mat','file')>=0)
    %     delete('globalEmResult2.mat');
    % end

    worstmodel = subpaths(find(labelerStats{2} == min(labelerStats{2})) + 2).name;
    disp(['Global fusion worst model:' worstmodel]);

    save([savedir 'globalEmResult' num2str(roundnumber) '.mat'], '-v7.3');
    % save([savedir 'globalworst' num2str(roundnumber) '.mat'], 'worstmodel', '-v7.3');
end
