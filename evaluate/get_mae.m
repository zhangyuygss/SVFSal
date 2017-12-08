function MAE = get_mae(GT,salmap)
	if(max(max(salmap)) > 1)
		salmap = salmap/255;
	end
	if(max(max(GT)) > 1)
		GT = GT/255;
	end
	MAE = mean2(abs(double(GT) - salmap));



% for i = 1:imNum
%   imName = dir_tr(i).name;
%   input_im = imread([resultpath(1:end-5),imName(1:end-4),resultpath(end-3:end)]);
%   input_im = double(input_im(:,:,1))./255;
%   truth_im = imread([truthpath(1:end-5),imName]);
%   truth_im = double(truth_im(:,:,1));
%   if max(max(truth_im))==255
%         truth_im = truth_im./255;
%   end
%   MAE = MAE + mean2(abs(truth_im-input_im));
%   display(num2str(i));
% end