%% visualize: function description
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
