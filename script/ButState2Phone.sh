data_dir="/home2/jyh705/data/quesst14Database/"
data_list_dir="/home2/jyh705/data/quesst14Database/list/"
data_list="quesst2014_all.list"
map_dir="/home2/jyh705/code/QUESST2014/phones/"
declare -A map
map=([czpg]="map_CZ" [hupg]="map_HU" [ruspg]="map_RU")
Core_NUM=20

python split.py $data_list_dir$data_list $Core_NUM
for i in `seq $Core_NUM`; do
{
    list=${data_list}${i}
    for input_data_type in czpg hupg ruspg; do
        output_data_type=${input_data_type}_mono
        echo "python ButState2Phone.py $data_dir $list $input_data_type $output_data_type ${map_dir}${map[${input_data_type}]}"
        python ButState2Phone.py $data_dir $list $input_data_type $output_data_type ${map_dir}${map[${input_data_type}]}
    done
    rm $list
} &
done
wait
