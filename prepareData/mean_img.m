function mean_img(basedir, big_glb, meandir)
	%% big_glb == 1: 0.9*glb + 0.1*loc  big_glb == 0: 0.1*glb + 0.9*loc
	% basedir = ['/disk1/zhangyu/ICCV/selectedSal/round' num2str(roundnumber) '/'];
	locdir = [basedir 'localSal/'];
	glbdir = [basedir 'glbSal/'];
	% meandir = [basedir 'meanSal/'];
	mkdir(meandir);
	sal_list = dir([locdir '*.png']);
	for iter = 1:length(sal_list)
		glb = imread([glbdir sal_list(iter).name]);
		loc = imread([locdir sal_list(iter).name]);
		if(big_glb == 1)
			mean_sal = mat2gray(0.9*glb + 0.1*loc);
		else
			mean_sal = mat2gray(0.1*glb + 0.9*loc);
		end
		imwrite(mean_sal, [meandir sal_list(iter).name]);
	end
end


% function mean_img(basedir, atMapDir, meandir)
% 	locdir = [basedir 'localSal/'];
% 	glbdir = [basedir 'glbSal/'];
% 	mkdir(meandir);
% 	sal_list = dir([locdir '*.png']);
% 	for iter = 1:length(sal_list)
% 		glb = imread([glbdir sal_list(iter).name]);
% 		loc = imread([locdir sal_list(iter).name]);
% 		[h, w] = size(glb);
% 		atMap = imread([atMapDir sal_list(iter).name]);
% 		atMap = imresize(atMap, [h, w]);

% 		thresh = 128;
% 		maskGlb = glb > thresh; maskLoc = loc > thresh;
% 		maskAtMap = atMap > thresh;
% 		simiGlb = sum(sum(maskAtMap .* maskGlb));
% 		simiLoc = sum(sum(maskAtMap .* maskLoc));
% 		coefG = simiGlb/(simiGlb + simiLoc);
% 		coefL = simiLoc/(simiGlb + simiLoc);

% 		mean_sal = mat2gray(coefG*glb + coefL*loc);
% 		imwrite(mean_sal, [meandir sal_list(iter).name]);
% 	end
% end


