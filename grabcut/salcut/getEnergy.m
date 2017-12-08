%% getEnergy: function description
function [energy] = getEnergy(U, P, fgIdx)
	energy = 0;
	energy = energy + sum(U(fgIdx==1, 1));
	energy = energy + sum(U(fgIdx==0, 2));
	energy = energy + sum(sum(P(fgIdx==0, fgIdx==1)));
