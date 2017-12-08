#include <gsl/gsl_vector.h>
#include <math.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include "data.h"
#include "prob_functions.h"

void EM (Dataset *data)
{
	int i, j;
	const double THRESHOLD = 1E-10;
	double Q, lastQ;

	srand(time(NULL));
	
	/* Initialize parameters to starting values */
	for (i = 0; i < data->numLabelers; i++) {
		data->alpha[i] = data->priorAlpha[i];
		/*data->alpha[i] = (double) rand() / RAND_MAX * 4 - 2;*/
	}
	for (j = 0; j < data->numImages; j++) {
		data->beta[j] = data->priorBeta[j];
		/*data->beta[j] = (double) rand() / RAND_MAX * 3;*/
	}
	
	Q = 0;
	EStep(data);
	Q = computeQ(data);
	/*printf("Q = %f\n", Q);*/
	do {
		lastQ = Q;

		/* Re-estimate P(Z|L,alpha,beta) */
		EStep(data);
		Q = computeQ(data);
		/*printf("Q = %f; L = %f\n", Q, 0.0 /*computeLikelihood(data)*/

		/*outputResults(data);*/
		MStep(data);
		
		Q = computeQ(data);
		/*printf("Q = %f; L = %f\n", Q, 0.0 /*computeLikelihood(data)*/
	} while (fabs((Q - lastQ)/lastQ) > THRESHOLD);
	/* outputResults(data); */
}

int main (int argc, char *argv[])
{
	Dataset data;

	if (argc < 2) {
		fprintf(stdout, "Usage: em <data>\n");
		fprintf(stdout, "where the specified data file is formatted as described in the README file.\n");
		exit(1);
	}

	readData(argv[1], &data);
	EM(&data);

	free(data.priorAlpha);
	free(data.priorBeta);
	free(data.labels);
	free(data.alpha);
	free(data.beta);
	free(data.probZ1);
	free(data.probZ0);
}
