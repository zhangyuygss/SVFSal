function [seg] = salcut(img, sal, maxIter)
% saliency map cut to binary segmentation map using grabcut
% Input:
% 	img: input image
% 	sal: input saliency map of the image
% 	maxIter: maximum iteration of grabcut
% Output:
% 	seg: binary segmentation
% Author:
% 	Yu Zhang
% 	Northwestern Polytechnical University
% 	August 2017
	epsilon = 0.0001; 
	ifvisualize = 1;

	img = im2double(img); sal = im2double(sal);
	[h, w] = size(sal);
	threshold = graythresh(sal);
	mask = img > threshold;
	
	sal1d = reshape(sal, [], 1);
	img1d = reshape(img, [], 3);
	fgIdx = sal1d > threshold;
	
	% output
	segs = cell(1,maxIter+1);
	flows = zeros(1,maxIter+1);
	energies = zeros(1,maxIter+1);
	fgks = cell(1, maxIter+1);
	bgks = cell(1, maxIter+1);
	converged = false;
	
	[P Pk] = getPairwise(img);
	K = 5;	% number of clusters
	[fgk, bgk] = clusterFromSaliency(sal1d, fgIdx, K);
	fgks{1} = showk(fgk, fgIdx); bgks{1} = showk(bgk, ~fgIdx);
	segs{1} = reshape(fgIdx, [h, w]);

	[fgm bgm] = updateGMM(img1d, fgIdx, fgk, bgk);	% Initialize GMMs

	% first unary, use only saliency map
	U = cat(2, sal1d, 1-sal1d);
	U = sparse(U);
	energies(1) = getEnergy(U, P, fgIdx);

	for iter = 1:maxIter
		disp(iter);
		[segs{iter+1}, flows(iter)] = getSegmentation(U, P, h, w);
		fgIdx = reshape(segs{iter+1}, [], 1);
		
		[fgk, bgk] = assignGaussian(img1d, fgIdx, fgm, bgm);
		fgks{iter+1} = showk(fgk, fgIdx); bgks{iter+1} = showk(bgk, ~fgIdx);

		[fgm, bgm] = updateGMM(img1d, fgIdx, fgk, bgk);
		U = getUnary(img1d, sal1d, fgm, bgm);
		energies(iter+1) = getEnergy(U, P, fgIdx);

		if iter>1 && (energies(iter+1)-energies(iter))/energies(iter) <= epsilon
			converged = true; break;
		end
	end

	if ~converged
		fprintf('Did not converge in %d iterations\n', maxIter);
	end
	seg = segs{iter+1};

	if ifvisualize
		clf();
		visualize(segs, energies, fgks, bgks, iter+1);
	end
