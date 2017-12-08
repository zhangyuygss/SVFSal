clear;
addpath('../evaluate/');
run('../vlfeat-0.9.20/toolbox/vl_setup');

imgdir = '../data/selectedSal/img/';
maskPath = '../data/MSRA10K/GT/';
savePath = '../data/selectedSal/';
subPaths = dir([savePath 'sal*']);
labelerNum = length(subPaths);
saldir = cell(labelerNum, 1);
for i = 1:length(subPaths)
    saldir{i} = [savePath subPaths(i).name '/'];
end
mkdir([savePath 'localSal1']);
mkdir([savePath 'localSal2']);
mkdir([savePath 'localSal3']);

paras.t = 2;

betas = [1 0.9 1.4 0.5 0.8 1.2 1.5 2 2.5 3 4 5 6];

imgList = dir([imgdir '*jpg']);
imgNum = length(imgList);

perfWrite={'AUC','AP','Pre1','TPR1','Fm'};
fid = fopen('local_test.txt', 'at+');
for bidx = 1:length(betas)
	savedir = [savePath 'localtest/local' num2str(betas(bidx)) '/'];
	mkdir(savedir);
	for i = 1:imgNum
		if(~mod(i,50))
			disp(i);
		end
		im = imread([imgdir imgList(i).name]);
		sals = cell(1,3);
		for jj = 1:3
			sals{jj} = imread([saldir{jj} imgList(i).name]);
		end
		localSal = local_em(im, sals, betas(bidx));
		imwrite(localSal, [savedir imgList(i).name]);
	end
	performance = evaluate_SO(maskPath, savedir, '.jpg');
	fprintf(fid, ['priBeta:' num2str(betas(bidx)) ' ']);
	for ii = 1:length(perfWrite)
		eval(['fprintf(fid,''%.4f  '', performance.' perfWrite{ii} ');']);
	end
	fprintf(fid, '\n');
end

rmpath('../evaluate/');

