#include <math.h>
#include <string.h>
#include <gsl/gsl_sf_gamma.h>
#include <gsl/gsl_multimin.h>
#include <gsl/gsl_sf_erf.h>
#include "prob_functions.h"
#include "data.h"

static const double ALPHA_PRIOR_MEAN = 1, BETA_PRIOR_MEAN = 1;

double my_f (const gsl_vector *x, void *params)
{
	Dataset *data = (Dataset *) params;

	unpackX(x, data);

	return - computeQ(data);
}

void my_df (const gsl_vector *x, void *params, gsl_vector *g)
{
	int i, j;

	Dataset *data = (Dataset *) params;
	double *dQdAlpha = (double *) malloc(sizeof(double) * data->numLabelers);
	double *dQdBeta = (double *) malloc(sizeof(double) * data->numImages);
	
	unpackX(x, data);
	
	gradientQ(data, dQdAlpha, dQdBeta);

	/* Pack dQdAlpha and dQdBeta into gsl_vector */
	for (i = 0; i < data->numLabelers; i++) {
		gsl_vector_set(g, i, - dQdAlpha[i]);  /* Flip the sign since we want to minimize */
	}
	for (j = 0; j < data->numImages; j++) {
		gsl_vector_set(g, data->numLabelers + j, - dQdBeta[j]);  /* Flip the sign since we want to minimize */
	}

	free(dQdAlpha);
	free(dQdBeta);
}

void my_fdf (const gsl_vector *x, void *params, double *f, gsl_vector *g)
{
	*f = my_f(x, params);
	my_df(x, params, g);
}

void gradientQ (Dataset *data, double *dQdAlpha, double *dQdBeta)
{
	int i, j;
	int idx;

	/* This comes from the priors */
	for (i = 0; i < data->numLabelers; i++) {
		dQdAlpha[i] = - (data->alpha[i] - data->priorAlpha[i]);
	}
	for (j = 0; j < data->numImages; j++) {
		dQdBeta[j] = - (data->beta[j] - data->priorBeta[j]);
	}

	for (idx = 0; idx < data->numLabels; idx++) {
		int i = data->labels[idx].labelerId;
		int j = data->labels[idx].imageIdx;
		int lij = data->labels[idx].label;
		double sigma = logistic(exp(data->beta[j]) * data->alpha[i]);

		dQdAlpha[i] += (data->probZ1[j] * (lij - sigma) + data->probZ0[j] * (1 - lij - sigma)) * exp(data->beta[j]);
		dQdBeta[j] += (data->probZ1[j] * (lij - sigma) + data->probZ0[j] * (1 - lij - sigma)) * data->alpha[i] * exp(data->beta[j]);
	}
}

double computeLikelihood (Dataset *data)
{
	int i, j;
	int idx;
	double L = 0;

	double *alpha = data->alpha, *beta = data->beta;

	for (j = 0; j < data->numImages; j++) {
		double P1 = data->priorZ1[j];
		double P0 = 1 - data->priorZ1[j];
		for (idx = 0; idx < data->numLabels; idx++) {
			if (data->labels[idx].imageIdx == j) {
				int i = data->labels[idx].labelerId;
				int lij = data->labels[idx].label;
				double sigma = logistic(exp(beta[j]) * alpha[i]);
				P1 *= pow(sigma, lij) * pow(1 - sigma, 1 - lij);
				P0 *= pow(sigma, 1 - lij) * pow(1 - sigma, lij);
			}
		}
		L += log(P1 + P0);
	}

	/* Add Gaussian (standard normal) prior for alpha */
	for (i = 0; i < data->numLabelers; i++) {
		L += log(gsl_sf_erf_Z(alpha[i] - data->priorAlpha[i]));
	}

	/* Add Gaussian (standard normal) prior for beta */
	for (j = 0; j < data->numImages; j++) {
		L += log(gsl_sf_erf_Z(beta[j] - data->priorBeta[j]));
	}

	return L;
}

