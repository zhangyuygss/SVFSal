%% 从global em的结果中选择难度较低的图像做下次训练用
function global_slct(roundnumber, select_rate, savePath, salpath, emrst_dir, CAM_wt, imgPath)
	%% savePath: directory to save selected pictures
	%% salpath: Original saliency maps to be selected
	%% emrst_dir: Directory to save em results

	% roundnumber = 5;

	% savePath = ['/disk1/zhangyu/ICCV/selectedSal/round' num2str(roundnumber) '/'];
	load([emrst_dir 'globalEmResult' num2str(roundnumber) '.mat'], ...
		'labelerStats', 'imageStats', 'imglist', 'modelnum');
	load(CAM_wt, 'std_dic', 'threshold_dic');
	% k = 0.53			% select rate
	k = select_rate;

	subpaths = dir([salpath]);
	% globalRsltPath = '../data/selectedSal/'; 
	imgId = imageStats{1};
	imgBeta = imageStats{3};
	m = length(imgId);		% saliency number

	% Add CAM weight
	imgBeta = addCAMGlbWeight(imgBeta, std_dic, imglist{1});

	sortedBeta = sort(imgBeta, 'descend');
	threshold = sortedBeta(round(k*m));

	mkdir([savePath 'img/']);
	for ii = 1:modelnum
		mkdir([savePath 'sal' num2str(ii) '/']);
	end

	% Creating map from filename to beta
	globalmap2beta = containers.Map;

	for i = 1:m
		if(imgBeta(i) >= threshold)
			imgname = imglist{1}(i).name;
			globalmap2beta([imgname(1:end-4)]) = imgBeta(i);
			im = imread([imgPath imgname(1:end-4) '.jpg']);
			imwrite(im, [savePath 'img/' imgname(1:end-4) '.jpg']);
			for ii = 1:length(subpaths)-2
				sal = imread([salpath subpaths(ii+2).name '/' imgname]);
				imwrite(sal, ...
					[savePath 'sal' num2str(ii) '/' imgname(1:end-4) '.png']);
			end
		end
	end


	% 最后把三张显著图融合在一起
	mkdir([savePath 'glbSal/']);
	imgList = dir([savePath 'sal1/*.png']);
	labeler = labelerStats{2};
	% 处理标签能力
	for ii = 1:modelnum
		if(labeler(ii) < 0)
			labeler(ii) = 0;
		end
	end
	if(sum(labeler) == 0) % All labelers are negetive
		labeler = 1./abs(labelerStats{2});
	end		
	% if(labeler(1)<=0 & labeler(2)<=0 & labeler(3)<=0)
	% 	labeler = abs(labeler)
	% else
	% 	for i = 1:3
	% 	    if(labeler(i)<0)
	% 	        labeler(i) = 0;
	% 	    end
	% 	end
	% end
	for i = 1:length(imgList)
		sals = cell(modelnum, 1);
		for jj = 1:modelnum
			sals{jj} = imread([savePath 'sal' num2str(jj) '/' imgList(i).name]);
			if(jj == 1)
				finalSal = (labeler(jj)/sum(labeler))*sals{jj};
			else
				finalSal = finalSal + (labeler(jj)/sum(labeler))*sals{jj};
			end
		end
		% sal1 = imread([savePath 'sal1/' imgList(i).name]);
		% sal2 = imread([savePath 'sal2/' imgList(i).name]);
		% sal3 = imread([savePath 'sal3/' imgList(i).name]);
		% finalSal =  sal1*(labeler(1)/sum(labeler)) + ...
		% 			sal2*(labeler(2)/sum(labeler)) + ...
		% 			sal3*(labeler(3)/sum(labeler));
		imwrite(finalSal, [savePath 'glbSal/' imgList(i).name]);
	end

	save ([emrst_dir 'globalmap2beta' num2str(roundnumber) '.mat'], 'globalmap2beta', '-v7.3');
	% save ([emrst_dir 'global_alpha' num2str(roundnumber) '.mat'], 'labelerStats', '-v7.3');
end
