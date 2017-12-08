% Adding CAM local weight to local weight 
function locWeight = addCAMLocWeight(at_map, betas)
    if(max(max(at_map)) <= 2)
        at_weight = abs(at_map - 0.5);
    else
        at_weight = abs(at_map - 128);
    end
    at_weight = mat2gray(at_weight);
    betas = mat2gray(betas);
    locWeight = at_weight + betas;
