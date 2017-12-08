#!/usr/bin/env sh
# Create the leveldb inputs
# $1: Directory of masks
# $2: Directory of leveldb files
echo "Creating leveldb..."
TOOLS=/home/zhangyu/caffe-master/.build_release/tools

GLOG_logtostderr=1

# mkdir $2

$TOOLS/convert_imageset.bin   -backend="leveldb" $1img/ \
 	$1mean_img_list.txt  	 $2train_imgmean_leveldb
$TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  $1mask28/ \
	$1mean_mask_list.txt   $2train_mask28mean_leveldb
$TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  $1mask56/ \
	$1mean_mask_list.txt   $2train_mask56mean_leveldb
$TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  $1mask112/ \
	$1mean_mask_list.txt   $2train_mask112mean_leveldb
$TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  $1mask224/ \
	$1mean_mask_list.txt  $2train_mask224mean_leveldb


# mkdir /disk1/zhangyu/ICCV/snap/comptest/round$3
# $TOOLS/convert_imageset.bin   -backend="leveldb" ../data/img/ \
# 	../data/unsupervised_img_list.txt  	 ../data/leveldb/train_img_leveldb
# $TOOLS/convert_imageset.bin   -gray=true  -backend="leveldb"  ../data/mask28loc/ \
# 	../data/unsupervised_locmask_list.txt   ../data/leveldb/loc_glb/train_mask28loc_leveldb
# $TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  ../data/mask56loc/ \
# 	../data/unsupervised_locmask_list.txt   ../data/leveldb/loc_glb/train_mask56loc_leveldb
# $TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  ../data/mask112loc/ \
# 	../data/unsupervised_locmask_list.txt   ../data/leveldb/loc_glb/train_mask112loc_leveldb
# $TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  ../data/maskloc/ \
# 	../data/unsupervised_locmask_list.txt  ../data/leveldb/loc_glb/train_mask224loc_leveldb

# $TOOLS/convert_imageset.bin   -gray=true  -backend="leveldb"  ../data/mask28glb/ \
# 	../data/unsupervised_glbmask_list.txt   ../data/leveldb/loc_glb/train_mask28glb_leveldb
# $TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  ../data/mask56glb/ \
# 	../data/unsupervised_glbmask_list.txt   ../data/leveldb/loc_glb/train_mask56glb_leveldb
# $TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  ../data/mask112glb/ \
# 	../data/unsupervised_glbmask_list.txt   ../data/leveldb/loc_glb/train_mask112glb_leveldb
# $TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  ../data/maskglb/ \
# 	../data/unsupervised_glbmask_list.txt  ../data/leveldb/loc_glb/train_mask224glb_leveldb

# $TOOLS/convert_imageset.bin	-backend="leveldb"	   /home/zhangyu/data/DHS-data/test/img/ \
# 	/home/zhangyu/data/DHS-data/test_img_list.txt  	 /home/zhangyu/data/DHS-data/leveldb/test_img_leveldb
# $TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  /home/zhangyu/data/DHS-data/test/mask28/  \
# 	/home/zhangyu/data/DHS-data/test_msk28_list.txt   /home/zhangyu/data/DHS-data/leveldb/test_mask28_leveldb
# $TOOLS/convert_imageset.bin   -gray=true  -backend="leveldb" /home/zhangyu/data/DHS-data/test/mask56/  \
# 	/home/zhangyu/data/DHS-data/test_msk56_list.txt   /home/zhangyu/data/DHS-data/leveldb/test_mask56_leveldb
# $TOOLS/convert_imageset.bin   -gray=true  -backend="leveldb" /home/zhangyu/data/DHS-data/test/mask112/ \
# 	/home/zhangyu/data/DHS-data/test_msk112_list.txt  /home/zhangyu/data/DHS-data/leveldb/test_mask112_leveldb
# $TOOLS/convert_imageset.bin   -gray=true  -backend="leveldb" /home/zhangyu/data/DHS-data/test/mask224/ \
# 	/home/zhangyu/data/DHS-data/test_msk224_list.txt  /home/zhangyu/data/DHS-data/leveldb/test_mask224_leveldb

echo "Done.~~~~~~~"