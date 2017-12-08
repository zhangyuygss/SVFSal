echo "Creating leveldb..."
TOOLS=/home/zhangyu/caffe-master/.build_release/tools

GLOG_logtostderr=1

# mkdir $2

$TOOLS/convert_imageset.bin   -backend="leveldb" $1img/ \
 	$1mean_img_list.txt  	 $2val_imgmean_leveldb
$TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  $1mask28/ \
	$1mean_mask_list.txt   $2val_mask28mean_leveldb
$TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  $1mask56/ \
	$1mean_mask_list.txt   $2val_mask56mean_leveldb
$TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  $1mask112/ \
	$1mean_mask_list.txt   $2val_mask112mean_leveldb
$TOOLS/convert_imageset.bin   -gray=true -backend="leveldb"  $1mask224/ \
	$1mean_mask_list.txt  $2val_mask224mean_leveldb

