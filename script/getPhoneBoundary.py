import sys
from dataIn import HTKFeat_read
import numpy as np
import distance_matrix as DM

THRESHOLD=0.5
DELAY=1

def is_boundary(SIL_probability_mean, threshold=THRESHOLD):
    return SIL_probability_mean < threshold

def time_delay(data, step):
    dim = data.shape[1]
    if(step == 0):
        return data
    elif(step>=0):
        new_data = data[step:, :]
        pad_data = np.tile((np.zeros([1, dim])+1)/dim, [step, 1])
        return np.concatenate([new_data, pad_data])
    else:
        new_data = data[0:step, :]
        pad_data = np.tile((np.zeros([1, dim])+1)/dim, (-step, dim))
        return np.concatenate([new_data, pad_data])

def write_list(fid, list_):
    for i in range(len(list_)-1):
        fid.writelines(str(list_[i])+" ")
    fid.writelines(str(list_[-1])+ "\n")


if __name__=="__main__":
    if len(sys.argv) < 5:
        print("USAGE: " + sys.argv[0] + " data_dir data_list output_data_type input_data_types\n")
        exit(1)

    data_dir = sys.argv[1]
    data_lists = open(sys.argv[2]).readlines()
    output_data_type = sys.argv[3]
    
    input_data_types = []
    for i in range(4, len(sys.argv)):
        input_data_types.append(sys.argv[i])

    input_data_type_len = len(input_data_types)
    for i in range(len(data_lists)):
        utterance_id = data_lists[i].strip()
        fid = open(data_dir + utterance_id + "." + output_data_type, "w")
        differences = []
        for input_data_type in input_data_types:
            input_file = data_dir + utterance_id + "." + input_data_type
            data = HTKFeat_read(input_file).getall()
            delay_data = time_delay(data, DELAY)
            differences.append(DM.innetProduct_dot(data, delay_data))
            
        write_list(fid, np.mean(differences, axis=0))
        fid.close()
        
