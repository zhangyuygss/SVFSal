% Resize global weight beta(one number) to global weight map(2D map)
% for further local weight
function gen_glb_weight(roundnumber ,saldir, betamap, weight_savedir)
	load(betamap);
	imglist = dir([saldir '*png']);
	loss_weight = containers.Map;
	for iter = 1:length(imglist)
		imgname = imglist(iter).name;
		sal = imread([saldir imgname]);
		glbweight = ones(size(sal));
		glbweight(:) = globalmap2beta([imgname(1:end-4)]);
		loss_weight([imgname(1:end-4)]) = glbweight;
	end
	save ([weight_savedir 'glb_weight' num2str(roundnumber) '.mat'],'loss_weight', '-v7.3');
end
