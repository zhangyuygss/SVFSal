function [TPR, Precision, F] = Fmeasure( image, hsegmap )
%计算某一幅sm的ROC相关数据，但是需要Algorithm_ROC.m提供ground truth。
%input parameter description: 
%image：输入的sm
%hsegmap：sm对应的手动分割图
%NT: 有多少级灰度阈值


betaSqr=0.3;
%这里对输入的sm和fixation map做了一个统一处理，变成全256级灰度图像
%img=mat2gray(image);
img=mat2gray(imresize(image,[size(hsegmap,1),size(hsegmap,2)]));

hsegmap=double(im2bw(mat2gray(hsegmap),0.5));%正则化到[0 1]
hsegmap=hsegmap(:,:,1);
positiveset  = hsegmap; %手动分割图的真集合
negativeset = ~hsegmap ;%手动分割图的假集合
P=sum(positiveset(:));%手动分割图的真集合点的个数
N=sum(negativeset(:));%手动分割图的假集合点的个数

%%%%%%%   计算Fmeasure
    %T=min(1,mean(img(:))+std(img(:),0));
    %T=min(1,mean(img(:))+1.2*std(img(:),1));
    Threshold=2*mean(img(:));
%超过阈值的部分就是主观认定的真集合
      positivesamples = img >= Threshold;
%计算真真和假真

      TPmat=positiveset.*positivesamples;
      FPmat=negativeset.*positivesamples;
      
       PS=sum(positivesamples(:));
%统计各项指标的具体数值
      TP=sum(TPmat(:));
      FP=sum(FPmat(:));
%计算真真率和假真率
      TPR=TP/P;
      FPR=FP/N;
      Precision=TP/PS;
      if PS==0
          F=0;
          Precision=0;
          TPR=0;
      elseif TPR==0
          F=0;
      else
          F=(1+betaSqr)*TPR*Precision/(TPR+betaSqr*Precision);
          %F=TPR*Precision/(0.5*TPR+0.5*Precision);
      end
end
