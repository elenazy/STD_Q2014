keyword_dir=/home2/jyh705/feature/TIMIT_STD/KEYWORD_TEST/
keyword_list=../lists/timit_test_keyword_all.list
utterance_dir=/home2/jyh705/feature/TIMIT_STD/TEST/
utterance_list=../lists/timit_test.list
model_type=BLSTMP
tag="_3lstm_1dnn"
loss_type=frame #frame # boundary

truncated=0
keyword_sampling_type="uniform_mean"
utterance_sampling_type="uniform_mean"

nj=18
result_dir_list=""
for i in `seq 3`; do
    left_encode_num=$((i+2))
    right_encode_num=$((i+1))
    feature_type=${model_type}${tag}_${loss_type}_${left_encode_num}_${right_encode_num}
    distance_type="KL-divergence" # cosine | KL-divergence
    result_dir="/home2/jyh705/feature/TIMIT_STD/KEYWORD_TEST/result_${feature_type}_${distance_type}/"
    result_dir_list="$result_dir_list $result_dir"
    echo "python Encode_STD_v2/std.py $keyword_dir $keyword_list $utterance_dir $utterance_list $left_encode_num $right_encode_num $feature_type $distance_type $keyword_sampling_type $utterance_sampling_type $result_dir $truncated"
    mkdir ${result_dir}
    python script/split.py $keyword_list $nj
    for JOB in `seq $nj`; do
    {
        python Encode_STD_v2/std.py $keyword_dir timit_test_keyword_all.list${JOB} $utterance_dir $utterance_list \
            $left_encode_num $right_encode_num $feature_type $distance_type $keyword_sampling_type \
            $utterance_sampling_type $result_dir $truncated
        rm timit_test_keyword_all.list${JOB}
    } &
    done
    wait
done

# chose the RESULT file according to the lenght of query
fusion_result_dir="/home2/jyh705/feature/TIMIT_STD/KEYWORD_TEST/result_multi_${model_type}${tag}_${loss_type}/"
mkdir -p ${fusion_result_dir}
echo "python Encode_STD_v2/SelectResult.py ${result_dir_list} ${fusion_result_dir}"
python Encode_STD_v2/SelectResult.py  ${keyword_dir} ${keyword_list} ${result_dir_list} ${fusion_result_dir}

echo "Ealuating $fusion_result_dir"
python script/evaluation.py ${fusion_result_dir} ${keyword_list} ../TEST/ $utterance_list



