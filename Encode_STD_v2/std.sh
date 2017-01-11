train_cmd="../script/slurm.pl --exclude=node01"
CORENUM=60
data_dir="/home2/jyh705/data/quesst14Database/"
list_dir="/home2/jyh705/data/quesst14Database/list/"
dev_list="quesst2014_dev_queries.list"
eval_list="quesst2014_eval_queries.list"
audio_list="quesst2014_audio.list"
scoring_dir="/home2/jyh705/data/quesst14Database/scoring/"

model_type=BLSTMP_frame
tag="_3lstm_1dnn"
loss_type=frame #frame # boundary
left_encode_num=4
right_encode_num=3
truncated=0 #0 | 1
keyword_sampling_type="uniform_mean"
utterance_sampling_type="uniform_mean"


tmp_dir="./tmp/"
out_dir="./out/"
log_dir="./log/"
mkdir -p $tmp_dir $out_dir $log_dir
feature_type=${model_type}${tag}_${loss_type}_${left_encode_num}_${right_encode_num}
distance_type="KL-divergence" # cosine | KL-divergence

result_dir="./result/result_encode_${feature_type}_${keyword_sampling_type}_${utterance_sampling_type}_${truncated}/"

stage=1
# std
if [ $stage -le 1 ]; then
    mkdir -p $result_dir/dev_queries/

    python ../script/split.py ${list_dir}${dev_list} $tmp_dir $CORENUM    
    $train_cmd JOB=1:$CORENUM ${log_dir}/encode_${feature_type}.JOB.log \
        python std.py ${data_dir} ${tmp_dir}${dev_list}JOB ${data_dir} ${list_dir}${audio_list} \
            $left_encode_num $right_encode_num $feature_type $distance_type $keyword_sampling_type \
            $utterance_sampling_type $result_dir $truncated
    rm ${tmp_dir}/${dev_list}*
fi

# evaluate
if [ $stage -le 2 ]; then
     output_dir_dev=${out_dir}/dev_out_encode_${feature_type}_${keyword_sampling_type}_${utterance_sampling_type}_${truncated}
     mkdir -p ${output_dir_dev}/
     python ../script/stdlist_gen.py ${result_dir} ${list_dir}${dev_list} 2.5959 ${output_dir_dev}/
fi

# scoring

if [ $stage -le 3 ]; then
    output_dir_dev=${out_dir}/dev_out_encode_${feature_type}_${keyword_sampling_type}_${utterance_sampling_type}_${truncated}
    output_file=$output_dir_dev/score_all.out
    rm $output_file
    for q_type in dev_T1 dev_T2 dev_T3 dev;
    do
        . ${scoring_dir}/score-TWV-Cnxe.sh ${output_dir_dev}/ ${scoring_dir}/groundtruth_quesst14_${q_type}/ 0.1
        echo "${q_type}:" >> $output_file
        tail -n 2 ${output_dir_dev}/score.out >> $output_file
        echo "" >> $output_file
        mkdir -p ${output_dir_dev}/${q_type}
        mv ${output_dir_dev}/score.out \
            ${output_dir_dev}/dev_out_DTW_${feature}/DET.pdf \
            ${output_dir_dev}/dev_out_DTW_${feature}/TWV.pdf ${output_dir_dev}/${q_type}
    done

fi
