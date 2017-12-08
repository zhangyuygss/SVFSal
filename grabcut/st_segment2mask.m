function seg = st_segment2mask(image,mask,motion,maxIterations)
	% For one image only.

	% settings
	doMorph = false; % apply morphological operations at the end (as in original GrabCut)
	doVisualize = false; % show plots with intermediate results

	if size(image,1)~=size(mask,1) || size(image,2)~=size(mask,2)
		mask = img_resize(mask,[size(image,1) size(image,2)]);
	end;

	% output
	segs = cell(1,maxIterations+1);
	flows = zeros(1,maxIterations+1);
	energies = zeros(1,maxIterations+1);
	fgks = cell(1, maxIterations+1);
	bgks = cell(1, maxIterations+1);
	converged = false;

	% initialization
	[img h w] = getImage(image);
	[P Pk] = getPairwise(img);
	% [fgm bgm] = initializeModel(img,mask>=threshold);
	U_loc = double(cat(3, mask, 1-mask));
	U_loc_orig = U_loc;


	% Get initial cluster using only saliency map
	K = 5;
	mask1d = reshape(mask, [], 1);
	lb1d = reshape(motion, [], 1);
	mask1d_fg = mask1d; mask1d_fg(~lb1d) = 0;
	mask1d_bg = mask1d; mask1d_bg(lb1d) = 0;
	% rmpath(genpath('../vlfeat-0.9.20'));
	fgk = kmeans(mask1d_fg, K, 'Distance', 'cityblock', 'Replicates', 5);
	bgk = kmeans(mask1d_bg, K, 'Distance', 'cityblock', 'Replicates', 5);
	% addpath(genpath('../vlfeat-0.9.20'));
	fgk = reshape(fgk, [h,w]); bgk = reshape(bgk, [h,w]);

	old = pdf_gm(repmat(img(randi(h),randi(w),:),[K 1]),repmat(1e-5*eye(3),[1 1 K]),ones(K,1)/K);
	[fgm bgm] = learnModel(img, motion, old, old, fgk, bgk);
	% U_app = - log(mask);
	% U = getUnary(U_loc,U_app);
	U_app = getUnary_app(img,fgm,bgm,fgk,bgk);
	U = getUnary(U_loc,U_app);
	segs{1} = motion;
	energies(1) = getEnergy(P, U, lb1d);
	fgks{1} = fgk; bgks{1} = bgk;


	for i = 1:maxIterations
		% figure;
		% subplot(1,2,1); imshow(label2rgb(fgk)); title('mod_fgk');
		% subplot(1,2,2); imshow(label2rgb(bgk)); title('bgk');
	%	pg_message('iteration %d/%d',i,maxIterations);
		
		

		[segs{i+1} flows(i+1) energies(i+1)] = getSegmentation(P,U,w,h);
		
	%	pg_message('flow = %g, energy = %g',flows(i),energies(i));
		
		% TODO assert energy/flow decrease

		% if doVisualize
		% 	visualize(img,mask,threshold,segs{i},i,energies(1:i));
		% end;

		if i>1 && all(segs{i-1}(:)==segs{i}(:))
	%		pg_message('converged after %d/%d iterations',i,maxIterations);
			converged = true;
			break;
		end;
		
		[fgm bgm] = learnModel(img,segs{i},fgm,bgm,fgk,bgk);
		[fgk bgk] = assignComponents(img,fgm,bgm);
		U_app = getUnary_app(img,fgm,bgm,fgk,bgk);
		U = getUnary(U_loc,U_app);

		fgks{i+1} = fgk; bgks{i+1} = bgk;

		% U_loc = double(cat(3, segs{i}, 1-segs{i}));
		% U_loc = U_loc .* U_loc_orig;
	end;

	if ~converged
	%	pg_message('did not converge after %d iterations',maxIterations);
		fprintf('did not converge after %d iterations\n',maxIterations);
	end;

	segs = segs(1:i+1);
	flows = flows(1:i+1);
	energies = energies(1:i+1);

	if(doVisualize)
		visualize(segs, energies, fgks, bgks, i+1);
	end
	seg = segs{end};
	energy = energies(end);




function energy = getEnergy(A,T,labels)

energy = 0;
energy = energy + sum(T(labels==0,2));
energy = energy + sum(T(labels==1,1));
energy = energy + sum(sum(A(labels==0,labels==1)));


