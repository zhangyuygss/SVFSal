%% getUnary: function description
function [U] = getUnary(img1d, sal1d, fgm, bgm)
	K = size(fgm, 1);	% number of Gaussian
	% img_fg = img1d(fgIdx, :); img_bg = img1d(~fgIdx, :);

	U = zeros(size(img1d, 1), 2);
	fgD = zeros(size(img1d, 1), K);	% D of every pixel in foreground
	for idx = 1:K
		weight = fgm{idx, 1};
		mu = fgm{idx, 2};
		Sigma = fgm{idx, 3};
		fgD(:, idx) = - log(mvnpdf(img1d, mu, Sigma)) - log(weight) - 1.5*log(2*pi);
	end
	[minfgD, ~] = min(fgD, [], 2);
	U(:, 1) = minfgD;

	K = size(bgm, 1);
	bgD = zeros(size(img1d, 1), K);	% D of every pixel in background
	for idx = 1:K
		weight = bgm{idx, 1};
		mu = bgm{idx, 2};
		Sigma = bgm{idx, 3};
		bgD(:, idx) = - log(mvnpdf(img1d, mu, Sigma)) - log(weight) - 1.5*log(2*pi);
	end
	[minbgD, ~] = min(bgD, [], 2);
	U(:, 2) = minbgD;

	U = U .* cat(2, sal1d, 1-sal1d);
	U = sparse(U);

