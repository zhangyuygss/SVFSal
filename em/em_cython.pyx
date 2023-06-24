import numpy as np
cimport numpy as np
from libc.stdlib cimport malloc, free

cdef extern from "data.h":
    ctypedef struct Label:
        int imageIdx
        int labelerId
        int label
    ctypedef struct Dataset:
        int numLabels
        int numLabelers
        int numImages
        double *priorZ1
        double *priorAlpha
        double *priorBeta
        double *probZ1
        double *probZ0
        double *beta
        double *alpha
        Label *labels
    void EM(Dataset *data)

cdef class EMWrapper:
    def __cinit__(self):
        pass

    def run_em(self, np.ndarray[np.int32_t, ndim=2] labels, int numLabelers, int numImages, np.ndarray[np.float64_t, ndim=1] priorZ1, np.ndarray[np.float64_t, ndim=1] priorAlpha, np.ndarray[np.float64_t, ndim=1] priorBeta):
        cdef Dataset data
        cdef int i

        data.numLabels = labels.shape[0]
        data.numLabelers = numLabelers
        data.numImages = numImages
        data.priorZ1 = &priorZ1[0]
        data.priorAlpha = &priorAlpha[0]
        data.priorBeta = &priorBeta[0]

        data.probZ1 = <double *>malloc(sizeof(double) * data.numImages)
        data.probZ0 = <double *>malloc(sizeof(double) * data.numImages)
        data.beta = <double *>malloc(sizeof(double) * data.numImages)
        data.alpha = <double *>malloc(sizeof(double) * data.numLabelers)
        data.labels = <Label *>malloc(sizeof(Label) * data.numLabels)

        for i in range(data.numLabels):
            data.labels[i].imageIdx = labels[i, 0]
            data.labels[i].labelerId = labels[i, 1]
            data.labels[i].label = labels[i, 2]

        EM(&data)

        cdef np.ndarray[np.float64_t, ndim=1] pZ = np.empty(data.numImages, dtype=np.float64)
        cdef np.ndarray[np.float64_t, ndim=1] beta = np.empty(data.numImages, dtype=np.float64)
        cdef np.ndarray[np.float64_t, ndim=1] alpha = np.empty(data.numLabelers, dtype=np.float64)

        for i in range(data.numImages):
            pZ[i] = data.probZ1[i]
            beta[i] = np.exp(data.beta[i])

        for i in range(data.numLabelers):
            alpha[i] = data.alpha[i]

        free(data.probZ1)
        free(data.probZ0)
        free(data.beta)
        free(data.alpha)
        free(data.labels)

        return pZ, beta, alpha