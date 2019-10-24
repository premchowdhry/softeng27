# -*- coding: utf-8 -*-

import time
import numpy as np
import matplotlib.pyplot as plt

from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import Matern, WhiteKernel, ConstantKernel

stime = time.time()

#Matern kernel parameters are in order - amplitude, lengthscale, roughness
#Choosing roughness (nu) as 1.5 means we assume that our ML function is differentiable at most once
m_ker = Matern(length_scale = 1, length_scale_bounds = (1e-1, 1e3), nu = 1.5)

#This kernel modifies the mean of the Gaussian process
c_ker = ConstantKernel()

#This kernel is used to explain the noise present in the data
w_ker = WhiteKernel(noise_level = 1)

kernel = m_ker + c_ker + w_ker

#Our training data - energy consumption E at time T
T_tr = [[0], [1], [2], [3], [4], [5]]
E_tr = [5, 6, 7, 8, 9, 10]

#Pass our kernel to the GP Regressor and set the number of times we re-run
#the optimizer in computing the hyperparameters
gpr = GaussianProcessRegressor(kernel = kernel, n_restarts_optimizer = 10)

#Fit the GP for the training data
gpr.fit(T_tr, E_tr)

# Predict new energy values over the supplied time range
T_pred = [[6], [7], [8], [9], [10]]
E_actual = [8.5, 9.5, 9, 10, 11]
E_pred, std_dev = gpr.predict(T_pred, return_std = True)	

# Plot results 
plt.figure(figsize=(10, 5))
lw = 2
plt.scatter(T_tr + T_pred, E_tr + E_actual, c='k', label = 'Data')

plt.plot(T_tr + T_pred, E_tr + E_actual, color = 'black', lw=lw, label='True')
plt.plot(T_pred, E_pred, color='red', lw=lw, label='GPR (%s)' % gpr.kernel_)
#plt.fill_between(X_plot[:, 0], y_gpr - y_std, y_gpr + y_std, color='darkorange', alpha=0.2)
plt.xlabel('Time')
plt.ylabel('Energy')
plt.xlim(0, 9)
plt.ylim(0, 15)
plt.title('Home Energy Consumption')
plt.legend(loc="best",  scatterpoints=1, prop={'size': 8})
plt.show()

