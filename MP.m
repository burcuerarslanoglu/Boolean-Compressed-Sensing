function z = MP(A, y, epsilon)
    % Initialize the sparse coefficient vector z to all zeros.
    z = zeros(size(A,2), 1);
    
    % Initialize the residual r to y, and double to make do calc.
    r = double(y);
    % Initialize a variable to keep track of used atoms
    used_atoms = false(1, size(A, 2)); % 100 in this case
    
    % Loop until the stopping criterion is met (epsilon or all col used)
    it = 0;
    while norm(r, 2) > epsilon
        % Compute the inner products between A's columns and r.
        inner_products = A' * r;
        inner_products(inner_products < 0) = 0;
        % Find the index of the column with the maximum inner product.
        % Exclude already used atoms.
        [inner_product_values, indices] = sort(abs(inner_products), 'descend');

        k = find(~used_atoms(indices), 1, 'first');
        max_col_index = indices(k);

        % Check if we found an unused atom
        if isempty(max_col_index)
            break;
        end
        
        % Update the coefficient of the chosen atom.
        z(max_col_index) = z(max_col_index) + inner_products(max_col_index);
        
        % Update the residual by reapplying the boolean operation.
        r = double(y) - double(A * z >= 1);
        % This atom will not be used again so:
        used_atoms(max_col_index) = true;
        it = it + 1; 
    end
end