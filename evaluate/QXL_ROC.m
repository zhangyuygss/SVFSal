function [TPR, FPR, Precision, AUC, AP, F] = QXL_ROC( image, hsegmap, NT )
%计算某一幅sm的ROC相关数据，但是需要Algorithm_ROC.m提供ground truth。
%input parameter description: 
%image：输入的sm
%hsegmap：sm对应的手动分割图
%NT: 有多少级灰度阈值
%output parameter description: 
%TPR, FPR：真真率，假真率，1*102
%AUC：ROC曲线下包含的面积，单个数值
betaSqr=0.3;
%这里对输入的sm和fixation map做了一个统一处理，变成全256级灰度图像
img=mat2gray(image);

%img=uint8(img*(NT-1));


hsegmap=double(im2bw(mat2gray(hsegmap),0.5));%正则化到[0 1]
hsegmap=hsegmap(:,:,1);
img=imresize(img,size(hsegmap));
img=(img*(NT-1));

positiveset  = hsegmap; %手动分割图的真集合
negativeset = ~hsegmap ;%手动分割图的假集合
P=sum(positiveset(:));%手动分割图的真集合点的个数
N=sum(negativeset(:));%手动分割图的假集合点的个数

%初始化TPR和FPR，因为有多少个阈值所有就有多少对[ TPR, FPR ]
TPR=zeros(1,NT);
FPR=zeros(1,NT);

Precision=zeros(1,NT);
F=zeros(1,NT);
%确保首位是1和0，这个不影响得分，只是显示曲线时好看
% TPR(1)=1;
% FPR(1)=1;
% TPR(NT+2)=0;
% FPR(NT+2)=0;
% Precision(1)=0;
% Precision(NT+2)=1;


for i=1:NT
%对输入的sm，我们把它变成全100级灰度后，就拿0~99这100个灰度作为阈值。关于阈值的选取，我曾经试过很多种方案，比如侯晓迪PAMI2011
%的代码，统计sm里有几个不重复的灰度，拿这些灰度做阈值，这样做即即精确又节省计算量，但是，由于每幅sm里不重复的灰度个数各个不同，计
%算出来的TPR和FPR的个数也就不同，将来没法把各个sm的TPR、FPR做均值和方差运算。还有一种方法，将sm所有像素的灰度进行排序，将这
%些像素点等分成N份，每份一个阈值，关键是N取多大，N如果小于sm的不重复的灰度个数，那么ROC数值和曲线就会偏低，但是这个“sm的不重
%复的灰度个数”每幅又不同，只能把N取大一点，贺胜就是取N=320，这明显是浪费，因为N>256的话就没意义了。我经过实验发现取100个阈值既
%减少运算量还可以保持相当的精度
      T=i-1;
%超过阈值的部分就是主观认定的真集合
      positivesamples = img >= T;
%计算真真和假真

      TPmat=positiveset.*positivesamples;
      FPmat=negativeset.*positivesamples;
      
       PS=sum(positivesamples(:));
       if PS~=0       
%统计各项指标的具体数值
      TP=sum(TPmat(:));
      FP=sum(FPmat(:));
%计算真真率和假真率
      TPR(i)=TP/P;
      FPR(i)=FP/N;
      
      Precision(i)=TP/PS;
      F(i)=(1+betaSqr)*TPR(i)*Precision(i)/(TPR(i)+betaSqr*Precision(i));
       end
end


%计算AUC（ROC曲线下的面积）
AUC = -trapz([1,FPR,0], [1,TPR,0]);
AP = -trapz([1,TPR,0], [0,Precision,1]);
end
