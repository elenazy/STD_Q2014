#!/usr/bin/python
#This script is used to convert the output of the query search 
#algorithm to the STD format, which is suitable for scoring.
#certain normalization technique is used to make the choice of the global threshold better.
#Two arguments are needeed: the query list, and the similarity threshold(for ActualTWV).
#Assume the .result file is at the same directory with the feature file.


import sys
import numpy as np

SITE = 'ntu-i2r-nwpu'
DATA = 'quesst2014_dev'
SYSID = 'p-baseline'
DELTSCORE = 'auto'

def m_norm(scorelist):
    hist, bin_edges = np.histogram(scorelist,40)
    index = hist.argmax();

    peak = (bin_edges[index] + bin_edges[index+1])/2

    slist_peak = np.array([x for x in scorelist if x >= peak])
    scorelist = (scorelist - peak)/slist_peak.std()

    return scorelist
    

def z_norm(scorelist):
    #scorelist = (np.array(scorelist)-min(scorelist))/(max(scorelist)-min(scorelist))
    mean = np.mean(scorelist)
    std  = np.std(scorelist)
    if std>0.000001:
        scorelist = (np.array(scorelist)-mean)/std
    else:
        scorelist = (np.array(scorelist)-mean)/0.000001    
    return scorelist

if __name__=='__main__':
    if len(sys.argv)<5:
        print("UASGE: result_dir query_list threshold")
        exit(0)
    result_dir = sys.argv[1]
    querylist_filename = sys.argv[2]
    threshold = float(sys.argv[3])
    stdlistdir=sys.argv[4]
    fid = open(querylist_filename)
    querylist = fid.readlines()
    fid.close()
    
    s = querylist[0].rfind('/') # "s" is the index of the last "/", so "s+1" is the start index of the query name. 

    
    
    stdlist =stdlistdir+SITE+'_'+DATA+'_'+SYSID+'_'+DELTSCORE+'.stdlist.xml'
    stdlist_fid = open(stdlist,'w')
    stdlist_fid.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    stdlist_fid.write('<stdlist termlist_filename="'+stdlist+ '" indexing_time="1.00" language="multiple" index_size="1" system_id="'+SYSID+'">\n')


    for query in querylist:
        query_id = query.strip()[s+1:]
        stdlist_fid.write('<detected_termlist termid="'+query_id+'" term_search_time="1.0" oov_term_count="1">\n')

        result_fid = open(result_dir + query.strip() + ".result")
        str_scorelist = result_fid.readlines()
        scorelist =[ float(score) for score in str_scorelist ];
        result_fid.close();
        
        norm_scorelist = z_norm(scorelist)
        
        audio_index = 1;

        for score in norm_scorelist:
            audio_id = 'quesst14_'+str(audio_index).zfill(5) #let the index be in "00001" style format
            if score>threshold:
                decision="YES"
            else:
                decision="NO"
            stdlist_fid.write('<term file="'+audio_id+'" channel="1" tbeg="0.00" dur="1.00" score="'+str(score)+'" decision="'+decision+'"/>\n');
            audio_index += 1
        stdlist_fid.write("</detected_termlist>\n")

    stdlist_fid.write("</stdlist>\n")
stdlist_fid.close()
