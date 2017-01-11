//=============================================================================
//
// File Name: Lab1.cpp
// Written by: Peng Yang
// Email: pengyang@nwpu-aslp.org
//
//=============================================================================
#include <infra.h>
#include <iostream>
#include <fstream>
#include <thread>
#include "HtkFile.h"
#include "Dataset.h"
#include "DTW.h"
#define MISPAR_GADOL_MEOD (1000000000);

using namespace std;
//this function is used to score for one query as the function name told
//parameter: 
//input : query_id //string
//		  test_size //int
//		  featureType //string
//output: test //the out put matrix
int score_for_one_query(const string& query_id, infra::matrix* test, int test_size, const string& featureType)
{
//	dynamic programming between query and test[j]
	string vad_label;
	//input query_id.vc file to ifs
	ifstream ifs((query_id + ".VAD_BUT_PHN").c_str());
	//get vad_label from ifs
	getline(ifs,vad_label);
	ifs.close();
	//define a query matrix
	infra::matrix query;
	string queryFileName = query_id + "." + featureType;
	//read  query file from queryFileName use vad_label as query matrix
	if (!read_htk(queryFileName, vad_label, query)) {
		return EXIT_FAILURE;
	}
	//if the feature type is mfc ,isa or vtlnmfc then use mvn normalization
	//else use normalizeFea
	if (featureType == "mfcc"||featureType=="isa" || featureType == "vtlnmfc")
		mvn(query);
	if (featureType == "mfcc"||featureType=="isa" || featureType == "sbnf" || featureType == "lpp"||featureType.find("sbnf") != std::string::npos)
	    normalizeFea(query);
//normal DTW	
	ofstream ofs((query_id + ".result").c_str());

	// run over the test set				
	for (int i = 0; i < test_size; i++) {
	//	dynamic programming between query and test[i]
		unsigned long height = query.height();
		unsigned long width = test[i].height();
		infra::matrix dist(height,width);
		
		computeDist(query, test[i], dist, featureType);
	//	cout<<dist;
	//	int x;
	//	cin>>x;
		float score = subsequnceDTW(dist);

		ofs<<score<<endl;
//		cout<<score;
	}

	ofs.close();

	return EXIT_SUCCESS;
}

int main(int argc, char *argv[])
{	
	if(argc < 5)
	{
		cerr<<"USAGE: dataDir queryListFile testListFile featureType"<<endl;
		return EXIT_FAILURE;
	}
    string dataDir;
	string queryListFile;
	string testListFile;
	string featureType;
	int num_cpu_core;
    
    dataDir = string(argv[1]);
	queryListFile = string(argv[2]);
	testListFile = string(argv[3]);
	featureType = string(argv[4]);
	
	StringVector queryList;
	queryList.read(queryListFile);

	StringVector testList;
	testList.read(testListFile);
	
	// read test set
    infra::matrix* test = new infra::matrix[testList.size()];
	

	for (int i = 0; i < testList.size(); i++) {
		string vad_label;
		ifstream ifs((dataDir + testList[i]+".VAD_BUT_PHN").c_str());
		getline(ifs,vad_label);
		ifs.close();

		string testFileName(dataDir + testList[i]+"."+featureType);
		if (!read_htk(testFileName, vad_label, test[i])) {
			return EXIT_FAILURE;
		}

		if (featureType == "mfcc"||featureType == "isa"||featureType == "vtlnmfc")
			mvn(test[i]);
		if (featureType == "mfcc"||featureType=="isa" || featureType == "vtlnmfc" || featureType.find("sbnf") != std::string::npos)
			normalizeFea(test[i]);

	}	

//debug the function of score_for_one_query()

	for (int i =0; i < queryList.size(); i++){
		score_for_one_query(dataDir + queryList[i], test, testList.size(), featureType);
	}	
	// for each of the query files
	//for ( int i=0; i < queryList.size(); i += num_cpu_core) {
	//	
	//    unsigned count_thread = 0;
	//	int j=i;
	//	thread t[num_cpu_core];
	//	while( count_thread < num_cpu_core && j < queryList.size() )
	//	{
	//		t[count_thread] = thread(score_for_one_query, dataDir + queryList[j], test, testList.size(), featureType);
	//		j++;
	//		count_thread++;
	//	}	
    //    
	//	for (int c = 0; c < count_thread; c++)
	//		t[c].join();
	//}	

	delete [] test;
	return EXIT_SUCCESS;
}