function [img h w] = getImage(img)

img = im2double(img);
assert(ndims(img)==3);

h = size(img,1);
w = size(img,2);
assert(size(img,3)==3);


function [fg bg] = initializeModel(img,mask)

% pg_message('initializeModel');

assert(any(mask(:)));
assert(any(~mask(:)));

img = reshape(img,[],3);

K = 5;

fg = pdf_gm.fit_using_vectorquantisation(img(mask,:),K);
bg = pdf_gm.fit_using_vectorquantisation(img(~mask,:),K);


function [fk bk] = assignComponents(img,fg,bg)

% pg_message('assignComponents');

fk = fg.cluster_2d(img);
bk = bg.cluster_2d(img);


function [fg bg] = learnModel(img,seg,fg,bg,fk,bk)

% pg_message('learnModel');

K = 5;

img = reshape(img,[],3);
seg = reshape(seg,[],1);
fk = reshape(fk,[],1);
bk = reshape(bk,[],1);

fg = pdf_gm.fit_given_labels(img(seg,:),fk(seg),K,fg);
bg = pdf_gm.fit_given_labels(img(~seg,:),bk(~seg),K,bg);


function [A K] = getPairwise(img)

% pg_message('getPairwise');

[h,w,~] = size(img);
n = h*w;

imgr = img(:,:,1); imgr = imgr(:);
imgg = img(:,:,2); imgg = imgg(:);
imgb = img(:,:,3); imgb = imgb(:);

% locations
[x,y] = meshgrid(1:w,1:h);
x = x(:); y = y(:);

% neighbors down -> y+1 -> idx+1
n1_i1 = 1:n; n1_i1 = n1_i1(y<h);
n1_i2 = n1_i1+1;

% neighbors right-down -> x+1,y+1 -> idx+1+h
n2_i1 = 1:n; n2_i1 = n2_i1(y<h & x<w);
n2_i2 = n2_i1+1+h;

% neighbors right -> x+1 -> idx+h
n3_i1 = 1:n; n3_i1 = n3_i1(x<w);
n3_i2 = n3_i1+h;

% neighbors right-up -> x+1,y-1 -> idx+h-1
n4_i1 = 1:n; n4_i1 = n4_i1(x<w & h>1);
n4_i2 = n4_i1+h-1;

from = [n1_i1 n2_i1 n3_i1 n4_i1];
to = [n1_i2 n2_i2 n3_i2 n4_i2];

gamma = 50; % TODO could be trained
invdis = 1./sqrt((x(from)-x(to)).^2+(y(from)-y(to)).^2);
dz2 = (imgr(from)-imgr(to)).^2 + (imgg(from)-imgg(to)).^2 + (imgb(from)-imgb(to)).^2;
beta = (2*mean(dz2.*invdis))^-1; % TODO changed, .*invdis is not in paper, but in gco
expb = exp(-beta*dz2);
c = gamma * invdis .* expb;

A = sparse([from to],[to from],[c c]); % TODO do i need to explicitely make it symmetric?

K = 1+max(sum(A,2)); % TODO changed, gco seems to have only half of this, not correct


function T = getUnary_app(img,fg,bg,fk,bk)

% pg_message('getUnary');

T = cat(3,fg.pdf_2d(img,fk),bg.pdf_2d(img,bk));


function U = getUnary(U_loc,U_app)

U = -log(U_loc .* U_app);
U = reshape(U,[],2);
U = sparse(U);


function [seg flow energy] = getSegmentation(P,U,w,h)

[flow labels] = maxflow(50*P,50*U);
seg = reshape(labels==1,h,w);
energy = getEnergy(P,U,labels);


% function visualize(img,mask,threshold,seg,iteration,energies)

% clf();

% subplot(5,1,1);
% imshow(img);

% subplot(5,1,2);
% imshow(mask);

% subplot(5,1,3);
% imshow(mask>=threshold);

% subplot(5,1,4);
% imshow(img.*repmat(double(seg),[1 1 3]));

% subplot(5,1,5);
% imshow(seg);

% figure;
% plot(energies);
% title('convergence');
% ylabel('energy');
% xlabel('iteration');

% drawnow();

