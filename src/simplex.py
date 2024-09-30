import numpy as np
import time
import sys


# Run the code: python3 simplex.py <path-to-dataset>
# Process the data set (.npz-file)

filc=" ".join(sys.argv[1:]).split('.')[0]+'.npz'
npzfile = np.load(filc)
c=npzfile['c']
b=npzfile['b']
A=npzfile['A'] # values - nix has the corresponding indicies
bix=npzfile['bix']
zcheat=npzfile['zcheat']
xcheat=npzfile['xcheat']

bix=bix-1 # indicies base variables

t1=time.time()

[m,n] = np.shape(A)
print('Rows: '+repr(m)+' cols: '+repr(n))

# Create nix
nix=np.setdiff1d(range(n), bix) # indicies non-basic variables

B  = A[:, bix]
N  = A[:, nix]
cB = c[bix]
cN = c[nix]

# Start iterations
iter = 0

while iter >= 0:
    iter+=1
    
    # calc right-hand-sides and reduced costs
    # TODO: define rc_min.
    #
    #       Note: Slack variabels will not allways be basevariables.
    #             Slack variables will not allways be in the dataset.
    #             We want to implement slack variables ONE time before we Start.
    #             There will allways always be three variables.
    #
    #--------
    # calculate the inverse of B
    B_inv = np.linalg.inv(B)

    # compute the right hand sides (basic variabels values)
    # skalärprodukt
    x_b = np.dot(B_inv, b)

    # calculate the reduced cost for the non-basix varibales
    # "zero:ed" matrice with the size of nix
    rc = np.zeros(len(nix))

    # going through all non-basic variables in A with the helo of the indicies i nix.
    # i - is the index within the nix
    # j - is the index within the problem, meaning it corresponds to the column
    # in thre matrix A and vector c.
    for i, j in enumerate(nix):
        aj = A[:, j] # extracting the column corresponding to non-basic variable.
                     # A[:, j] select the entire column of A that corresponds with non-basic var x_j.
        

        # c[j] is the cost coefficient of the non-basic variable x_j from the objective function.
        # cB.T is the transpose of the cost vector for the basic variables. The transpose turns it into a row vector so it can be multiplied by the matrix.
        # B_inv is the inverse of the basis matrix B, which is formed from the columns of A that correspond to the basic variables.
        # aj is the column of matrix A corresponding to the non-basic variable x_j.

        rc[i] = c[j] - np.dot(np.dot(cB.T, B_inv), aj) # r_j = c_j - (C_B)^T * B^-1 * A_j

    # Find the the most negative reduced cost.
    rc_min = np.min(rc)
    inc_var = np.argmin(rc)

    # calc most negative reduced cost, rc_min,
    # and index for entering variable, inc_var
    # --------


    #reduced cost with a tolerance of 10^-6
    if rc_min >= -1.0E-6:
        print('Ready')
        iter=-1
 
        # construct solution, x, and check it
        x = np.zeros(n) # full solution vector (i.e. all variables)
        x[bix] = x_b # base variables
        z = np.dot(cB.T, x_b) # calculate the objective function value

        diffx = np.linalg.norm(x-xcheat)
        diffz = z-zcheat
        print('xdiff: '+repr(diffx))
        print('zdiff: '+repr(diffz))
    else:
        # entering variable is the one with the most reduced cost.
        inix = nix[inc_var]
        
        # calc entering column, a
        a = np.dot(B_inv, A[:, inix])


        if np.all(a <= 1e-10):
            # unbounded solution
            print('Unbounded solution!')
            iter=-1

        else:
            # Calculate the outgoing variable
            ratios = np.full(len(x_b), np.inf)  # Set the values to infinity as to not interfere with np.argmin
            for i in range(len(x_b)):
                if a[i] > 0:  # Only consider positive a values
                    ratios[i] = x_b[i] / a[i]

            utg_var = np.argmin(ratios)  # Find the variable with the minimum positive ratio

            # Print iteration information
            z = np.dot(cB.T, x_b)  # Calculate the current objective function value


            print(' Iter: '+repr(iter)+' z: '+repr(z)+' rc: '+repr(rc_min)+' ink: '+repr(inc_var+1)+' utg: '+repr(utg_var+1))

            # make new partition
            bix[utg_var], nix[inc_var] = nix[inc_var], bix[utg_var]
            
            #Update the basis and non-basis matrices after the pivot
            B = A[:, bix]  # Update the basis matrix
            N = A[:, nix]  # Update the non-basis matrix


elapsed = time.time() - t1
print('Elapsed time: '+repr(elapsed))

