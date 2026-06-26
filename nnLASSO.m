function x_estimate = nnLASSO(A, y, lambda)
    [x_estimate, FitInfo] = lasso(A, double(y), 'Lambda', lambda, 'Alpha', 1, 'CV', 10);
    
    % For finding the lambda with lowest MSE
    % bestLambda = 0;
    % minMSE = inf;
    % bestX = [];

    % idxLambda1SE = FitInfo.Index1SE;
    % mse = FitInfo.MSE(idxLambda1SE);
    % if mse < minMSE
    %     minMSE = mse;
    %     bestLambda = lambda;
    %     bestX = B(:, idxLambda1SE);
    % end
end