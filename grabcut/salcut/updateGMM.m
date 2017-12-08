%% updateGMM: function description
function [fgm, bgm] = updateGMM(img1d, fgIdx, fgk, bgk, oldfgm, oldbgm)
	fgks = unique(fgk);	% GMMs of fg, label k may not have all 1,2,...,K
	fgm = cell(length(fgks), 3); 
	imgfg = img1d(fgIdx, :);  
	for idx = 1:length(fgks)
		lb = fgks(idx);
		datafg = imgfg(fgk == lb, :);
		fgm{idx, 1} = size(datafg, 1)/size(imgfg, 1); % weights
		fgm{idx, 2} = mean(datafg, 1);	% mu
		fgm{idx, 3} = cov(datafg);	% sigma

		[~, err1] = cholcov(fgm{idx, 3}, 0);
		err2 = 0;
		if(size(fgm{idx, 3}, 2) == 1)
			err2 = 1;
		end
		err = err1 + err2;
	end
	
	bgks = unique(bgk);
	bgm = cell(length(bgks), 3);
	imgbg = img1d(~fgIdx, :);
	for idx = 1:length(bgks)
		lb = bgks(idx);
		databg = imgbg(bgk == lb, :);
		bgm{idx, 1} = size(databg, 1)/size(imgbg, 1);
		bgm{idx, 2} = mean(databg, 1);
		bgm{idx, 3} = cov(databg);

		[~, err1] = cholcov(bgm{idx, 3}, 0);
		err2 = 0;
		if(size(fgm{idx, 3}, 2) == 1)
			err2 = 1;
		end
		err = err1 + err2;
		a = 0;
	end
