function [phi] = regressor(m,d)
no_lines_dk = size(d,1);
no_columns_dk = size(d,2);

phi = ones(no_lines_dk,1);

% p is a matrix which containes on each line all the possible exponents
% (0:m), having the number of lines equal with the number of signals in d
p = zeros(no_columns_dk,m+1);
for i = 1:size(p,1)
    p(i,:) = 0:m;
end

% breaking the p matrix into a single column cell array containing the rows of p
R = ones(1,no_columns_dk); % the elements of this array determine the size of each cell 
powers = mat2cell(p,R); % a column cell array containing a number equal to the number 
% of signals in d of identical arrays of the possible powers at which
% these signals can be raised to

% making a matrix containing all the possible combinations of powers,
% depending on the order of the system (the number of signals in dk), 
% and on the order of the polynomial (m)
powers_comb = combvec(powers{:})';

% regressor phi contains the products of all the signals in d
% raised at all the possible combinations of powers, as long as the sum of
% the exponents does not exceed the order of the polynomial m
column = 1;
for i = 1:size(powers_comb,1)
    exponent = powers_comb(i,:);
    s = sum(exponent);
    if s <= m
        phi(:,column) = 1;
        for x = 1:no_columns_dk
            phi(:,column) = phi(:,column).*(d(:,x).^exponent(x));
        end
        column = column+1;
    end
end