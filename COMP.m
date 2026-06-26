function x_estimate = COMP(A, y)
    % Initialize all items as defective.
    x_estimate = ones(size(A, 2), 1); % Defective (1) until proven nondefective
    
    % Loop through each test outcome
    for test_idx = 1:length(y)
        if y(test_idx) == 0
            % If the test is negative, all items in that test are
            % nondefective => 0
            x_estimate(A(test_idx, :) == 1) = 0;
        end
    end
end