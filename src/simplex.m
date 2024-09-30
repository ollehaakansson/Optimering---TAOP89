function simplex_solver(filename)
    % Load the problem data
    data = load(filename);
    A = data.A;
    b = data.b;
    c = data.c;
    bix = data.bix;
    xcheat = data.xcheat;
    zcheat = data.zcheat;
    
    % Initial setup
    B = A(:, bix);  % Basis matrix
    nix = setdiff(1:size(A, 2), bix);  % Non-basic variables
    max_iterations = 100;  % Just to avoid infinite loops
    tolerance = 1e-6;
    
    % Start timer
    tic;
    
    for iter = 1:max_iterations
        % Step 1: Solve Bx_B = b for x_B
        x_B = B \ b;
        
        % Step 2: Calculate reduced costs c_N - c_B * inv(B) * A_N
        c_B = c(bix);
        c_N = c(nix);
        invB = inv(B);
        reduced_costs = c_N' - c_B' * invB * A(:, nix);
        
        % Step 3: Check optimality
        if all(reduced_costs >= -tolerance)
            disp('Optimal solution found');
            x = zeros(size(c));  % Full solution
            x(bix) = x_B;
            z = c' * x;  % Objective function value
            
            % Stop the timer and display execution time
            elapsed_time = toc;
            
            fprintf('Optimal x:\n');
            disp(x);
            fprintf('Optimal z: %f\n', z);
            fprintf('Difference to cheat solution: ||x - xcheat|| = %f\n', norm(x - xcheat));
            fprintf('Difference in objective function: |z - zcheat| = %f\n', abs(z - zcheat));
            fprintf('Execution time: %.6f seconds\n', elapsed_time);  % Display elapsed time
            return;
        end
        
        % Step 4: Choose entering variable (most negative reduced cost)
        [min_val, inix] = min(reduced_costs);
        if min_val >= 0
            disp('Solution is optimal.');
            break;
        end
        entering_var = nix(inix);
        
        % Step 5: Calculate the direction vector d_B
        d_B = invB * A(:, entering_var);
        
        % Step 6: Determine leaving variable
        theta = x_B ./ d_B;
        theta(d_B <= 0) = Inf;  % Ignore non-positive directions
        [min_theta, outix] = min(theta);
        if isinf(min_theta)
            disp('The problem is unbounded.');
            
            % Stop the timer and display execution time
            elapsed_time = toc;
            fprintf('Execution time: %.6f seconds\n', elapsed_time);  % Display elapsed time
            return;
        end
        leaving_var = bix(outix);
        
        % Step 7: Update the basis
        bix(outix) = entering_var;
        nix(inix) = leaving_var;
        B = A(:, bix);  % Update basis matrix
    end
    
    % Stop the timer if max iterations reached and display execution time
    elapsed_time = toc;
    disp('Maximum iterations reached.');
    fprintf('Execution time: %.6f seconds\n', elapsed_time);  % Display elapsed time
end
