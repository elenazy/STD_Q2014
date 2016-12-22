
//a C++ version of sub-sequence DTW, which do the length normalization on the fly

#include <infra.h>
#include <math.h>
#include <string>

#define WINDOWSIZE 60
#define STEP 5 
#define LEN_PENALTY_DIAG 2

// unterance-level mean variance normalization

// smooth the distance matrix
void smooth(const infra::matrix& dist, infra::matrix& sdist, int context = 1)
{

	unsigned long nHeight = dist.height();
	unsigned long nWidth = dist.width();

	int length = 2*context + 1;

	for (int i = 0; i < nHeight; i++)
		for(int j = 0; j < nWidth; j++)
		{
			float sum = dist(i,j); 
			for (int k=1; k <= context; k++)
			{
				int ii = std::max(0,i-k);
				int jj = std::max(0,j-k);
				sum+=dist(ii,jj);
				ii = std::min(int(nHeight-1),i+k);
				jj = std::min(int(nWidth-1),j+k);
				sum+=dist(ii,jj);
			}
			sdist(i,j) = sum/length;
		}

}


void mvn(infra::matrix& feature)
{
	unsigned long nHeight = feature.height();
	unsigned long nWidth = feature.width();

	for(int i = 0; i < nWidth; i++)
	{
		float mean = feature.column(i).sum()/nHeight;	
		feature.column(i) -= mean; // centralize
	    float std  = sqrt((feature.column(i)*feature.column(i))/nHeight);
		feature.column(i) /= std;  
			
	}

}

void normalizeFea(infra::matrix& feature)
{
	unsigned long nHeight = feature.height();
	unsigned long nWidth = feature.width();

	for(int i = 0; i < nHeight; i++)
	{
		float sum=0;
		for(int j = 0; j < nWidth; j++)
			sum += feature(i,j)*feature(i,j);

	    float mod = sqrt(sum);	
		for(int j = 0; j < nWidth; j++)
	        feature(i,j) /= mod;	
	}
}

void computeDist( const infra::matrix& query, const infra::matrix& test, infra::matrix& dist_matrix, std::string featureType)
{
	unsigned long nHeight = dist_matrix.height();
	unsigned long nWidth = dist_matrix.width();
	
	if(featureType == "mfc" || featureType == "isa"|| featureType == "vtlnmfc" || featureType == "sbnf")
	{
		infra::prod_t(query,test,dist_matrix); // dist_matrix = query*test.T

		infra::vector query_norm(query.height());
		for(int i = 0; i < query.height(); i++)
		{
			float sum=0;
			for(int j = 0; j < query.width();j++)
			{
				sum += query(i,j)*query(i,j);
			}
			query_norm[i] = sqrt(sum);
		}
	  
		infra::vector test_norm(test.height());
		for(int i = 0; i < test.height(); i++)
		{
			float sum = 0;
			for( int j = 0; j < test.width(); j++)
			{
				sum += test(i,j)*test(i,j);
			}	
			test_norm[i] = sqrt(sum);
		}
		
		for( int i = 0; i < nHeight; i++)
			for( int j = 0; j < nWidth;j++)
			{
				dist_matrix(i,j) = dist_matrix(i,j)/(query_norm[i]*test_norm[j]);
			}

		dist_matrix = 1 - dist_matrix;
	}
	else if(featureType=="vtln_k_256_gpg"||featureType=="vtln_k_1024_gpg" || featureType == "enpg" || featureType =="ruspg"||featureType == "czpg"||featureType == "hupg") // "pg" denote any kind of posteriorgram.
	{
		infra::prod_t(query,test,dist_matrix); // outcome = query*test.T
		dist_matrix =  0 - dist_matrix.log();      // outcome = -log(x.T*y)
	}
	else
	{
		std::cout<<"This type of feature representation is not supported"<<std::endl;
		exit(1);
	}

// the so-called test normalization	
	for( int i = 0; i < nHeight; i++)
	{
		double dmin = dist_matrix.row(i).min();
		double dmax = dist_matrix.row(i).max();
		for( int j = 0; j < nWidth;j++)
		{
			dist_matrix(i,j) = (dist_matrix(i,j)-dmin)/(dmax - dmin);
		}
	}
	
}