double computeQ (Dataset *data)
{
	int i, j;
	int idx;
	double Q = 0;

	double *alpha = data->alpha, *beta = data->beta;

	/* Start with the expectation of the sum of priors over all images */
	for (j = 0; j < data->numImages; j++) {
		Q += data->probZ1[j] * log(data->priorZ1[j]);
		Q += data->probZ0[j] * log(1 - data->priorZ1[j]);
	}

	for (idx = 0; idx < data->numLabels; idx++) {
		int i = data->labels[idx].labelerId;
		int j = data->labels[idx].imageIdx;
		int lij = data->labels[idx].label;
		/* Do some analytic manipulation first for numerical stability! */
		double logSigma = - log(1 + exp(- exp(beta[j]) * alpha[i]));
		if (logSigma == - INFINITY) {
			/* For large negative x, -log(1 + exp(-x)) = x */
			logSigma = exp(beta[j]) * alpha[i];
		}

		double logOneMinusSigma = - log(1 + exp(exp(beta[j]) * alpha[i]));
		if (logOneMinusSigma == - INFINITY) {
			/* For large positive x, -log(1 + exp(x)) = x */
			logOneMinusSigma = - exp(beta[j]) * alpha[i];
		}

		Q += data->probZ1[j] * (lij * logSigma + (1 - lij) * logOneMinusSigma) +
		     data->probZ0[j] * ((1 - lij) * logSigma + lij * logOneMinusSigma);
		/*if (isnan(Q)) { abort(); }*/
	}

	/* Add Gaussian (standard normal) prior for alpha */
	for (i = 0; i < data->numLabelers; i++) {
		Q += log(gsl_sf_erf_Z(alpha[i] - data->priorAlpha[i]));
		/*if (isnan(Q)) { abort(); }*/
	}

	/* Add Gaussian (standard normal) prior for beta */
	for (j = 0; j < data->numImages; j++) {
		Q += log(gsl_sf_erf_Z(beta[j] - data->priorBeta[j]));
		/*if (isnan(Q)) { abort(); }*/
	}
	/*printf("a=%f a=%f a=%f b=%f\n", alpha[0], alpha[1], alpha[2], beta[0]);*/
	/*printf("Q=%f\n", Q);*/
	return Q;
}

double logProbL (int l, int z, double alphaI, double betaJ)
{
	double p;

	if (z == l) {
		p = - log(1 + exp(- exp(betaJ) * alphaI));
	} else {
		p = - log(1 + exp(exp(betaJ) * alphaI));
	}
	/*if (z == 1) {*/
	/*	p = - l * log(1 + exp(- exp(betaJ) * alphaI)) - (1 - l) * log(1 + exp(exp(betaJ) * alphaI));*/
	/*} else {*/
	/*	p = - (1 - l) * log(1 + exp(- exp(betaJ) * alphaI)) - l * log(1 + exp(exp(betaJ) * alphaI));*/
	/*}*/

	return p;
}

double logistic (double x)
{
	return 1.0 / (1 + exp(-x));
}

void EStep (Dataset *data)
{
	int j;
	int idx;

	for (j = 0; j < data->numImages; j++) {
		data->probZ1[j] = log(data->priorZ1[j]);
		data->probZ0[j] = log(1 - data->priorZ1[j]);
	}

	for (idx = 0; idx < data->numLabels; idx++) {
		int i = data->labels[idx].labelerId;
		int j = data->labels[idx].imageIdx;
		int lij = data->labels[idx].label;
		data->probZ1[j] += logProbL(lij, 1, data->alpha[i], data->beta[j]);
		data->probZ0[j] += logProbL(lij, 0, data->alpha[i], data->beta[j]);
	}

	/* Exponentiate and renormalize */
	for (j = 0; j < data->numImages; j++) {
		data->probZ1[j] = exp(data->probZ1[j]);
		data->probZ0[j] = exp(data->probZ0[j]);
		data->probZ1[j] = data->probZ1[j] / (data->probZ1[j] + data->probZ0[j]); 
		data->probZ0[j] = 1 - data->probZ1[j];
		if (isnan(data->probZ1[j])) {
			abort();
		}
	}
}

void MStep (Dataset *data)
{
	double lastF;
	int iter, status;
	int i, j;

	int numLabelers = data->numLabelers;
	int numImages = data->numImages;
		
	gsl_vector *x;
	gsl_multimin_fdfminimizer *s;
	const gsl_multimin_fdfminimizer_type *T;
	gsl_multimin_function_fdf my_func;

	x = gsl_vector_alloc(numLabelers + numImages);

	/* Pack alpha and beta into a gsl_vector */
	packX(x, data);

	/* Initialize objective function */
	my_func.n = numLabelers + numImages;
	my_func.f = &my_f;
	my_func.df = &my_df;
	my_func.fdf = &my_fdf;
	my_func.params = data;

	/* Initialize minimizer */
	T = gsl_multimin_fdfminimizer_conjugate_pr;
	s = gsl_multimin_fdfminimizer_alloc(T, numLabelers + numImages);

	gsl_multimin_fdfminimizer_set(s, &my_func, x, 0.01, 0.01);
	iter = 0;
	do {
		lastF = s->f;
		iter++;
		//printf("iter=%d f=%f\n", iter, s->f);
	
		status = gsl_multimin_fdfminimizer_iterate(s);
		if (status) {
			break;
		}
		status = gsl_multimin_test_gradient(s->gradient, 1e-3);
		if (status == GSL_SUCCESS) {
			printf ("Minimum found");
		}
	} while (lastF - s->f > 0.01 && status == GSL_CONTINUE && iter < 25);

	/* Unpack alpha and beta from gsl_vector */
	unpackX(s->x, data);
	
	gsl_multimin_fdfminimizer_free(s);
	gsl_vector_free(x);
}
