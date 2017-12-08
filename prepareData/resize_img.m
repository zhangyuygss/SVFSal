% function resize_img(roundnumber)
	%Add images and masks for training, images are 
	%converted from mask10
	%images are converted into 224x224 to feed the net
	%masks are converted into 28x28 56x56 112x112 224x224
function resize_img(maskdir)
    % roundnumber = 1;
    % maskdir = ['/disk1/zhangyu/ICCV/masks/round' num2str(roundnumber) 'glb/'];
	maskList = dir([maskdir 'mask224/*png']);
	mask28dir = [maskdir 'mask28/'];
	mask56dir = [maskdir 'mask56/'];
	mask112dir = [maskdir 'mask112/'];
	mkdir(mask28dir);
	mkdir(mask56dir);
	mkdir(mask112dir);

	for idx = 1:length(maskList)
		if(~mod(idx,2000))
			disp(idx);
		end
		mask = imread([maskdir 'mask224/', maskList(idx).name]);
		mask28 = imresize(mask,[28,28]);
		mask56 = imresize(mask,[56,56]);
		mask112 = imresize(mask,[112,112]);
		imwrite(mask28, strcat(mask28dir, maskList(idx).name));
		imwrite(mask56, strcat(mask56dir, maskList(idx).name));
		imwrite(mask112, strcat(mask112dir, maskList(idx).name));
    end
end
	% imglist = dir(['../data/img/*jpg']);
	% loc_maskList = dir('../data/maskloc/*jpg');
	% glb_maskList = dir('../data/maskglb/*jpg');
	% mkdir('../data/mask28loc/');
	% mkdir('../data/mask56loc/');
	% mkdir('../data/mask112loc/');
	% mkdir('../data/mask28glb/');
	% mkdir('../data/mask56glb/');
	% mkdir('../data/mask112glb/');
	% mask28loc = '../data/mask28loc/';
	% mask56loc = '../data/mask56loc/';
	% mask112loc = '../data/mask112loc/';
	% mask28glb = '../data/mask28glb/';
	% mask56glb = '../data/mask56glb/';
	% mask112glb = '../data/mask112glb/';


	% for idx = 1:length(loc_maskList)
	% 	if(~mod(idx,2000))
	% 		disp(idx);
	% 	end
	% 	mask = imread(['../data/maskloc/', loc_maskList(idx).name]);
	% 	mask28 = imresize(mask,[28,28]);
	% 	mask56 = imresize(mask,[56,56]);
	% 	mask112 = imresize(mask,[112,112]);
	% 	% mask224 = imresize(mask,[224,224]);
	% 	imwrite(mask28, strcat(mask28loc, loc_maskList(idx).name));
	% 	imwrite(mask56, strcat(mask56loc, loc_maskList(idx).name));
	% 	imwrite(mask112, strcat(mask112loc, loc_maskList(idx).name));
	% end
	% disp(['idx_gt:', num2str(idx)]);

	% for idx = 1:length(glb_maskList)
	% 	if(~mod(idx,2000))
	% 		disp(idx);
	% 	end
	% 	mask = imread(['../data/maskglb/', glb_maskList(idx).name]);
	% 	mask28 = imresize(mask,[28,28]);
	% 	mask56 = imresize(mask,[56,56]);
	% 	mask112 = imresize(mask,[112,112]);
	% 	% mask224 = imresize(mask,[224,224]);
	% 	imwrite(mask28, strcat(mask28glb, glb_maskList(idx).name));
	% 	imwrite(mask56, strcat(mask56glb, glb_maskList(idx).name));
	% 	imwrite(mask112, strcat(mask112glb, glb_maskList(idx).name));
	% end
	% disp(['idx_gt:', num2str(idx)]);

	% gtList = dir('../data/gt/*jpg');

	% mkdir('../data/gt28/');
	% mkdir('../data/gt56/');
	% mkdir('../data/gt112/');
	% gt28 = '../data/gt28/';
	% gt56 = '../data/gt56/';
	% gt112 = '../data/gt112/';
	% for idx = 1:length(gtList)
	% 	if(~mod(idx,2000))
	% 		disp(idx);
	% 	end
	% 	mask = imread(['../data/gt/', gtList(idx).name]);
	% 	mask28 = imresize(mask,[28,28]);
	% 	mask56 = imresize(mask,[56,56]);
	% 	mask112 = imresize(mask,[112,112]);
	% 	imwrite(mask28, strcat(gt28, gtList(idx).name));
	% 	imwrite(mask56, strcat(gt56, gtList(idx).name));
	% 	imwrite(mask112, strcat(gt112, gtList(idx).name));
	% end
	% disp(['idx_gt:', num2str(idx)]);


% end