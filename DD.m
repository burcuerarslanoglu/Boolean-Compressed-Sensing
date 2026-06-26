function x_estimate = DD(A, y)
    [num_tests, num_items] = size(A);  
    
    % Initialize variables
    x_estimate = false(num_items, 1);  % All items are (initially) non-defective
    possible_defectives = true(num_items, 1); 
    
    % Identify definite non-defectives from negative test results
    for i = 1:num_tests
        if y(i) == 0
            possible_defectives(A(i, :) == 1) = false;  % Items in a negative test are not defective
        end
    end
    
    % Identify definite defectives
    for i = 1:num_tests
        if y(i) == 1
            items_in_test = find(A(i, :) == 1);  % Items included in this test
            if sum(possible_defectives(items_in_test)) == 1  % Only one possible defective in this test
                % Mark the item as definitely defective
                x_estimate(items_in_test(possible_defectives(items_in_test))) = true;
            end
        end
    end
end