function [outputs] = visualize(segs, energies, fgks, bgks, len)
	[h, w] = size(segs{1});
	for iter = 1:len
		subplot(3,len,iter); 
		imshow(segs{iter}); title(['seg of iter' num2str(iter)]);
		subplot(3,len,iter+len); 
		imshow(label2rgb(reshape(fgks{iter}, [h, w])));
        title(['fgk of iter' num2str(iter)]);
		subplot(3,len,iter+len*2); 
		imshow(label2rgb(reshape(bgks{iter}, [h, w])));
        title(['bgk of iter' num2str(iter)]);
	end
	figure; 
	plot(energies);
    title('energies'); xlabel('energy'); ylabel('iteration');


function seg = applyMorph(seg)

seg = imclose(seg,strel('disk',3));
seg = imfill(seg,'holes');
seg = bwmorph(seg,'open'); % remove thin regions
[~,N] = bwlabel(seg); % select largest 8-connected region
h = hist(seg(:),1:N);
[~,i] = max(h);
seg = seg==i;


% function seg = st_segment2mask(image,mask1,mask2,threshold1,threshold2,maxIterations)
% % Segments the image using the mask to initialize Grabcut.
% %
% % arguments:
% %   image = rgb uint8 image, or cell of ~
% %   mask = transfer mask, or cell of ~, doesn't have to be the same size as the image(s)
% %   threshold = threshold on the mask to initialize fg/bg appearance models
% %   maxIterations = maximum number of iterations for GrabCut
% %
% % returns:
% %   seg = segmentation as logical image, or cell of ~, same size as image(s)

% % if iscell(image)
% % 	seg = map('c','par',@compute,'cc--',{image,mask,threshold,maxIterations});
% % else
% % 	seg = compute(image,mask,threshold,maxIterations);
% % end;
% seg = compute(image,mask1,mask2,threshold1,threshold2,maxIterations);

% function seg = compute(image,mask1,mask2,threshold1,threshold2,maxIterations)
% % For one image only.

% % settings
% doMorph = false; % apply morphological operations at the end (as in original GrabCut)
% doVisualize = false; % show plots with intermediate results

% if size(image,1)~=size(mask1,1) || size(image,2)~=size(mask1,2) ...
% 	|| size(image,2)~=size(mask2,2) || size(image,2)~=size(mask2,2)
% 	mask1 = img_resize(mask1,[size(image,1) size(image,2)]);
% 	mask2 = img_resize(mask2,[size(image,1) size(image,2)]);
% end;

% % output
% segs = cell(1,maxIterations+1);
% flows = zeros(1,maxIterations+1);
% energies = zeros(1,maxIterations+1);
% converged = false;

% % initialization
% K = 2;
% [img h w] = getImage(image);
% [P Pk] = getPairwise(img);
% % [fgm1 bgm1] = initializeModel(img,mask1>=threshold1);
% % [fgm2 bgm2] = initializeModel(img,mask2>=threshold2);
% U_loc1 = cat(3,mask1,1-mask1); U_loc1_orig = U_loc1;
% U_loc2 = cat(3,mask2,1-mask2); U_loc2_orig = U_loc2;

% [fgk1, bgk1] = clusterFromSaliency(mask1, threshold1);
% [fgk2, bgk2] = clusterFromSaliency(mask2, threshold2);
% old = pdf_gm(repmat(img(randi(h),randi(w),:),[K 1]),repmat(1e-5*eye(3),[1 1 K]),ones(K,1)/K);
% [fgm1 bgm1] = learnModel(img, mask1>threshold1, old, old, fgk1, bgk1);
% [fgm2 bgm2] = learnModel(img, mask2>threshold2, old, old, fgk2, bgk2);
% U_app1 = - log(mask1);
% U_app2 = - log(mask2);

% for i = 1:maxIterations

% 	U1 = getUnary(U_loc1,U_app1);
% 	U2 = getUnary(U_loc2,U_app2);
% 	U = U1 + U2;

% 	[segs{i} flows(i) energies(i)] = getSegmentation(P,U,w,h);

% 	if doVisualize
% 		visualize(img,mask,threshold,segs{i},i,energies(1:i));
% 	end;

% 	if i>1 && all(segs{i-1}(:)==segs{i}(:))
% %		pg_message('converged after %d/%d iterations',i,maxIterations);
% 		converged = true;
% 		break;
% 	end;
	
