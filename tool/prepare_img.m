function im=prepare_img(image)
    mean_pix = [103.939, 116.779, 123.68];
    im = single(image);
    if size(image,1)~=224 || size(image,2)~=224
        im = imresize(im, [224, 224],'bilinear');
    end
    im = im(:, :, [3 2 1]);
    im = permute(im, [2 1 3]);
    for c = 1:3
        im(:, :, c) = im(:, :, c) - mean_pix(c);
    end