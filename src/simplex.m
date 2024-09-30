function simplex(filename)
    % Ladda in problemdatan
    data = load(filename);
    A = data.A;
    b = data.b;
    c = data.c;
    bix = data.bix;
    xcheat = data.xcheat;
    zcheat = data.zcheat;
    
    % Starta tidtagning
    tic;
    
    % Storleken på problemet
    [m, n] = size(A);

    % Skapa nix, dvs indexvektorn för ickebasvariabler
    nix = setdiff([1:n], bix);

    % Skapa initial partition
    B = A(:, bix);
    N = A(:, nix);
    cB = c(bix, :);
    cN = c(nix, :);
    
    % Initiera variabler
    opt = 0;
    iter = 0;
    
    while opt == 0
        iter = iter + 1;

        % Steg 1: Lös Bx_B = b för x_B
        xb = B \ b;

        % Steg 2: Beräkna reducerade kostnader c_N - c_B * inv(B) * A_N
        invB = inv(B);
        rc = cN' - cB' * invB * N;

        % Steg 3: Beräkna mest negativ reducerad kostnad och index för inkommande variabel
        [rc_min, inkix] = min(rc);
        
        if rc_min >= -1.0E-6
            opt = 1;
            disp('Optimum');
        else
            % Steg 4: Beräkna inkommande kolumn
            a = invB * A(:, nix(inkix));
            
            if max(a) <= 0
                disp('Obegränsad lösning');
                break;
            else
                % Steg 5: Bestäm utgående variabel
                theta = xb ./ a;
                theta(a <= 0) = Inf;  % Ignorera negativa och nollvärden
                [min_theta, utgix] = min(theta);

                % Utskrift av iterationens resultat
                z = cB' * xb;  % Målfunktionsvärde
                disp(sprintf('Iter: %d, z: %f, rc_min: %f, ink: %d, utg: %d', iter, z, rc_min, nix(inkix), bix(utgix)));
                
                % Steg 6: Uppdatera basen genom att byta ut bas- och ickebasvariabler
                bix(utgix) = nix(inkix);
                nix(inkix) = bix(utgix);

                % Uppdatera partitionerna skibidi toilett
                B = A(:, bix);
                N = A(:, nix);
                cB = c(bix, :);
                cN = c(nix, :);
            end
        end
    end
    
    % Avsluta tidtagning och skriv ut resultat
    elapsed_time = toc;
    z = cB' * xb;  % Målfunktionsvärde
    disp(sprintf('z: %f', z));
    x = zeros(n, 1);
    x(bix) = xb;
    disp(sprintf('sum(x-xcheat): %f', sum(x - xcheat)));
    disp(sprintf('z-zcheat: %f', z - zcheat));
    fprintf('Execution time: %.6f seconds\n', elapsed_time);  % Visa exekveringstid
end
