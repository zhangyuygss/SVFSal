% function data_enhance(maskpath,maskpath_save,roundnumber)
roundnumber  =1;
maskpath_save = ['/disk1/zhangyu/ICCV/masks/round' num2str(roundnumber) '/mask224/'];
	savePath = ['/disk1/zhangyu/ICCV/selectedSal/round' num2str(roundnumber) '/'];
maskpath = [savePath 'meanSal/'];

    load(['/disk1/zhangyu/ICCV/EmRst/loc_weight' num2str(roundnumber) '.mat']);
    database = {'MSRA10K'};
    imgsiz = 224;
    masksiz = 224;
    basedir = ['/disk1/zhangyu/ICCV/masks/round' num2str(roundnumber) '/'];
    mkdir([basedir 'locweight/']);
    imgpath_save = [basedir 'img/'];
    mkdir(imgpath_save);
    methods={'hflip','crop','rotate'};%crop with zoom-out
    paras={{[1,-1]},{{'whole','up','down','left','right','middle'}},{[0]}};
    cropFrac=0.2;
    pad=1;
    imgnum = 0;

    img_txt = [basedir 'mean_img_list.txt'];
    mask_txt = [basedir 'mean_mask_list.txt'];
    h5create([basedir 'locweight/weight28.h5'],'/weight28',[28 28 Inf], 'ChunkSize', [28 28 1]);
    h5create([basedir 'locweight/weight56.h5'],'/weight56',[56 56 Inf], 'ChunkSize', [56 56 1]);
    h5create([basedir 'locweight/weight112.h5'],'/weight112',[112 112 Inf], 'ChunkSize', [112 112 1]);
    h5create([basedir 'locweight/weight224.h5'],'/weight224',[224 224 Inf], 'ChunkSize', [224 224 1]);

    fid = fopen(img_txt, 'w+');
    fid1 = fopen(mask_txt, 'w+');
    cnt = 1;
    for i = 1:length(database)
        imgpath = ['/disk1/zhangyu/ICCV/selectedSal/round' num2str(roundnumber) '/img/'];
        imglist = dir(imgpath);
        masklist = dir(maskpath);
        for idx = 3:length(masklist)
            imgname = masklist(idx).name;
            lw = loc_weight([imgname(1:end-4) '.jpg']);
            img = imread([imgpath imgname(1:end-4) '.jpg']);

            mask = imread(strcat(maskpath, imgname(1:end-4), '.png'));
            % 转换成double类型，不然后面无法处理
            img224 = im2double(imresize(img,[imgsiz,imgsiz]));
            mask224 = imresize(mask,[masksiz,masksiz]);
            mask224 = mat2gray(double(mask224)/255);
            % imwrite(img224,strcat(imgpath_save,imgname(1:end-4),'224.jpg'));
            % imwrite(mask224,strcat(maskpath_save,imgname(1:end-4),'224.png'));
            wtmp1 = imresize(lw,[masksiz, masksiz]);
            h5write([basedir 'locweight/weight224.h5'],'/weight224', wtmp1, [1 1 cnt], [masksiz masksiz 1]);
            h5write([basedir 'locweight/weight112.h5'],'/weight112', imresize(wtmp1, [112 112]), [1 1 cnt], [112 112 1]);
            h5write([basedir 'locweight/weight56.h5'],'/weight56', imresize(wtmp1, [56 56]), [1 1 cnt], [56 56 1]);
            h5write([basedir 'locweight/weight28.h5'],'/weight28', imresize(wtmp1, [28 28]), [1 1 cnt], [28 28 1]);
            cnt = cnt+1;
            % fprintf(fid, '%s\r\n', [imgname(1:end-4),'224.jpg', ' ', '0']);
            % fprintf(fid1, '%s\r\n', [imgname(1:end-4),'224.png', ' ', '0']);
            hflip_ornot = paras{1}{1};
            for h = 1:length(hflip_ornot)
                if hflip_ornot(h)==1
                    imgstep1 = img224;
                    maskstep1 = mask224;
                    wstep1 = wtmp1;
                elseif hflip_ornot(h)==-1
                    imgstep1 = img224(:,end:-1:1,:);
                    maskstep1 = mask224(:,end:-1:1,:);
                    wstep1 = wtmp1(:,end:-1:1,:);
                end
                crop_method = paras{2}{1};
                for c = 1:length(crop_method)
                    imgstep2 = imgcrop(imgstep1,crop_method{c},cropFrac,pad,'img');
                    maskstep2 = imgcrop(maskstep1,crop_method{c},cropFrac,pad,'mask');
                    wstep2 = imgcrop(wstep1,crop_method{c},cropFrac,pad,'mask');
                    for t = 1:length(imgstep2)
                        imgtmp = imgstep2{t};
                        imgnum = imgnum +1;
                        if(~mod(imgnum,1000))
                            disp(imgnum);
                        end
                        masktmp = maskstep2{t};
                        wtmp2 = wstep2{t};
                        % imwrite(imgtmp,strcat(imgpath_save,database{i},'_',imgname(1:end-4),'_',num2str(imgnum),'.jpg'));
                        % imwrite(masktmp,strcat(maskpath_save,database{i},'_',imgname(1:end-4),'_',num2str(imgnum),'.png'));
                        h5write([basedir 'locweight/weight224.h5'],'/weight224', wtmp2, [1 1 cnt], [masksiz masksiz 1]);
                        h5write([basedir 'locweight/weight112.h5'],'/weight112', imresize(wtmp2, [112 112]), [1 1 cnt], [112 112 1]);
                        h5write([basedir 'locweight/weight56.h5'],'/weight56', imresize(wtmp2, [56 56]), [1 1 cnt], [56 56 1]);
                        h5write([basedir 'locweight/weight28.h5'],'/weight28', imresize(wtmp2, [28 28]), [1 1 cnt], [28 28 1]);
                        cnt = cnt +1;
                        % fprintf(fid, '%s\r\n', [database{i},'_',imgname(1:end-4),'_',num2str(imgnum),'.jpg', ' ', '0']);
                        % fprintf(fid1, '%s\r\n', [database{i},'_',imgname(1:end-4),'_',num2str(imgnum),'.png', ' ', '0']);
                    end
                end
            end
        end
    end
    fclose(fid);