float subsequnceDTW(const infra::matrix& dist)
{
	unsigned long nHeight = dist.height();
	unsigned long nWidth = dist.width();
	double min_cost = 1; // the maximum cost 

	int window = ( (WINDOWSIZE > nHeight) ? nHeight : WINDOWSIZE );

	infra::matrix avg_cost(window,nWidth);
	infra::matrix cost(window,nWidth);
	infra::matrix length(window,nWidth);
	
	for(int start= 0; start + window - 1 < nHeight; start += STEP)
	{
		for( int i = 0; i < nWidth; i++)
		{
			cost(0,i) = dist(start,i);
			length(0,i) = 1;
			avg_cost(0,i) = cost(0,i);
		}

		for( int i = 1; i < window; i++)
		{
			length(i,0) = i+1;
			cost(i,0) = dist(start + i,0)+cost(i-1,0);
			avg_cost(i,0)= cost(i,0)/length(i,0);
		}

	// fill the three matrices in a dynamic programming style.
		for( int i = 1; i < window; i++)
			for( int j = 1; j < nWidth; j++)
			{
				// compute the three possible costs
				double cost_0 = dist(i + start,j )+cost(i-1,j);
				double cost_1 = dist(i + start,j )+cost(i,j-1);
				double cost_2 = dist(i + start,j )+cost(i-1,j-1);
				double avg_cost_0 = cost_0/(1+length(i-1,j));
				double avg_cost_1 = cost_1/(1+length(i,j-1));
				double avg_cost_2 = cost_2/(LEN_PENALTY_DIAG+length(i-1,j-1));
				
				// choose the one which lead to the minimum cost as the precedent point 
				if(avg_cost_0 < avg_cost_1)
				{
					if(avg_cost_0 < avg_cost_2)
					{
						avg_cost(i,j) = avg_cost_0;
						cost(i,j) = cost_0;
						length(i,j) = 1 + length(i-1,j);
					}
					else
					{
						avg_cost(i,j) = avg_cost_2;
						cost(i,j) = cost_2;
						length(i,j) = LEN_PENALTY_DIAG + length(i-1,j-1);
					}
				}
				else if(avg_cost_1 < avg_cost_2)
				{
					avg_cost(i,j) = avg_cost_1;
					cost(i,j) = cost_1;
					length(i,j) = 1 + length(i,j-1);
				}
				else
				{
					avg_cost(i,j) = avg_cost_2;
					cost(i,j) = cost_2;
					length(i,j) = LEN_PENALTY_DIAG + length(i-1,j-1);
				}
					
			}

		min_cost =std::min( avg_cost.row( window - 1 ).min(), min_cost );


	}

// backtrack to find the alignment path, just used to debug.	
//	unsigned index = avg_cost.row( nHeight - 1 ).argmin();
//	infra::matrix path(nHeight+nWidth,2);
//
//	unsigned i = nHeight -1;
//	unsigned j = index;
//	int p  = nHeight + nWidth -1;
//	int l = 0;
//	for(;p>=0;p--)
//	{
//		path(l,0)=i;
//		path(l,1)=j;
//		l++;
//		if(i==0) break;
//		switch(int(trace(i,j)))
//		{
//			case 0: i--;break; // the precedent point is (i-1,j)
//			case 1: j--;break; // the precedent point is (i,j-1)
//			default: i--;j--;  // the precedent point is (i-1,j-1)
//		}
//
//	}	
//
//	path.resize(l,2);
//	std::cout<<path<<std::endl;
//

	return 1 - min_cost;
}













