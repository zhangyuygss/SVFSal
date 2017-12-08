function  P_Z1=initPG2_qr( feature,pic_l,r,c,treenum)
%%%%%  [r c]=size(pic_l), [row,colum,depth]=size(d_pic);
if nargin<5
    treenum=2;
end

pos_idx=sum(pic_l,2)==c;
neg_idx=sum(pic_l,2)==0;
i=1;
while sum(pos_idx)==0
    pos_idx=sum(pic_l,2)==c-i;
    i=i+1;
end
i=1;
while sum(neg_idx)==0
    neg_idx=sum(pic_l,2)==0+i;
    i=i+1;
end

img_vector=[];
pos_fea=[];
neg_fea=[];

%{
 for i=1:depth
    channel=d_pic(:,:,i);
    channel=channel(:);
    img_vector=[img_vector channel];
    pos_fea=[pos_fea channel(pos_idx)];
    neg_fea=[neg_fea channel(neg_idx)];
  end
%}
pos_fea=feature(pos_idx,:);
neg_fea=feature(neg_idx,:);
img_vector=feature;
%%% calculate P_Z1
P_Z1=zeros(r,1);
P_Z1(pos_idx)=9999;
P_Z1(neg_idx)=-9999;



    kdtree_pos = vl_kdtreebuild(pos_fea', 'NumTrees', treenum) ;
    kdtree_neg = vl_kdtreebuild(neg_fea', 'NumTrees', treenum) ;
    for i=1:r

        if pos_idx(i)~=1&&neg_idx(i)~=1        
%         Dpos=nnDis(img_vector(i,:),pos_fea); 
%         Dneg=nnDis(img_vector(i,:),neg_fea);
        [~, Dpos] = vl_kdtreequery(kdtree_pos, pos_fea', img_vector(i,:)') ;
        [~, Dneg] = vl_kdtreequery(kdtree_neg, neg_fea', img_vector(i,:)') ;
        P_Z1(i)=exp((Dneg-Dpos)/(10^4));
        
        if P_Z1(i) == Inf
            P_Z1(i) = 9999;
        elseif P_Z1(i) == -Inf
            P_Z1(i) = -9999;
        end
        
        end

      
        
    end

        


%%% calculate Gamma
%Gamma=0;
%{
if paranum==2
sur=2;
for i=1:row
   for j=1:column
      patch_fea=[];
      s_top=max(1,i-sur);
      s_bottom=min(row,i+sur);
      s_left=max(1,j-sur);
      s_right=min(column,j+sur);
      path=d_pic(s_top:s_bottom,s_left:s_right,:);
      for k=1:depth
          channel=path(:,:,k);
          patch_fea=[patch_fea channel(:)];
      end
      gamma(i,j)=sqrt(sum(std(patch_fea,1).^2));
   end
end
 
for i=1:r
    neigh_index=neighbor{i};
    neigh_fea=feature(neigh_index,:)';
    neigh_fea=[neigh_fea feature(i,:)'];
    gamma(i)=sqrt(sum(std(neigh_fea,1).^2));
    
end

Gamma=gamma(:);
%}
%Gamma=rand(length(gamma(:)),1);
clear neg_idx pos_idx;
end
          
    
        