% end

load(['/disk1/zhangyu/ICCV/EmRst/fulglb_weight' num2str(roundnumber) '.mat']);
    database = {'MSRA10K'};
    imgsiz = 224;
    masksiz = 224;
    basedir = ['/disk1/zhangyu/ICCV/masks/round' num2str(roundnumber) '/'];
    mkdir([basedir 'glbweight/']);
    imgpath_save = [basedir 'img/'];
    mkdir(imgpath_save);
    methods={'hflip','crop','rotate'};%crop with zoom-out
    paras={{[1,-1]},{{'whole','up','down','left','right','middle'}},{[0]}};
    cropFrac=0.2;
    pad=1;
    imgnum = 0;

    img_txt = [basedir 'mean_img_list.txt'];
    mask_txt = [basedir 'mean_mask_list.txt'];
    h5create([basedir 'glbweight/weight28.h5'],'/weight28',[28 28 Inf], 'ChunkSize', [28 28 1]);
    h5create([basedir 'glbweight/weight56.h5'],'/weight56',[56 56 Inf], 'ChunkSize', [56 56 1]);
    h5create([basedir 'glbweight/weight112.h5'],'/weight112',[112 112 Inf], 'ChunkSize', [112 112 1]);
    h5create([basedir 'glbweight/weight224.h5'],'/weight224',[224 224 Inf], 'ChunkSize', [224 224 1]);

    fid = fopen(img_txt, 'w+');
    fid1 = fopen(mask_txt, 'w+');
    cnt = 1;
    for i = 1:length(database)
        imgpath = ['/disk1/zhangyu/ICCV/selectedSal/round' num2str(roundnumber) '/img/'];
        imglist = dir(imgpath);
        masklist = dir(maskpath);
        for idx = 3:length(masklist)
            imgname = masklist(idx).name;
            lw = fulglb_weight([imgname(1:end-4) '.jpg']);
            img = imread([imgpath imgname(1:end-4) '.jpg']);

            mask = imread(strcat(maskpath, imgname(1:end-4), '.png'));
            % 转换成double类型，不然后面无法处理
            img224 = im2double(imresize(img,[imgsiz,imgsiz]));
            mask224 = imresize(mask,[masksiz,masksiz]);
            mask224 = mat2gray(double(mask224)/255);
            % imwrite(img224,strcat(imgpath_save,imgname(1:end-4),'224.jpg'));
            % imwrite(mask224,strcat(maskpath_save,imgname(1:end-4),'224.png'));
            wtmp1 = imresize(lw,[masksiz, masksiz]);
            h5write([basedir 'glbweight/weight224.h5'],'/weight224', wtmp1, [1 1 cnt], [masksiz masksiz 1]);
            h5write([basedir 'glbweight/weight112.h5'],'/weight112', imresize(wtmp1, [112 112]), [1 1 cnt], [112 112 1]);
            h5write([basedir 'glbweight/weight56.h5'],'/weight56', imresize(wtmp1, [56 56]), [1 1 cnt], [56 56 1]);
            h5write([basedir 'glbweight/weight28.h5'],'/weight28', imresize(wtmp1, [28 28]), [1 1 cnt], [28 28 1]);
            cnt = cnt+1;
            % fprintf(fid, '%s\r\n', [imgname(1:end-4),'224.jpg', ' ', '0']);
            % fprintf(fid1, '%s\r\n', [imgname(1:end-4),'224.png', ' ', '0']);
            hflip_ornot = paras{1}{1};
            for h = 1:length(hflip_ornot)
                if hflip_ornot(h)==1
                    imgstep1 = img224;
                    maskstep1 = mask224;
                    wstep1 = wtmp1;
                elseif hflip_ornot(h)==-1
                    imgstep1 = img224(:,end:-1:1,:);
                    maskstep1 = mask224(:,end:-1:1,:);
                    wstep1 = wtmp1(:,end:-1:1,:);
                end
                crop_method = paras{2}{1};
                for c = 1:length(crop_method)
                    imgstep2 = imgcrop(imgstep1,crop_method{c},cropFrac,pad,'img');
                    maskstep2 = imgcrop(maskstep1,crop_method{c},cropFrac,pad,'mask');
                    wstep2 = imgcrop(wstep1,crop_method{c},cropFrac,pad,'mask');
                    for t = 1:length(imgstep2)
                        imgtmp = imgstep2{t};
                        imgnum = imgnum +1;
                        if(~mod(imgnum,1000))
                            disp(imgnum);
                        end
                        masktmp = maskstep2{t};
                        wtmp2 = wstep2{t};
                        % imwrite(imgtmp,strcat(imgpath_save,database{i},'_',imgname(1:end-4),'_',num2str(imgnum),'.jpg'));
                        % imwrite(masktmp,strcat(maskpath_save,database{i},'_',imgname(1:end-4),'_',num2str(imgnum),'.png'));
                        h5write([basedir 'glbweight/weight224.h5'],'/weight224', wtmp2, [1 1 cnt], [masksiz masksiz 1]);
                        h5write([basedir 'glbweight/weight112.h5'],'/weight112', imresize(wtmp2, [112 112]), [1 1 cnt], [112 112 1]);
                        h5write([basedir 'glbweight/weight56.h5'],'/weight56', imresize(wtmp2, [56 56]), [1 1 cnt], [56 56 1]);
                        h5write([basedir 'glbweight/weight28.h5'],'/weight28', imresize(wtmp2, [28 28]), [1 1 cnt], [28 28 1]);
                        cnt = cnt +1;
                        % fprintf(fid, '%s\r\n', [database{i},'_',imgname(1:end-4),'_',num2str(imgnum),'.jpg', ' ', '0']);
                        % fprintf(fid1, '%s\r\n', [database{i},'_',imgname(1:end-4),'_',num2str(imgnum),'.png', ' ', '0']);
                    end
                end
            end
        end
    end
    fclose(fid);


