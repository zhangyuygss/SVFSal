#include <math.h>
#include "data.h"

void packX (gsl_vector *x, Dataset *data)
{
	int i, j;

	/* Pack alpha and beta into gsl_vector */
	for (i = 0; i < data->numLabelers; i++) {
		gsl_vector_set(x, i, data->alpha[i]);
	}
	for (j = 0; j < data->numImages; j++) {
		gsl_vector_set(x, data->numLabelers + j, data->beta[j]);
	}
}

void unpackX (const gsl_vector *x, Dataset *data)
{
	int i, j;

	/* Unpack alpha and beta from gsl_vector */
	for (i = 0; i < data->numLabelers; i++) {
		data->alpha[i] = gsl_vector_get(x, i);
		/*if (isnan(data->alpha[i])) {
			abort();
		}*/
	}
	for (j = 0; j < data->numImages; j++) {
		data->beta[j] = gsl_vector_get(x, data->numLabelers + j);
		/*if (isnan(data->beta[j])) {
			abort();
		}*/
	}
}


void readData (char *filename, Dataset *data)
{
	int i, j;
	int idx;
	char str[1024];
	FILE *fp = fopen(filename, "rt");
	double priorZ1;

	/* Read parameters */
	fscanf(fp, "%d %d %d %lf\n", &data->numLabels, &data->numLabelers, &data->numImages, &priorZ1);
	printf("Reading %d labels of %d labelers over %d images for prior P(Z=1) = %lf\n",
	       data->numLabels, data->numLabelers, data->numImages, priorZ1);
	data->priorAlpha = (double *) malloc(sizeof(double) * data->numLabelers);

	printf("Assuming prior on alpha has mean 1 and std 1\n");
	for (i = 0; i < data->numLabelers; i++) {
		data->priorAlpha[i] = 1.0; /* default value */
	}
	data->priorBeta = (double *) malloc(sizeof(double) * data->numImages);
	data->priorZ1 = (double *) malloc(sizeof(double) * data->numImages);
	
	printf("Assuming prior on beta has mean 1 and std 1.\n");
	printf("Also assuming p(Z=1) is the same for all images.\n");
	for (j = 0; j < data->numImages; j++) {
		data->priorBeta[j] = 1.0; /* default value */
		data->priorZ1[j] = priorZ1;
	}
	data->probZ1 = (double *) malloc(sizeof(double) * data->numImages);
	data->probZ0 = (double *) malloc(sizeof(double) * data->numImages);
	data->beta = (double *) malloc(sizeof(double) * data->numImages);
	data->alpha = (double *) malloc(sizeof(double) * data->numLabelers);
	data->labels = (Label *) malloc(sizeof(Label) * data->numLabels);

	/* Read labels */
	idx = 0;
	while (fscanf(fp, "%d %d %d\n", &(data->labels[idx].imageIdx),
		      &(data->labels[idx].labelerId), &(data->labels[idx].label)) == 3) {
		/*if (data->labels[idx].label != 0 && data->labels[idx].label != 1) {
			abort();
		}*/
		printf("Read: image(%d)=%d by labeler %d\n", data->labels[idx].imageIdx,
		       data->labels[idx].label, data->labels[idx].labelerId);
		idx++;
	}
	fclose(fp);
}

void outputResults (Dataset *data)
{
	int i, j;

	for (i = 0; i < data->numLabelers; i++) {
		printf("Alpha[%d] = %f\n", i, data->alpha[i]);
	}
	for (j = 0; j < data->numImages; j++) {
		printf("Beta[%d] = %f\n", j, exp(data->beta[j]));
	}
	for (j = 0; j < data->numImages; j++) {
		printf("P(Z(%d)=1) = %f\n", j, data->probZ1[j]);
	}
}
