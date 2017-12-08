function [fgk, bgk] = assignGaussian(img1d, fgIdx, fgm, bgm)
	
	img_fg = img1d(fgIdx, :); img_bg = img1d(~fgIdx, :);
	
	fgNumK = size(fgm, 1);	% number of Gaussian for fg
	fgD = zeros(size(img_fg, 1), fgNumK);	% D of every pixel in foreground
	for idx = 1:fgNumK
		weight = fgm{idx, 1};
		mu = fgm{idx, 2};
		Sigma = fgm{idx, 3};
		fgD(:, idx) = - log(mvnpdf(img_fg, mu, Sigma)) - log(weight) - 1.5*log(2*pi);
	end
	[~, fgk] = min(fgD, [], 2);

	bgNumK = size(bgm, 1);
	bgD = zeros(size(img_bg, 1), bgNumK);	% D of every pixel in background
	for idx = 1:bgNumK
		weight = bgm{idx, 1};
		mu = bgm{idx, 2};
		Sigma = bgm{idx, 3};
		bgD(:, idx) = - log(mvnpdf(img_bg, mu, Sigma)) - log(weight) - 1.5*log(2*pi);
	end
	[~, bgk] = min(bgD, [], 2);