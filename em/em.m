function [ imageStats, labelerStats ] = em (imageIds, labelerIds, labels, priorZ1, priorAlpha, priorBeta)
% [ imageStats, labelerStats ] = EM(imageIds, labelerIds, labels, priorZ1, priorAlpha, priorBeta)
% Wrapper function for em_mex C-based Mex function.
% Note that priorBeta is the prior of log(beta), not beta itself.
	if nargin < 5
		priorAlpha = ones(length(unique(labelerIds)), 1);
	end
	if nargin < 6
		priorBeta = ones(length(unique(imageIds)), 1);
	end

	% Check inputs
	if (length(imageIds) ~= length(labelerIds)) || (length(imageIds) ~= length(labels))
		error('imageIds, labelerIds, and labels must have the same length!');
	end
	if length(priorAlpha) == 1
		priorAlpha = repmat(priorAlpha, length(unique(labelerIds)), 1);
	elseif length(priorAlpha) ~= length(unique(labelerIds))
		error('priorAlpha should have length 1, or same length as unique(labelerIds)!');
	end
	if length(priorBeta) == 1
		priorBeta = repmat(priorBeta, length(unique(imageIds)), 1);
	elseif length(priorBeta) ~= length(unique(imageIds))
		error('priorBeta should have length 1, or same length as unique(imageIds)!');
	end
	if length(priorZ1) == 1
		priorZ1 = repmat(priorZ1, length(unique(imageIds)), 1);
	elseif length(priorZ1) ~= length(unique(imageIds))
		error('priorZ1 should have length 1, or same length as unique(imageIds)!');
	end

	numImages = length(unique(imageIds));
	numLabelers = length(unique(labelerIds));

	% Map from the given set of labelers to 1:numLabelers
	[dummy, mappedImages] = ismember(imageIds, unique(imageIds));
	[dummy, mappedLabelers] = ismember(labelerIds, unique(labelerIds));

	% "- 1" -- convert from Matlab- to C-style indexing.
	mappedL = zeros(length(labels), 3);
	mappedL(:,1) = mappedImages - 1;
	mappedL(:,2) = mappedLabelers - 1;
	mappedL(:,3) = labels;

	[ pZ, beta, alpha ] = em_mex(mappedL, numLabelers, numImages, priorZ1, priorAlpha, priorBeta);

	% Map back!
	imageStats{:,1} = unique(imageIds);
	imageStats{:,2} = pZ;
	imageStats{:,3} = beta;

	labelerStats{:,1} = unique(labelerIds);
	labelerStats{:,2} = alpha;
end
