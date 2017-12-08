# $1 roundnumber etc:'round1'
# LOG=/disk1/zhangyu/supervisionPAMI/log/train-$1-`date +%Y-%m-%d-%H-%M-%S`.log
LOG_DIR=$1
# mkdir LOG_DIR
LOG=$1$2`date +%Y-%m-%d-%H-%M-%S`.log
# /home/zhangyu/caffe-master/.build_release/tools/caffe train --solver=solver.prototxt \
# 	-snapshot /disk2/zhangyu/supervisionPAMI1/snap/round7/fintune_with_50p_davis_iter_58500.solverstate -gpu 0 \
# 	2>&1 | tee $LOG
	
# /home/zhangyu/caffe-master/.build_release/tools/caffe train --solver=solver.prototxt \
# 	-snapshot /disk1/zhangyu/supervisionPAMI/snap/round4/MSRA_finetune_r4_iter_12500.solverstate -gpu 0 \
# 	2>&1 | tee $LOG


/home/zhangyu/caffe-master/.build_release/tools/caffe train --solver=solver.prototxt \
	-weights /disk2/zhangyu/data/models/VGG_ILSVRC_16_layers.caffemodel -gpu 3 \
	2>&1 | tee $LOG
