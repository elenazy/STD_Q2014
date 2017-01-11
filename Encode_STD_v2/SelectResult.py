import os
import sys
from Keyword import Keyword

if __name__=="__main__":
    if len(sys.argv) < 7:
        print("USAGE: pythno " + sys.argv[0] + "keyword_dir keyword_list result_5 result_7 result_9 fusion_result")
        exit(1)
    keyword_dir = sys.argv[1]
    keyword_list_file = sys.argv[2]
    result_dir_1 = sys.argv[3]
    result_dir_2 = sys.argv[4]
    result_dir_3 = sys.argv[5]
    result_dir_fusion = sys.argv[6]

    keyword_lists = open(keyword_list_file).readlines()
    keywords = []

    for i in range(len(keyword_lists)):
        keyword_id = keyword_lists[i].strip()
        new_entity = Keyword(keyword_dir, keyword_id, feature_type="enpg4", phone_type="PHN39", wav_sampling_rate=16000)
        keyword_phone_num = new_entity.getPhoneNum()
        #print(keyword_phone_num)
        if (keyword_phone_num <=5):
            cmd = "cp " + result_dir_1 + keyword_id + ".RESULT " + " " + result_dir_fusion + keyword_id + ".RESULT"
            os.system(cmd)
        elif (keyword_phone_num <=10):
            cmd = "cp " + result_dir_2 + keyword_id + ".RESULT " + " " + result_dir_fusion + keyword_id + ".RESULT"
            os.system(cmd)
        else:
            cmd = "cp " + result_dir_3 + keyword_id + ".RESULT " + " " + result_dir_fusion + keyword_id + ".RESULT"
            os.system(cmd)
