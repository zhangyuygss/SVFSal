function local_fusion(roundnumber, selectdir, gen_fullweight, savelocweight, emrst_dir)
	%% gen_fullweight: 1: Add global weight and local weight 2: Add local weight only

    % roundnumber = 5;
	run('./vlfeat-0.9.20/toolbox/vl_setup');
	priorBeta = 1.5;
	% selectdir = ['/disk1/zhangyu/ICCV/selectedSal/round' num2str(roundnumber) '/'];
	mkdir(selectdir);
	imgdir = [selectdir 'img/'];
	subPaths = dir([selectdir 'sal*']);
	labelerNum = length(subPaths);
	saldir = cell(labelerNum, 1);
	for i = 1:length(subPaths)
	    saldir{i} = [selectdir subPaths(i).name '/'];
	end

	imgList = dir([imgdir '*jpg']);
	imgNum = length(imgList);

	Asum = 0;			% Average sum of labeler ability

	% Add weights for every picture and superpixels in it
	loss_weight = containers.Map;
	if(gen_fullweight == 1)
		load([emrst_dir 'globalmap2beta' num2str(roundnumber) '.mat']);
	end
	mkdir([selectdir 'localSal/']);
	for i = 1:imgNum
		imgname = imgList(i).name;
		sals = cell(labelerNum,1);
		for ii = 1:labelerNum
			sals{ii} = imread([saldir{ii} imgname(1:end-4) '.png']);
		end
		im = imread([imgdir imgname]);

		[localSal, betas, labelerStats]= local_em(im, sals, priorBeta);

		% % attention map weight
		% at_map = imread([atMapDir, imgname(1:end-4), '.png']);
		% [h, w, ch] = size(im);
		% at_map = mat2gray(imresize(at_map, [h, w]));
		% betas = addCAMLocWeight(at_map, betas);

		labeler = labelerStats{2};
		Asum = Asum + mean(labeler);

		imwrite(localSal, [selectdir 'localSal/' imgname(1:end-4) '.png']);
		% modify it 
		if(gen_fullweight == 1)
			glb_weight = globalmap2beta([imgname(1:end-4)]);				
			betas = betas*glb_weight;
		end
		betas = mat2gray(betas) + 0.01;  % Normalize, avoid zero weights
		loss_weight([imgname(1:end-4)]) = betas;
	end

	disp(['Sum of labeler ability--round' num2str(roundnumber)]);
	Asum = Asum/imgNum
	if(savelocweight == 1)
		save ([emrst_dir 'loss_weight' num2str(roundnumber) '.mat'], 'loss_weight', '-v7.3');
	end
	save ([emrst_dir 'local_alpha' num2str(roundnumber) '.mat'],'Asum', '-v7.3');
end



