#!/bin/bash
CORENUM=60
data_dir="/home2/jyh705/data/quesst14Database/"
list_dir="/home2/jyh705/data/quesst14Database/list/"
dev_list="quesst2014_dev_queries.list"
eval_list="quesst2014_eval_queries.list"

audio_list="quesst2014_audio.list"
scoring_dir="/home2/jyh705/data/quesst14Database/scoring/"
log_dir="./log/"
stage=1
tmp_dir="./tmp/"
out_dir="./out/"
result_dir="./result/"
export train_cmd="../script/slurm.pl"
for feature in ruspg_mono;
do
    if [ $stage -le 1 ]; then
        rm dev_queries/*.result
        #1_1 do normal DTW with query dev  with $feature 
        python ../script/split.py ${list_dir}${dev_list} $tmp_dir $CORENUM
        $train_cmd JOB=1:$CORENUM $log_dir/dtw_$feature.JOB.log \
            ./dtw_std $data_dir ${tmp_dir}${dev_list}JOB ${list_dir}${audio_list} ${feature} || exit 1

        #mv .result file to a new direction
        mkdir -p ${result_dir}/result_DTW_${feature}/dev_queries/
        mv ${data_dir}/dev_queries/*.result ${result_dir}/result_DTW_${feature}/dev_queries/
        echo "have done the quess14_dev DTW with feature: $feature"
    fi

    if [ $stage -le 2 ]; then
        #get std xml file, already get T1, T2, T3, alldev
        mkdir -p ${out_dir}/dev_out_DTW_${feature}/
        python ../script/stdlist_gen.py ${result_dir}/result_DTW_${feature}/ ${list_dir}${dev_list} 2.5959 ${out_dir}/dev_out_DTW_${feature}/
        #get the result awtv, mwtv, mxcn, axcn 

    fi

    if [ $stage -le 3 ]; then
        output_file=${out_dir}/dev_out_DTW_${feature}/score_all.out
        rm $output_file
        for q_type in dev_T1 dev_T2 dev_T3 dev; 
        do
            . ${scoring_dir}/score-TWV-Cnxe.sh ${out_dir}/dev_out_DTW_${feature}/ ${scoring_dir}/groundtruth_quesst14_${q_type}/ 0.1
            echo "${q_type}:" >> $output_file
            tail -n 2 ${out_dir}/dev_out_DTW_${feature}/score.out >> $output_file
            echo "" >> $output_file
            mkdir -p ${out_dir}/dev_out_DTW_${feature}/${q_type}
            mv ${out_dir}/dev_out_DTW_${feature}/score.out \
                ${out_dir}/dev_out_DTW_${feature}/DET.pdf \
                ${out_dir}/dev_out_DTW_${feature}/TWV.pdf ${out_dir}/dev_out_DTW_${feature}/${q_type}
        done
    fi
done

