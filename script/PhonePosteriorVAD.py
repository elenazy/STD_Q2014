import sys
from dataIn import HTKFeat_read
import numpy as np
THRESHOLD=0.5

def VAD(SIL_probability_mean, threshold=THRESHOLD):
    return SIL_probability_mean < threshold

def write_list(fid, list_):
    for i in range(len(list_)-1):
        fid.writelines(str(list_[i]))
    fid.writelines(str(list_[-1]))


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
        SIL_probability = []
        for input_data_type in input_data_types:
            input_file = data_dir + utterance_id + "." + input_data_type
            data = HTKFeat_read(input_file).getall()
            SIL_probability.append(data[:, 0])
        SIL_probability_mean = np.mean(SIL_probability, axis=0)
        VAD_result = VAD(SIL_probability_mean)
        VAD_sesult_int = [int(element) for element in VAD_result]
        output_file = data_dir + utterance_id + "." + output_data_type
        fid = open(output_file, "w")
        write_list(fid, VAD_sesult_int)
        fid.close()        

