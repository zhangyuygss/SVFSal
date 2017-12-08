function [ seg_vals,num_fea ] = Get_features (image, spnum, pixelList, texton) 
%% compute the feature (mean color in lab color space) for each node (superpixel)
        % spnum = spsets.spnum;
        % pixelList = spsets.pixelList;
        [h w k] = size( image);
        input_vals=reshape(image, h*w, k);
        rgb_vals=zeros(spnum,3);
        for i=1:spnum
            rgb_vals(i,:)=mean(input_vals(pixelList{i},:),1);
        end  
        lab_vals = colorspace('Lab<-', rgb_vals); % feature for each superpixel
        seg_vals = lab_vals;
       %% texton feature
        texton_vals=zeros(spnum,1);
        for i=1:spnum
            texton_vals(i,:)=mean(texton(pixelList{i}));
        end  
        seg_vals = [ seg_vals texton_vals];
        
        filtext = makeLMfilters;
        ntext = size(filtext, 3);
       %% lbp texture
        grayim = rgb2gray( image );
        imtext = zeros(h,w,ntext);
        for f = 1:ntext
            imtext(:, :, f) = abs(imfilter(im2single(grayim), filtext(:, :, f), 'same'));    
        end
        imtext1=reshape(imtext, h*w, ntext);
        lbp_vals = zeros(spnum, ntext);        
        for i=1:spnum
            lbp_vals(i,:)=mean(imtext1(pixelList{i},:),1);
        end  
        seg_vals = [seg_vals lbp_vals];   
        num_fea(1) = k;
        num_fea(2) = 1;
        num_fea(3) = ntext;
        seg_vals = normalize(seg_vals);

end

