## Supervision by Fusion: Towards Unsupervised Learning of Deep Salient Object Detector

### What's new
We add a Pytorch inference demo for Pytorch users!
We convert the caffe inference prototxt and weights into pytorch model.
The conversion codes are modified from 
[caffemodel2pytorch](https://github.com/vadimkantorov/caffemodel2pytorch).

#### Usage
Change the image directory in *demo_pytorch.py*, them run the script,
you'll get saliency maps in `data/output`.


Read our paper [here](http://openaccess.thecvf.com/content_ICCV_2017/papers/Zhang_Supervision_by_Fusion_ICCV_2017_paper.pdf) .

![Arch](https://zhangyuygss.github.io/uploads/SVFSal_Arch.png)

### Requirements

+ Make sure you have installed caffe and matcaffe to run the demo code.
+ Since the training procedure contains a modified loss layer, if you want to run codes of training part, you'll have to install this modified [caffe](https://github.com/zhangyuygss/caffe-modified) version. 

### Installation and demo

1. Clone the repository

   `git clone https://github.com/zhangyuygss/SVFSal.caffe.git  `

2. `cd` into the directory you cloned, let's call it `SVFS_ROOT`

3. Download our pretrained caffemodel, put it into `SVFS_ROOT/data`.

   You can download the pretrained model from [here](https://drive.google.com/open?id=1zwXvBkaGcGxyYfE_K9zfa69K2npdZbIx).

4. Modify *caffe path* in file *demo.m*:

   Change this line:

   `addpath(genpath('/your/path/caffe-master/matlab/'));`

   to your own *caffe path*.

5. Run `demo.m`

   After running demo code, you should find the output saliency map from `SVFS_ROOT/data/output`. Put your images into `SVFS_ROOT/data/images` if you want to run on your own dataset.

   If you would like to download our saliency map results, you can also find them [here](https://drive.google.com/open?id=1U04GTkN7KkNFDgT4iUqspJote7QYqGiG) via google drive or [here](https://pan.baidu.com/s/1gfCOxkJ).

### Training and evaluation

+ Script `prepare_and_train.m` contains one round training of our framework, it calls corresponding script to do fusion, data preparation and start training. However, we don't recommend you to run training procedure since the codes are not well modified and you have to change some path in the script to make it run on your machine. We only release the training part as a reference for you if you want to check some details in the codes.
+ Evaluation code can be found in `SVFS_ROOT/evaluate/evaluate_net.m`, also the code serves as a reference. If you have any question about the codes, feel free to ask me.

### Citation

Cite our paper with:

```bibtex
@article{zhang2019synthesizing,
  title={Synthesizing supervision for learning deep saliency network without human annotation},
  author={Zhang, Dingwen and Han, Junwei and Zhang, Yu and Xu, Dong},
  journal={IEEE transactions on pattern analysis and machine intelligence},
  volume={42},
  number={7},
  pages={1755--1769},
  year={2019},
  publisher={IEEE}
}
@INPROCEEDINGS{DZhang2017SVFSal,
	author = {Dingwen, Zhang and Junwei, Han and Yu, Zhang},
	title = {Supervision by fusion: towards unsupervised learning of deep salient object detector},
	booktitle = {ICCV},
	year = {2017}
}
```

