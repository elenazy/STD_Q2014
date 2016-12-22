#!/bin/bash
CORENUM=60
data_dir="/home2/jyh705/data/quesst14Database/"
list_dir="/home2/jyh705/data/quesst14Database/list/"
dev_list="quesst2014_dev_queries.list"
eval_list="quesst2014_eval_queries.list"
audio_list="quesst2014_audio.list"
scoring_dir=""
log_dir="./log/"
stage=1
export train_cmd="../script/slurm.pl"
for feature in czpg_mono;
do
	if [ $stage -le 1 ]; then
        rm dev_queries/*.result
	    #1_1 do normal DTW with query dev  with $feature 
        python ../script/split.py ${list_dir}${dev_list} $CORENUM
	    $train_cmd JOB=1:$CORENUM $log_dir/dtw_$feature.JOB.log \
            ./dtw_std $data_dir ${dev_list}JOB ${list_dir}${audio_list} ${feature} || exit 1

	    echo "have done the quess14_dev DTW with feature: $feature"
    fi

    if [ $stage -le 0 ]; then
	    #get std xml file, already get T1, T2, T3, alldev
	    mkdir -p ../scoring/out/DTW_${feature}_T1/
	    mkdir -p ../scoring/out/DTW_${feature}_T2/
	    mkdir -p ../scoring/out/DTW_${feature}_T3/
	    mkdir -p ../scoring/out/DTW_${feature}_dev/
	    
	    python stdlist_gen.py ../../list/quesst2015_dev_T1.list 2.5959 ../scoring/out/DTW_${feature}_T1/
	    python stdlist_gen.py ../../list/quesst2015_dev_T2.list 2.5959 ../scoring/out/DTW_${feature}_T2/
	    python stdlist_gen.py ../../list/quesst2015_dev_T3.list 2.5959 ../scoring/out/DTW_${feature}_T3/
	    python stdlist_gen.py ../../list/quesst2015_dev.list 2.5959 ../scoring/out/DTW_${feature}_dev/
	    #get the result awtv, mwtv, mxcn, axcn 
        . ../scoring/score-TWV-Cnxe.sh ../scoring/out/DTW_${feature}_T1/ ../scoring/groundtruth_quesst2015_dev_T1/ 0.1
	    . ../scoring/score-TWV-Cnxe.sh ../scoring/out/DTW_${feature}_T2/ ../scoring/groundtruth_quesst2015_dev_T2/ 0.1
	    . ../scoring/score-TWV-Cnxe.sh ../scoring/out/DTW_${feature}_T3/ ../scoring/groundtruth_quesst2015_dev_T3/ 0.1
	    . ../scoring/score-TWV-Cnxe.sh ../scoring/out/DTW_${feature}_dev/ ../scoring/groundtruth_quesst2015_dev/ 0.1
	    #mv .result file to a new direction
	    mkdir -p ../dev_result_DTW_${feature}/
	    mv ../data/QUESST2015-dev/dev_queries/*.result ../dev_result_DTW_${feature}/
    fi
done

