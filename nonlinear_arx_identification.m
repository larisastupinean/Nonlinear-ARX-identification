%% Initial data
clear all
% loading the initial data
load('iddata-05.mat');

% plotting the identification dataset
plot(id)
title('Input-Output Identification Data')
% plotting the validation dataset
figure, plot(val)
title('Input-Output Validation Data')

% identification data
yid = id.y;
uid = id.u;
% validation data
yval = val.y;
uval = val.u;
% the number of data points in the identification dataset
Nid = length(yid);
% the number of data points in the validation dataset
Nval = length(yval);

%% Finding the model and tuning results
% varying the order of the system given by na,nb and the order of the
% polynomial given by m in order to find the model which yields the best
% results

% we consider that na and nb vary from 1 to 3, m from 1 to 7 and that we
% have no time delay (nk=1)
na=1:3; nb=na; m=1:7; nk=1;

% generating a matrix which contains all possible combinations between the
% vectors na, nb, and m, in this order
na_nb_m_comb = combvec(m,nb,na)';
na_nb_m_comb(:,[1 3]) = na_nb_m_comb(:,[3 1]);

% arrays in which will be stored all MSEs on identification and validation
% for prediction and simulation
mse_pred_id = zeros(1,length(na_nb_m_comb));
mse_sim_id = zeros(1,length(na_nb_m_comb));
mse_pred_val = zeros(1,length(na_nb_m_comb));
mse_sim_val = zeros(1,length(na_nb_m_comb));
% index of the column in these arrays of MSEs
c = 1;

for i = na
    for j = nb
        % generating the vector of delayed identification inputs and outputs
        d_id = delayed_io(Nid,uid,yid,i,j,nk);
        % generating the vector of delayed validation inputs and outputs
        d_val = delayed_io(Nval,uval,yval,i,j,nk);
        
        for k = m
            % obtaining the regressors for both identification and validation data
            phi_id = regressor(k,d_id);
            phi_val = regressor(k,d_val);
            
            % finding the unknown parameters using the identification data
            theta = phi_id\yid;
            
            % obtaining the predicted and simulated outputs for the
            % identification dataset
            y_pred_id = phi_id*theta;
            y_sim_id = simulation(Nid,i,j,nk,k,uid,theta);
            
            % computing the mean squared error for both predicted and simulated
            % outputs on identification data
            mse_pred_id(c) = 1/Nid*sum((y_pred_id-yid).^2);
            mse_sim_id(c) = 1/Nid*sum((y_sim_id-yid).^2);
            
            % obtaining the predicted and simulated outputs for the
            % validation dataset
            y_pred_val = phi_val*theta;
            y_sim_val = simulation(Nval,i,j,nk,k,uval,theta);
            
            % computing the mean squared error for both predicted and simulated
            % outputs on validaton data
            mse_pred_val(c) = 1/Nval*sum((y_pred_val-yval).^2);
            mse_sim_val(c) = 1/Nval*sum((y_sim_val-yval).^2);
            
            % incrementing the index of the column for the arrays of MSEs
            c = c+1;
        end
    end
end

% finding the minimum MSEs on validation for both prediction and simulation
% and the corresponding indexes at which they appear
[mse_min_pred,index_pred] = min(mse_pred_val,[],'linear');
[mse_min_sim,index_sim] = min(mse_sim_val,[],'linear');

% we notice that the minimum MSEs are obtained for both prediction and
% simulation at the same index, thus for the same values of na, nb, m
% therefore, from now on we consider a single model as the best choice

% getting the values of na, nb, m from the matrix of their combinations
best_model = na_nb_m_comb(index_pred,:);

%% Graphical and tabular representations of the MSEs
% 2D plot of the values of the MSEs on identification
figure
subplot(121), plot(mse_pred_id)
xlabel('index'), ylabel('MSE')
title({'The mean squared errors','for prediction'})
subplot(122), plot(mse_sim_id)
xlabel('index'), ylabel('MSE')
title({'The mean squared errors','for simulation'})
sgtitle('The mean squared errors on identification')

% 2D plot of the values of the MSEs on validation
figure
subplot(121), plot(mse_pred_val)
xlabel('index'), ylabel('MSE')
title({'The mean squared errors','for prediction'})
subplot(122), plot(mse_sim_val)
xlabel('index'), ylabel('MSE')
title({'The mean squared errors','for simulation'})
sgtitle('The mean squared errors on validation')

% finding the values of the MSEs only for the cases in which na=nb and
% storing them in separate arrays
k = 1;
mse_pred_na_id = zeros(1,length(na)*length(m));
mse_pred_na_val = zeros(1,length(na)*length(m));
for i = 1:size(na_nb_m_comb,1)
    if na_nb_m_comb(i,1) == na_nb_m_comb(i,2)
        mse_pred_na_id(k) = mse_pred_id(i);
        mse_pred_na_val(k) = mse_pred_val(i);
        k = k+1;
    end
