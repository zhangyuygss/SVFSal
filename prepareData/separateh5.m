function separateh5(h5weights_dir, originalnum)
    % roundnumber = 1;
	% basedir = ['/disk1/zhangyu/ICCV/masks/round' num2str(roundnumber) '/locweight/'];
	basedir = h5weights_dir;
	weigth224_txt = [basedir 'weight224.txt'];
	weigth112_txt = [basedir 'weight112.txt'];
	weigth56_txt = [basedir 'weight56.txt'];
	weigth28_txt = [basedir 'weight28.txt'];
	% originalnum = 3647;
	img_num = 25*originalnum;
	% 224 weights
	fid = fopen(weigth224_txt, 'w+');
	h5create([basedir 'weight224_1.h5'], '/weight224', [224 224 Inf], 'ChunkSize', [224 224 1]);
	fprintf(fid, '%s\r\n', [h5weights_dir 'weight224_1.h5']);
	count = 1;
	file = 1;
	count2 = 1;
	for i = 1:img_num
		filename = [basedir 'weight224_' num2str(file) '.h5'];
		data = h5read([basedir 'weight224.h5'], '/weight224', [1 1 count], [224 224 1]);
		count = count + 1;
	    tmpdata = zeros(224,224,1);
	    tmpdata(:,:,1) = data;
		h5write(filename, '/weight224', tmpdata, [1 1 count2], [224 224 1]);
		count2 = count2 + 1;
		if(~mod(i,4800))
			file = file+1;
			count2 = 1;
			tmp = [basedir 'weight224_' num2str(file) '.h5']
			h5create(tmp, '/weight224', [224 224 Inf], 'ChunkSize', [224 224 1]);
			fprintf(fid, '%s\r\n', [h5weights_dir 'weight224_' num2str(file) '.h5']);
		end
	end
	fclose(fid);
	delete([basedir 'weight224.h5']);

	% 112 weights
	fid = fopen(weigth112_txt, 'w+');
	h5create([basedir 'weight112_1.h5'], '/weight112', [112 112 Inf], 'ChunkSize', [112 112 1]);
	fprintf(fid, '%s\r\n', [h5weights_dir 'weight112_1.h5']);
	count = 1;
	file = 1;
	count2 = 1;
	for i = 1:img_num
		filename = [basedir 'weight112_' num2str(file) '.h5'];
		data = h5read([basedir 'weight112.h5'], '/weight112', [1 1 count], [112 112 1]);
		count = count + 1;
	    tmpdata = zeros(112,112,1);
	    tmpdata(:,:,1) = data;
		h5write(filename, '/weight112', tmpdata, [1 1 count2], [112 112 1]);
		count2 = count2 + 1;
		if(~mod(i,8000))
			file = file+1;
			count2 = 1;
			tmp = [basedir 'weight112_' num2str(file) '.h5']
			h5create(tmp, '/weight112', [112 112 Inf], 'ChunkSize', [112 112 1]);
			fprintf(fid, '%s\r\n', [h5weights_dir 'weight112_' num2str(file) '.h5']);
		end
	end
	fclose(fid);
	delete([basedir 'weight112.h5']);

	% 56 weights
	fid = fopen(weigth56_txt, 'w+');
	h5create([basedir 'weight56_1.h5'], '/weight56', [56 56 Inf], 'ChunkSize', [56 56 1]);
	fprintf(fid, '%s\r\n', [h5weights_dir 'weight56_1.h5']);
	count = 1;
	file = 1;
	count2 = 1;
	for i = 1:img_num
		filename = [basedir 'weight56_' num2str(file) '.h5'];
		data = h5read([basedir 'weight56.h5'], '/weight56', [1 1 count], [56 56 1]);
		count = count + 1;
	    tmpdata = zeros(56,56,1);
	    tmpdata(:,:,1) = data;
		h5write(filename, '/weight56', tmpdata, [1 1 count2], [56 56 1]);
		count2 = count2 + 1;
		if(~mod(i,15000))
			file = file+1;
			count2 = 1;
			tmp = [basedir 'weight56_' num2str(file) '.h5']
			h5create(tmp, '/weight56', [56 56 Inf], 'ChunkSize', [56 56 1]);
			fprintf(fid, '%s\r\n', [h5weights_dir 'weight56_' num2str(file) '.h5']);
		end
	end
	fclose(fid);
	delete([basedir 'weight56.h5']);

	% 28 weights
	fid = fopen(weigth28_txt, 'w+');
	h5create([basedir 'weight28_1.h5'], '/weight28', [28 28 Inf], 'ChunkSize', [28 28 1]);
	fprintf(fid, '%s\r\n', [h5weights_dir 'weight28_1.h5']);
	count = 1;
	file = 1;
	count2 = 1;
	for i = 1:img_num
		filename = [basedir 'weight28_' num2str(file) '.h5'];
		data = h5read([basedir 'weight28.h5'], '/weight28', [1 1 count], [28 28 1]);
		count = count + 1;
	    tmpdata = zeros(28,28,1);
	    tmpdata(:,:,1) = data;
		h5write(filename, '/weight28', tmpdata, [1 1 count2], [28 28 1]);
		count2 = count2 + 1;
		if(~mod(i,50000))
			file = file+1;
			count2 = 1;
			tmp = [basedir 'weight28_' num2str(file) '.h5']
			h5create(tmp, '/weight28', [28 28 Inf], 'ChunkSize', [28 28 1]);
			fprintf(fid, '%s\r\n', [h5weights_dir 'weight28_' num2str(file) '.h5']);
		end
	end
	fclose(fid);
	delete([basedir 'weight28.h5']);
end