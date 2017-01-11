Core_NUM=20
data_dir="/home2/jyh705/data/quesst14Database/"
data_list_dir="/home2/jyh705/data/quesst14Database/list/"
data_list="quesst2014_all.list"

PHONE_NUM=43
left_encode_num=4
right_encode_num=3
model_type="BLSTMP_frame"
tag="_3lstm_1dnn"
loss_type="frame"
input_data_type=${model_type}${tag}_${loss_type}_${left_encode_num}_${right_encode_num}
output_data_type=enpg_mono

cmd_cpu="./script/slurm.pl --exclude=node01"

tmp_dir="tmp"
log_dir="log"
mkdir -p $tmp_dir $log_dir
python ./script/split.py ${data_list_dir}${data_list} ${tmp_dir}/ $Core_NUM

$cmd_cpu JOB=1:$Core_NUM $log_dir/HTKSlice.JOB.log \
    python ./script/HTKSlice.py $data_dir ${tmp_dir}/${data_list}JOB \
        $input_data_type $output_data_type ${PHONE_NUM} ${left_encode_num} ${right_encode_num}
    
rm ${tmp_dir}/${data_list}*

