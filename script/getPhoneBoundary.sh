data_dir="/home2/jyh705/data/quesst14Database/"
data_list_dir="/home2/jyh705/data/quesst14Database/list/"
data_list="quesst2014_all.list"
Core_NUM=20
python split.py $data_list_dir$data_list ./ $Core_NUM

echo "python getPhoneBoundary.py $data_dir $data_list BDY_PHN czpg_mono hupg_mono ruspg_mono"
for i in `seq $Core_NUM`; do
{
    list=${data_list}${i}
    python getPhoneBoundary.py $data_dir $list BDY_PHN czpg_mono
    rm $list
} &
done

wait
