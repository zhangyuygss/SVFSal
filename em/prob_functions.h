#ifndef PROB_FUNCTIONS_H
#define PROB_FUNCTIONS_H

#include <gsl/gsl_vector.h>
#include "data.h"

double my_f (const gsl_vector *x, void *params);
void my_df (const gsl_vector *x, void *params, gsl_vector *g);
void my_fdf (const gsl_vector *x, void *params, double *f, gsl_vector *g);
void gradientQ (Dataset *data, double *dQdAlpha, double *dQdBeta);
double computeLikelihood (Dataset *data);
double computeQ (Dataset *data);
double logProbL (int l, int z, double alphaI, double betaJ);
double logistic (double x);
void EStep (Dataset *data);
void MStep (Dataset *data);

#endif