% 	[fgm1 bgm1] = learnModel(img,segs{i},fgm1,bgm1,fgk1,bgk1);
% 	[fgm2 bgm2] = learnModel(img,segs{i},fgm2,bgm2,fgk2,bgk2);
% 	[fgk1 bgk1] = assignComponents(img,fgm1,bgm1);
% 	[fgk2 bgk2] = assignComponents(img,fgm2,bgm2);
% 	U_app1 = getUnary_app(img,fgm1,bgm1,fgk1,bgk1);
% 	U_app2 = getUnary_app(img,fgm2,bgm2,fgk2,bgk2);
% 	% U_loc1 = double(cat(3, segs{i}, 1-segs{i})) .* U_loc1_orig;
% 	% U_loc2 = double(cat(3, segs{i}, 1-segs{i})) .* U_loc2_orig;
% end;

% if ~converged
% %	pg_message('did not converge after %d iterations',maxIterations);
% 	fprintf('did not converge after %d iterations\n',maxIterations);
% end;

% segs = segs(1:i);
% flows = flows(1:i);
% energies = energies(1:i);

% seg = segs{end};
% energy = energies(end);

% if doMorph
% 	seg = applyMorph(seg);
% 	if doVisualize
% 		visualize(img,mask,threshold,boxes,seg,energies);
% 	end;
% end;

% function [fgk, bgk] = clusterFromSaliency(saliency, threshold)
% 	% Get initial cluster using only saliency map
% 	K = 2;
% 	[h, w] = size(saliency);
% 	mask1d = reshape(saliency, [], 1);
% 	lb1d = mask1d > threshold;
% 	mask1d_fg = mask1d; mask1d_fg(~lb1d) = 0;
% 	mask1d_bg = mask1d; mask1d_bg(lb1d) = 0;
% 	% rmpath(genpath('../vlfeat-0.9.20'));
% 	fgk = kmeans(mask1d_fg, K, 'Distance', 'cityblock', 'Replicates', 5);
% 	bgk = kmeans(mask1d_bg, K, 'Distance', 'cityblock', 'Replicates', 5);
% 	% addpath(genpath('../vlfeat-0.9.20'));
% 	fgk = reshape(fgk, [h,w]); bgk = reshape(bgk, [h,w]);


% function energy = getEnergy(A,T,labels)

% energy = 0;
% energy = energy + sum(T(labels==0,2));
% energy = energy + sum(T(labels==1,1));
% energy = energy + sum(sum(A(labels==0,labels==1)));


% function [img h w] = getImage(img)

% img = im2double(img);
% assert(ndims(img)==3);

% h = size(img,1);
% w = size(img,2);
% assert(size(img,3)==3);


% function [fg bg] = initializeModel(img,mask)

% % pg_message('initializeModel');

% assert(any(mask(:)));
% assert(any(~mask(:)));

% img = reshape(img,[],3);

% K = 5;

% fg = pdf_gm.fit_using_vectorquantisation(img(mask,:),K);
% bg = pdf_gm.fit_using_vectorquantisation(img(~mask,:),K);


% function [fk bk] = assignComponents(img,fg,bg)

% % pg_message('assignComponents');

% fk = fg.cluster_2d(img);
% bk = bg.cluster_2d(img);


% function [fg bg] = learnModel(img,seg,fg,bg,fk,bk)

% % pg_message('learnModel');

% K = 2;

% img = reshape(img,[],3);
% seg = reshape(seg,[],1);
% fk = reshape(fk,[],1);
% bk = reshape(bk,[],1);

% fg = pdf_gm.fit_given_labels(img(seg,:),fk(seg),K,fg);
% bg = pdf_gm.fit_given_labels(img(~seg,:),bk(~seg),K,bg);


% function [A K] = getPairwise(img)

% % pg_message('getPairwise');

% [h,w,~] = size(img);
% n = h*w;

% imgr = img(:,:,1); imgr = imgr(:);
% imgg = img(:,:,2); imgg = imgg(:);
% imgb = img(:,:,3); imgb = imgb(:);

% % locations
% [x,y] = meshgrid(1:w,1:h);
% x = x(:); y = y(:);

% % neighbors down -> y+1 -> idx+1
% n1_i1 = 1:n; n1_i1 = n1_i1(y<h);
% n1_i2 = n1_i1+1;