run('separateh5.m');
run('s5.m');


function imgC=imgcrop(img,manner,cropFrac,pad,flag)
    siz1=size(img,1);
    siz2=size(img,2);
    switch flag
        case 'img'
            padPixel(1,1,:) = [123.68, 116.779, 103.939]./255;
        case 'mask'
            padPixel=0;
    end
    padImg=repmat(padPixel,[siz1,siz1,1]);

    switch manner
        case 'whole'
            idx1=round(0.5*cropFrac*siz1):round((1-0.5*cropFrac)*siz1);
            idx2=round(0.5*cropFrac*siz2):round((1-0.5*cropFrac)*siz2);
        case 'up'
            idx1=1:round((1-cropFrac)*siz1);
            idx2=1:siz2;
        case 'down'
            idx1=round(cropFrac*siz1):siz1;
            idx2=1:siz2;
        case 'left'
            idx2=1:round((1-cropFrac)*siz2);
            idx1=1:siz1;
        case 'right'
            idx2=round(cropFrac*siz2):siz2;
            idx1=1:siz1;
        case 'middle'
            idx1=round(0.5*cropFrac*siz1):round((1-0.5*cropFrac)*siz1);
            idx2=round(0.5*cropFrac*siz2):round((1-0.5*cropFrac)*siz2);
        otherwise
            disp('Invalid crop manner!');
            return
    end
    switch manner
        case 'whole'
            imgC{1}=img;
        otherwise
            imgC{1}=imresize(img(idx1,idx2,:),[siz1,siz2]);
    end
    if pad
        switch manner
            case 'whole'
                padImg(idx1,idx2,:)=imresize(img,[numel(idx1),numel(idx1)]);
            otherwise
                padImg(idx1,idx2,:)=img(idx1,idx2,:);
        end
        imgC{2}=padImg;
    end
end