clear;

% imgpath = '../data/img/';
imgpath = '../data/masks/round0/img/';
% glb_maskdir = '../data/mask224/';
% loc_maskdir = '../data/maskloc/';
img_txt = '../data/masks/round0/mean_img_list.txt';
% mask_txt_glb = '../data/mean_mask_list.txt';
% mask_txt_loc = '../data/unsupervised_locmask_list.txt';

fid = fopen(img_txt, 'w+');
img_namelist = dir([imgpath '*.jpg']);
for k = 1:length(img_namelist)
	image_name = [img_namelist(k).name, ' ', '0',];
	fprintf(fid, '%s\r\n', image_name);
end
fclose(fid);

% fid = fopen(mask_txt_glb, 'w+');
% img_namelist = dir([glb_maskdir '*.jpg']);
% for k = 1:length(img_namelist)
% 	image_name = [img_namelist(k).name, ' ', '0',];
% 	fprintf(fid, '%s\r\n', image_name);
% end
% fclose(fid);

% fid = fopen(mask_txt_loc, 'w+');
% img_namelist = dir([loc_maskdir '*.jpg']);
% for k = 1:length(img_namelist)
% 	image_name = [img_namelist(k).name, ' ', '0',];
% 	fprintf(fid, '%s\r\n', image_name);
% end
% fclose(fid);


% gtdir = '../data/gt/';
% gt_txt = '../data/gt_txt';
% fid = fopen(gt_txt, 'w+');
% img_namelist = dir([gtdir '*.jpg']);
% for k = 1:length(img_namelist)
% 	image_name = [img_namelist(k).name, ' ', '0',];
% 	fprintf(fid, '%s\r\n', image_name);
% end
% fclose(fid);