% % neighbors right-down -> x+1,y+1 -> idx+1+h
% n2_i1 = 1:n; n2_i1 = n2_i1(y<h & x<w);
% n2_i2 = n2_i1+1+h;

% % neighbors right -> x+1 -> idx+h
% n3_i1 = 1:n; n3_i1 = n3_i1(x<w);
% n3_i2 = n3_i1+h;

% % neighbors right-up -> x+1,y-1 -> idx+h-1
% n4_i1 = 1:n; n4_i1 = n4_i1(x<w & h>1);
% n4_i2 = n4_i1+h-1;

% from = [n1_i1 n2_i1 n3_i1 n4_i1];
% to = [n1_i2 n2_i2 n3_i2 n4_i2];

% gamma = 50; % TODO could be trained
% invdis = 1./sqrt((x(from)-x(to)).^2+(y(from)-y(to)).^2);
% dz2 = (imgr(from)-imgr(to)).^2 + (imgg(from)-imgg(to)).^2 + (imgb(from)-imgb(to)).^2;
% beta = (2*mean(dz2.*invdis))^-1; % TODO changed, .*invdis is not in paper, but in gco
% expb = exp(-beta*dz2);
% c = gamma * invdis .* expb;

% A = sparse([from to],[to from],[c c]); % TODO do i need to explicitely make it symmetric?

% K = 1+max(sum(A,2)); % TODO changed, gco seems to have only half of this, not correct


% function T = getUnary_app(img,fg,bg,fk,bk)

% % pg_message('getUnary');

% T = cat(3,fg.pdf_2d(img,fk),bg.pdf_2d(img,bk));


% function U = getUnary(U_loc,U_app)

% U = -log(U_loc .* U_app);
% U = reshape(U,[],2);
% U = sparse(U);


% function [seg flow energy] = getSegmentation(P,U,w,h)

% [flow labels] = maxflow(50*P,50*U);
% seg = reshape(labels==1,h,w);
% energy = getEnergy(P,U,labels);


% function visualize(img,mask,threshold,seg,iteration,energies)

% clf();

% subplot2d(5,1,1,1);
% plot_image(img,'image');

% subplot2d(5,2,2,1);
% plot_image(mask,'prior');

% subplot2d(5,2,2,2);
% plot_image(mask>=threshold,'init');

% subplot2d(5,1,3,1);
% plot_image(img.*repmat(double(seg),[1 1 3]),'foreground');

% subplot2d(5,1,4,1);
% plot_image(seg,'segmentation');

% subplot2d(5,1,5,1);
% plot(energies);
% title('convergence');
% ylabel('energy');
% xlabel('iteration');

% drawnow();


% function seg = applyMorph(seg)

% seg = imclose(seg,strel('disk',3));
% seg = imfill(seg,'holes');
% seg = bwmorph(seg,'open'); % remove thin regions
% [~,N] = bwlabel(seg); % select largest 8-connected region
% h = hist(seg(:),1:N);
% [~,i] = max(h);
% seg = seg==i;








% % function seg = st_segment2mask(image,mask1,mask2,threshold1,threshold2,maxIterations)
% % % Segments the image using the mask to initialize Grabcut.
% % %
% % % arguments:
% % %   image = rgb uint8 image, or cell of ~
% % %   mask = transfer mask, or cell of ~, doesn't have to be the same size as the image(s)
% % %   threshold = threshold on the mask to initialize fg/bg appearance models
% % %   maxIterations = maximum number of iterations for GrabCut
% % %
% % % returns:
% % %   seg = segmentation as logical image, or cell of ~, same size as image(s)

% % % if iscell(image)
% % % 	seg = map('c','par',@compute,'cc--',{image,mask,threshold,maxIterations});
% % % else
% % % 	seg = compute(image,mask,threshold,maxIterations);
% % % end;
% % seg = compute(image,mask1,mask2,threshold1,threshold2,maxIterations);

% % function seg = compute(image,mask1,mask2,threshold1,threshold2,maxIterations)
% % % For one image only.

% % % settings
% % doMorph = false; % apply morphological operations at the end (as in original GrabCut)
% % doVisualize = false; % show plots with intermediate results