end
% rearranging the values of the MSEs in matrices so that they can be
% represented graphically
mse_pred_id_matrix = reshape(mse_pred_na_id,length(m),length(na));
mse_pred_val_matrix = reshape(mse_pred_na_val,length(m),length(na));
% 3D plot of the MSEs for prediction only for the cases in which na=nb
figure
subplot(121), surf(na,m,mse_pred_id_matrix)
xlabel('na=nb'), ylabel('m'), zlabel('MSE')
title({'The mean squared errors','on identification data'})
subplot(122), surf(na,m,mse_pred_val_matrix)
xlabel('na=nb'), ylabel('m'), zlabel('MSE')
title({'The mean squared errors','on validation data'})
sgtitle('The mean squared errors for prediction depending on na=nb and m')

% table with the values of the MSEs on identification for both prediction
% and simulation depending on na, nb and m
data1 = [na_nb_m_comb(:,1),na_nb_m_comb(:,2),na_nb_m_comb(:,3),mse_pred_id',mse_sim_id'];
fig1 = uifigure('Position',[500 75 500 600]);
fig1.Name = 'Table with MSEs depending on na,nb and m on the identification data';
uit1 = uitable(fig1,'Position',[20 20 466 575],'Data',data1);
uit1.ColumnWidth = {50,50,50,135,135};
uit1.ColumnFormat = {[],[],[],'shortE','shortE'};
uit1.ColumnName = {'na','nb','m','MSE prediction (id)','MSE simulation (id)'};
% table with the values of the MSEs on validation for both prediction
% and simulation depending on na, nb and m
data2 = [na_nb_m_comb(:,1),na_nb_m_comb(:,2),na_nb_m_comb(:,3),mse_pred_val',mse_sim_val'];
fig2 = uifigure('Position',[500 75 500 600]);
fig2.Name = 'Table with MSEs depending on na,nb and m on the validation data';
uit2 = uitable(fig2,'Position',[20 20 466 575],'Data',data2);
uit2.ColumnWidth = {50,50,50,135,135};
uit2.ColumnFormat={[],[],[],'shortE','shortE'};
uit2.ColumnName = {'na','nb','m','MSE prediction (val)','MSE simulation (val)'};

%% Final model and results
% retrieving the na, nb, m which give the best results
na = best_model(1); nb = best_model(2); m = best_model(3);
% for the final results check we will also consider time delay
nk = 1:3;

i = 1;
MSE_pred_id = zeros(1,length(nk)); MSE_sim_id = zeros(1,length(nk));
MSE_pred_val = zeros(1,length(nk)); MSE_sim_val = zeros(1,length(nk));
for j = nk
    % obtaining the approximation of the identification output for both 
    % simulation and prediction
    d_id = delayed_io(Nid,uid,yid,na,nb,j);
    phi_id = regressor(m,d_id);
    theta = phi_id\yid;
    y_pred_id = phi_id*theta;
    y_sim_id = simulation(Nid,na,nb,j,m,uid,theta);
    % computing the one-step-ahead prediction errors for the identification dataset
    MSE_pred_id(i) = 1/Nid*sum((y_pred_id-yid).^2);
    % computing the simulation errors for the identification dataset
    MSE_sim_id(i) = 1/Nid*sum((y_sim_id-yid).^2);
    % creating data objects for prediction and simulation i/o on identification
    dat_pred_id = iddata(y_pred_id,uid,id.Ts);
    dat_sim_id = iddata(y_sim_id,uid,id.Ts);
    % plots with the approximated model output versus the real output, for 
    % both simulation and prediction for the training dataset
    figure, compare(id,dat_pred_id,dat_sim_id)
    title({'Comparison between the identification output and the corresponding',...
        ['predicted and simulated outputs, nk=' num2str(j)]})
    
    % obtaining the approximation of the validation output for both 
    % simulation and prediction
    d_val = delayed_io(Nval,uval,yval,na,nb,j);
    phi_val = regressor(m,d_val);
    y_pred_val = phi_val*theta;
    y_sim_val = simulation(Nval,na,nb,j,m,uval,theta);
    % computing the one-step-ahead prediction errors for the validation dataset
    MSE_pred_val(i) = 1/Nval*sum((y_pred_val-yval).^2);
    % computing the simulation errors for the validation dataset
    MSE_sim_val(i) = 1/Nval*sum((y_sim_val-yval).^2);
    % creating data objects for prediction and simulation i/o on validation
    dat_pred_val = iddata(y_pred_val,uval,val.Ts);
    dat_sim_val = iddata(y_sim_val,uval,val.Ts);
    % plots with the approximated model output versus the real output, for 
    % both simulation and prediction for the validation dataset
    figure, compare(val,dat_pred_val,dat_sim_val)
    title({'Comparison between the validation output and the corresponding',...
        ['predicted and simulated outputs, nk=' num2str(j)]})
    
    i = i+1;
end
