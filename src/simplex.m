
function simplex(filename)
    % Load the problem data
    data = load(filename);
    A = data.A;
    b = data.b;
    c = data.c;
    basic_vars = data.bix;  % Basic variables
    optimal_solution = data.xcheat;
    optimal_value = data.zcheat;
    
    % Start timing the execution
    tic;
    
    % Problem dimensions
    [m, n] = size(A);

    % Create the nonbasic variable index vector
    nonbasic_vars = setdiff(1:n, basic_vars);

    % Initial partition
    B = A(:, basic_vars);
    N = A(:, nonbasic_vars);
    cB = c(basic_vars, :);
    cN = c(nonbasic_vars, :);
    
    % Initialize variables
    is_optimal = false;
    iteration = 0;
    
    while ~is_optimal
        iteration = iteration + 1;

        % Step 1: Solve B * x_B = b for x_B
        xB = B \ b;

        % Step 2: Calculate reduced costs c_N - c_B * inv(B) * A_N
        invB = inv(B);
        reduced_costs = cN' - cB' * invB * N;

        % Step 3: Find the most negative reduced cost and the index of the entering variable
        [min_reduced_cost, entering_index] = min(reduced_costs);
        
        if min_reduced_cost >= -1.0E-6
            is_optimal = true;
            disp('Optimal solution found');
        else
            % Step 4: Calculate the entering column
            entering_column = invB * A(:, nonbasic_vars(entering_index));
            
            if max(entering_column) <= 0
                disp('Unbounded solution');
                break;
            else
                % Step 5: Determine the leaving variable
                theta = xB ./ entering_column;
                theta(entering_column <= 0) = Inf;  % Ignore non-positive values
                [min_theta, leaving_index] = min(theta);

                % Print the iteration results
                objective_value = cB' * xB;  % Objective function value
                fprintf('Iter: %d, Objective: %f, Min Reduced Cost: %f, Entering: %d, Leaving: %d\n', ...
                        iteration, objective_value, min_reduced_cost, nonbasic_vars(entering_index), basic_vars(leaving_index));
                
                % Step 6: Update the basis by swapping basic and nonbasic variables
                temp = basic_vars(leaving_index);
                basic_vars(leaving_index) = nonbasic_vars(entering_index);
                nonbasic_vars(entering_index) = temp;

                % Update partitions
                B = A(:, basic_vars);
                N = A(:, nonbasic_vars);
                cB = c(basic_vars, :);
                cN = c(nonbasic_vars, :);
            end
        end
    end
    
    % Stop timing and print results
    elapsed_time = toc;
    objective_value = cB' * xB;  % Final objective function value
    fprintf('Final Objective Value: %f\n', objective_value);
    x = zeros(n, 1);
    x(basic_vars) = xB;
    fprintf('Sum of differences with optimal solution: %f\n', sum(x - optimal_solution));
    fprintf('Difference in objective value: %f\n', objective_value - optimal_value);
    fprintf('Execution time: %.6f seconds\n', elapsed_time);  % Display execution time
end