% % if size(image,1)~=size(mask1,1) || size(image,2)~=size(mask1,2) ...
% % 	|| size(image,2)~=size(mask2,2) || size(image,2)~=size(mask2,2)
% % 	mask1 = img_resize(mask1,[size(image,1) size(image,2)]);
% % 	mask2 = img_resize(mask2,[size(image,1) size(image,2)]);
% % end;

% % % output
% % segs = cell(1,maxIterations+1);
% % flows = zeros(1,maxIterations+1);
% % energies = zeros(1,maxIterations+1);
% % converged = false;

% % % initialization
% % [img h w] = getImage(image);
% % [P Pk] = getPairwise(img);
% % [fgm1 bgm1] = initializeModel(img,mask1>=threshold1);
% % [fgm2 bgm2] = initializeModel(img,mask2>=threshold2);
% % U_loc1 = cat(3,mask1,1-mask1);
% % U_loc2 = cat(3,mask2,1-mask2);

% % for i = 1:maxIterations
	
% % %	pg_message('iteration %d/%d',i,maxIterations);

% % 	% [fgk bgk] = assignComponents(img,fgm,bgm);
% % 	% U_app = getUnary_app(img,fgm,bgm,fgk,bgk);
% % 	% U = getUnary(U_loc,U_app);

% % 	[fgk1 bgk1] = assignComponents(img,fgm1,bgm1);
% % 	[fgk2 bgk2] = assignComponents(img,fgm2,bgm2);
% % 	U_app1 = getUnary_app(img,fgm1,bgm1,fgk1,bgk1);
% % 	U_app2 = getUnary_app(img,fgm2,bgm2,fgk2,bgk2);
% % 	U1 = getUnary(U_loc1,U_app1);
% % 	U2 = getUnary(U_loc2,U_app2);
% % 	U = U1 + U2;

% % 	[segs{i} flows(i) energies(i)] = getSegmentation(P,U,w,h);
	
% % %	pg_message('flow = %g, energy = %g',flows(i),energies(i));
	
% % 	% TODO assert energy/flow decrease

% % 	if doVisualize
% % 		visualize(img,mask,threshold,segs{i},i,energies(1:i));
% % 	end;

% % 	if i>1 && all(segs{i-1}(:)==segs{i}(:))
% % %		pg_message('converged after %d/%d iterations',i,maxIterations);
% % 		converged = true;
% % 		break;
% % 	end;
	
% % 	[fgm1 bgm1] = learnModel(img,segs{i},fgm1,bgm1,fgk1,bgk1);
% % 	[fgm2 bgm2] = learnModel(img,segs{i},fgm2,bgm2,fgk2,bgk2);
% % 	U_loc1 = cat(3,mask1,1-mask1) .* cat(3, segs{i}, 1-segs{i});
% % 	U_loc2 = cat(3,mask2,1-mask2) .* cat(3, segs{i}, 1-segs{i});
% % end;

% % if ~converged
% % %	pg_message('did not converge after %d iterations',maxIterations);
% % 	fprintf('did not converge after %d iterations\n',maxIterations);
% % end;

% % segs = segs(1:i);
% % flows = flows(1:i);
% % energies = energies(1:i);

% % seg = segs{end};
% % energy = energies(end);

% % if doMorph
% % 	seg = applyMorph(seg);
% % 	if doVisualize
% % 		visualize(img,mask,threshold,boxes,seg,energies);
% % 	end;
% % end;


% % function energy = getEnergy(A,T,labels)

% % energy = 0;
% % energy = energy + sum(T(labels==0,2));
% % energy = energy + sum(T(labels==1,1));
% % energy = energy + sum(sum(A(labels==0,labels==1)));


% % function [img h w] = getImage(img)

% % img = im2double(img);
% % assert(ndims(img)==3);

% % h = size(img,1);
% % w = size(img,2);
% % assert(size(img,3)==3);


% % function [fg bg] = initializeModel(img,mask)

% % % pg_message('initializeModel');

% % assert(any(mask(:)));
% % assert(any(~mask(:)));

% % img = reshape(img,[],3);

% % K = 5;

% % fg = pdf_gm.fit_using_vectorquantisation(img(mask,:),K);
% % bg = pdf_gm.fit_using_vectorquantisation(img(~mask,:),K);


% % function [fk bk] = assignComponents(img,fg,bg)

% % % pg_message('assignComponents');

% % fk = fg.cluster_2d(img);
% % bk = bg.cluster_2d(img);


