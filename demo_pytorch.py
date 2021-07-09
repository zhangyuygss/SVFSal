"""
Pytorch version inference code of SVFSal
The conversion codes modified from https://github.com/vadimkantorov/caffemodel2pytorch
"""
import torch
from caffe2pt import caffemodel2pytorch
import numpy as np 
import os 
import cv2

def prepare_img(img):
	mean = np.array([103.939, 116.779, 123.68])
	img = cv2.resize(img, (224, 224)) - mean
	img = torch.from_numpy(img).permute(2, 0, 1).unsqueeze(0).float().cuda()
	return img


model = caffemodel2pytorch.Net(
	prototxt = 'models/supervision_model/SVFSal_deploy.prototxt',
	weights = 'data/SVFSal_round5_iter_34500.caffemodel',
	caffe_proto = 'https://raw.githubusercontent.com/BVLC/caffe/master/src/caffe/proto/caffe.proto'
)
model.cuda()
model.eval()
torch.set_grad_enabled(False)

img_root = 'data/images'
im_list = os.listdir(img_root)
for im_name in im_list:
	im_dir = os.path.join(img_root, im_name)
	im = cv2.imread(im_dir)
	input = prepare_img(im)
	saliency = model(input)['RCL1_sm'].squeeze().cpu().numpy() * 255
	saliency = cv2.resize(saliency, (im.shape[1], im.shape[0]))
	cv2.imwrite('data/output/{}.png'.format(im_name.split('.')[0]), saliency)
	