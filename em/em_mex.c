#include <math.h>
#include <mex.h>
#include "data.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	int i, j;
	Dataset data;

	if (nlhs != 3 || nrhs != 6) {
		mexErrMsgTxt("Usage: [pZ,beta,alpha] = em_mex(L, numLabelers, numImages, priorZ1, priorAlpha, priorBeta)\nwhere L is a Nx3 array of N labels (imageID, labelerID label)\n");
	}

	/* Determine number of labelers */
	data.numLabels = mxGetM(prhs[0]);
	data.numLabelers = (int) mxGetScalar(prhs[1]);
	data.numImages = (int) mxGetScalar(prhs[2]);
	data.priorZ1 = (double *) malloc(sizeof(double) * data.numImages);
	data.priorAlpha = (double *) malloc(sizeof(double) * data.numLabelers);
	data.priorBeta = (double *) malloc(sizeof(double) * data.numImages);

	/* Read the priors for alpha, beta, and Z */
	double *rawPriorAlpha = mxGetPr(prhs[4]);
	for (i = 0; i < data.numLabelers; i++) {
		data.priorAlpha[i] = rawPriorAlpha[i];
	}
	double *rawPriorBeta = mxGetPr(prhs[5]);
	double *rawPriorZ1 = mxGetPr(prhs[3]);
	for (j = 0; j < data.numImages; j++) {
		data.priorBeta[j] = rawPriorBeta[j];
		data.priorZ1[j] = rawPriorZ1[j];
	}

	data.probZ1 = (double *) malloc(sizeof(double) * data.numImages);
	data.probZ0 = (double *) malloc(sizeof(double) * data.numImages);
	data.beta = (double *) malloc(sizeof(double) * data.numImages);
	data.alpha = (double *) malloc(sizeof(double) * data.numLabelers);
	data.labels = (Label *) malloc(sizeof(Label) * data.numLabels);

	double *rawLabels = mxGetPr(prhs[0]);
	for (i = 0; i < data.numLabels; i++) {
		/* Remember that Matlab stores data in row-major order! */
		data.labels[i].imageIdx = rawLabels[i];
		data.labels[i].labelerId = rawLabels[data.numLabels + i];
		data.labels[i].label = rawLabels[2 * data.numLabels + i];
	}

	EM(&data);

	plhs[0] = mxCreateNumericMatrix(data.numImages, 1, mxDOUBLE_CLASS, mxREAL);
	plhs[1] = mxCreateNumericMatrix(data.numImages, 1, mxDOUBLE_CLASS, mxREAL);
	plhs[2] = mxCreateNumericMatrix(data.numLabelers, 1, mxDOUBLE_CLASS, mxREAL);

	double *pZ = mxGetPr(plhs[0]);
	double *beta = mxGetPr(plhs[1]);
	for (i = 0; i < data.numImages; i++) {
		pZ[i] = data.probZ1[i];
		beta[i] = exp(data.beta[i]);
	}
	double *alpha = mxGetPr(plhs[2]);
	for (i = 0; i < data.numLabelers; i++) {
		alpha[i] = data.alpha[i];
	}

	free(data.priorAlpha);
	free(data.priorBeta);
	free(data.priorZ1);
	free(data.probZ1);
	free(data.probZ0);
	free(data.beta);
	free(data.alpha);
	free(data.labels);
}
