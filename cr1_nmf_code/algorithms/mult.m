% multiplicative update algorithm
% written according to the paper: D. D. Lee and H. S. Seung. Algorithms for 
% non-negative matrix factorization.
%
% [W,H,rel_err,t,iter] = mult(V,W,H,maxiter,timelimit,early_stopping,tol)
%
% Input.
%   V              : (F x N) matrix to factorize
%   (W,H)          : initial matrices of dimensions (F x K) and (K x N)
%   maxiter        : maximum number of iterations
%   timelimit      : maximum time alloted to the algorithm
%   early_stopping : if early_stopping == 1, terminate the algorithm when the
%                    variation of product of factor matrices (<tol) is small 
%                    over 10 times
%   tol            : used for early_stopping
%
% Output.
%   (W,H)          : final nonnegative matrices, WH approximate V
%   (rel_err,t)    : relative error and time after each iteration
%   iter           : number of iterations when terminated

function [W,H,rel_err,t,iter] = mult(V,W,H,maxiter,timelimit,early_stopping,tol)

% Initialization
etime = cputime; normV = norm(V,'fro'); nV = normV*normV;
err = []; t = [];  iter = 0; 

if nargin <= 3, maxiter = 100; end
if nargin <= 4, timelimit = inf; end
if nargin <= 5, early_stopping=0; end 
if nargin <= 6, tol=1e-4; end 

% Main loop
while iter < maxiter && cputime-etime <= timelimit 
    % Update of W
    A = (V*H'); B = (H*H'); 
    W = max(1e-16,W.*(A./(W*B))); 
    
    % Update of H
    A = (W'*V); B = (W'*W); 
    H = max(1e-16,H.*(A./(B*H))); 
    
    % Evaluation of the approximation error at time t 
    if nargout >= 3
        cnT = cputime;
        err = [err sqrt( (nV-2*sum(sum(H.*A))+ sum(sum(B.*(H*H')))) )];
        etime = etime+(cputime-cnT);    
        t = [t cputime-etime]; 
        if(length(err)>9)
            temp_e=err((end-9):end);temp_err=abs(temp_e(1)-temp_e(end));
            if(early_stopping==1 && temp_err<tol)
                fprintf(['Mult algorithm converged, total iteration number is ', num2str(iter+1),'\n']);
                break;
            end
        end
    end
    iter = iter+1; 
end
rel_err = err/normV;
