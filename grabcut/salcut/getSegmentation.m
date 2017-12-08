%% getSegmentation: function description
function [seg, flow] = getSegmentation(U, P, h, w)
	[flow, seg] = maxflow(50*P, 50*U);
	seg = logical(reshape(seg, [h, w]));
