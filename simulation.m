function [yhat] = simulation(N,na,nb,nk,m,u,theta)
% function for obtaining the simulated model output
yhat = zeros(N,1);
dk = zeros(1,na+nb);
for k = 1:N
    % obtaining only line k from the vector of delayed inputs and outputs
    % using the values of the output signal yhat computed previousely
    for i = 1:na
        if k-i > 0
            dk(i) = yhat(k-i);
        end
    end
    for j = 0:nb-1
        if k-nk-j > 0
            dk(j+na+1) = u(k-nk-j);
        end
    end
    
    % obtaining only line k of the regressor using the previously computed
    % yhat values as the output signal
    phik = regressor(m,dk);
    
    % computing the output value yhat(k) and storing it in the column yhat
    % on the line k
    yhat(k) = phik*theta;
end
end