% % function [fg bg] = learnModel(img,seg,fg,bg,fk,bk)

% % % pg_message('learnModel');

% % K = 5;

% % img = reshape(img,[],3);
% % seg = reshape(seg,[],1);
% % fk = reshape(fk,[],1);
% % bk = reshape(bk,[],1);

% % fg = pdf_gm.fit_given_labels(img(seg,:),fk(seg),K,fg);
% % bg = pdf_gm.fit_given_labels(img(~seg,:),bk(~seg),K,bg);


% % function [A K] = getPairwise(img)

% % % pg_message('getPairwise');

% % [h,w,~] = size(img);
% % n = h*w;

% % imgr = img(:,:,1); imgr = imgr(:);
% % imgg = img(:,:,2); imgg = imgg(:);
% % imgb = img(:,:,3); imgb = imgb(:);

% % % locations
% % [x,y] = meshgrid(1:w,1:h);
% % x = x(:); y = y(:);

% % % neighbors down -> y+1 -> idx+1
% % n1_i1 = 1:n; n1_i1 = n1_i1(y<h);
% % n1_i2 = n1_i1+1;

% % % neighbors right-down -> x+1,y+1 -> idx+1+h
% % n2_i1 = 1:n; n2_i1 = n2_i1(y<h & x<w);
% % n2_i2 = n2_i1+1+h;

% % % neighbors right -> x+1 -> idx+h
% % n3_i1 = 1:n; n3_i1 = n3_i1(x<w);
% % n3_i2 = n3_i1+h;

% % % neighbors right-up -> x+1,y-1 -> idx+h-1
% % n4_i1 = 1:n; n4_i1 = n4_i1(x<w & h>1);
% % n4_i2 = n4_i1+h-1;

% % from = [n1_i1 n2_i1 n3_i1 n4_i1];
% % to = [n1_i2 n2_i2 n3_i2 n4_i2];

% % gamma = 50; % TODO could be trained
% % invdis = 1./sqrt((x(from)-x(to)).^2+(y(from)-y(to)).^2);
% % dz2 = (imgr(from)-imgr(to)).^2 + (imgg(from)-imgg(to)).^2 + (imgb(from)-imgb(to)).^2;
% % beta = (2*mean(dz2.*invdis))^-1; % TODO changed, .*invdis is not in paper, but in gco
% % expb = exp(-beta*dz2);
% % c = gamma * invdis .* expb;

% % A = sparse([from to],[to from],[c c]); % TODO do i need to explicitely make it symmetric?

% % K = 1+max(sum(A,2)); % TODO changed, gco seems to have only half of this, not correct


% % function T = getUnary_app(img,fg,bg,fk,bk)

% % % pg_message('getUnary');

% % T = cat(3,fg.pdf_2d(img,fk),bg.pdf_2d(img,bk));


% % function U = getUnary(U_loc,U_app)

% % U = -log(U_loc .* U_app);
% % U = reshape(U,[],2);
% % U = sparse(U);


% % function [seg flow energy] = getSegmentation(P,U,w,h)

% % [flow labels] = maxflow(50*P,50*U);
% % seg = reshape(labels==1,h,w);
% % energy = getEnergy(P,U,labels);


% % function visualize(img,mask,threshold,seg,iteration,energies)

% % clf();

% % subplot2d(5,1,1,1);
% % plot_image(img,'image');

% % subplot2d(5,2,2,1);
% % plot_image(mask,'prior');

% % subplot2d(5,2,2,2);
% % plot_image(mask>=threshold,'init');

% % subplot2d(5,1,3,1);
% % plot_image(img.*repmat(double(seg),[1 1 3]),'foreground');

% % subplot2d(5,1,4,1);
% % plot_image(seg,'segmentation');

% % subplot2d(5,1,5,1);
% % plot(energies);
% % title('convergence');
% % ylabel('energy');
% % xlabel('iteration');

% % drawnow();


% % function seg = applyMorph(seg)

% % seg = imclose(seg,strel('disk',3));
% % seg = imfill(seg,'holes');
% % seg = bwmorph(seg,'open'); % remove thin regions
% % [~,N] = bwlabel(seg); % select largest 8-connected region
% % h = hist(seg(:),1:N);
% % [~,i] = max(h);
% % seg = seg==i;
