% Adding CAM global weight to global weight 
function glbWeight = gen_glb_weight(imgBeta, std_dic, imglist)
    betaMin = min(imgBeta); betaMax = max(imgBeta);
    CAMMin = min(cell2mat(std_dic.values));
    CAMMax = max(cell2mat(std_dic.values));

    glbWeight = imgBeta;
    for iter = 1:length(imglist)
        imgname = imglist(iter).name;
        imNameShort = imgname(1:end-4);
        
        betaWeight = imgBeta(iter);
        CAMWeight = std_dic(imNameShort);
        CWNormalize = betaMin + (betaMax-betaMin)*(CAMWeight-CAMMin)/(CAMMax-CAMMin);

        glbWeight(iter) = CWNormalize + betaWeight;
    end
end


