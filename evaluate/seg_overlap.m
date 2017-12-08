function SOV = seg_overlap(imsegs, im, sal, GT)
    if(max(max(sal)) > 2)
        sal = sal/255;
    end
    if(max(max(GT)) > 2)
        GT = GT/255;
    end
    segments = imsegs.segimage;
    regions = regionprops(segments, 'PixelIdxList');
    regionNum = length(regions);
    resultimg_smoothed = zeros(size(sal));
    for ii=1:regionNum
        resultimg_smoothed(regions(ii).PixelIdxList) = mean(sal(regions(ii).PixelIdxList));
    end
    threshold = 2*mean2(resultimg_smoothed);
    index1 = (resultimg_smoothed>=threshold);
    truePositive = length(find(index1 & GT));
    mm = length(find(index1 | GT));
    if truePositive~=0
        SOV = truePositive/mm;  
    else
        SOV = 0;
    end