function [sm]=predict_sm(net,im,x,y)
    output=net.forward({im});
    tmp = output{1};
    sm = imresize(tmp',[x,y],'bilinear');
