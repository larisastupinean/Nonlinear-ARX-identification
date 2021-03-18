function [d] = delayed_io(N,u,y,na,nb,nk)
% function for obtaining the vector of delayed inputs and outputs
d = zeros(N,na+nb);
for k = 1:N
    for i = 1:na
        if k-i > 0
            d(k,i) = y(k-i);
        end
    end
    
    for j = 0:nb-1
        if k-nk-j > 0
            d(k,j+na+1) = u(k-nk-j);
        end
    end
end
end