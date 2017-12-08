function weights=makeweights2(vals,valScale,adjcMatrix)
valDistances = dist(vals');
valDistances=normalize(valDistances);
weights_all = exp(-valScale*valDistances);
weights = weights_all .* adjcMatrix;
