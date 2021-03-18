# Nonlinear-ARX-identification
System identification using nonlinear ARX

This team project focuses on developing a black-box model of an unknown dynamic system using nonlinear ARX. The results are tuned by varying the values of the order of the system
and of the order of the polynomial. The identification of the system is done on the training data set, and the validation of the developed model is done on a separate data set
measured on the same system. These 2 data sets can be found in the MATLAB Data file "iddata-05.mat". The developed model can be used for the one-step-ahead prediction and the
simulation of the system's output. So, after tuning the results, the best model for the prediction is considered to be the one which leads to the smallest mean squared error for
the prediction on the validation data; likewise, the best model for the simulation is considered to be the one which leads to the smallest mean squared error for simulation on the 
validation data. There is also a discussion on how the time delay of the system affects the results obtained using the developed models. Here are some figures with the true 
values, and the predicted and the simulated values of the identification and validation output in the case of no time delay:

![image](https://user-images.githubusercontent.com/80631066/111638414-f8c67580-8802-11eb-8026-389813137334.png)
![image](https://user-images.githubusercontent.com/80631066/111638524-14ca1700-8803-11eb-8966-419aae7a37f9.png)
