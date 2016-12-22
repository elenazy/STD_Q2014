import sys
from dataIn import HTKFeat_read
from dataIn import HTKFeat_write
import numpy as np
def merge(data, phone2state_map):
    merged_data = [] 
    data_len = data.shape[0]
    for i in range(len(phone2state_map)):
        merged_data.append(np.sum(data[:, phone2state_map[i]], axis=1).reshape(data_len, 1))
    return np.concatenate(merged_data, axis=1)

if __name__=="__main__":
    if len(sys.argv) < 6:
        print("USAGE: " + sys.argv[0] + " data_dir data_list input_data_type output_data_type state2phone_map\n")
        exit(1)

    data_dir = sys.argv[1]
    data_lists = open(sys.argv[2]).readlines()
    input_data_type = sys.argv[3]
    output_data_type = sys.argv[4]
    phone2state_map_list = open(sys.argv[5]).readlines()
    phone2state_map = []
    for i in range(len(phone2state_map_list)):
        phone_id, dim_id = phone2state_map_list[i].strip().split()
        if len(phone2state_map) <= int(phone_id):
            phone2state_map.append([])
        phone2state_map[-1].append(int(dim_id))

    output_len = len(phone2state_map)
    for i in range(len(data_lists)):
        utterance_id = data_lists[i].strip()
        input_file = data_dir + utterance_id + "." + input_data_type
        data = HTKFeat_read(input_file).getall()
        
        merged_data = merge(data, phone2state_map)
        
        output_file = data_dir + utterance_id + "." + output_data_type
        HTK_file = HTKFeat_write(output_file, veclen=output_len, sampPeriod=100000, paramKind=9)
        HTK_file.writeall(merged_data)
        HTK_file.close()

