import numpy as np
import time
import sys


# Run the code: python3 simplex.py <path-to-dataset>
# Process the data set (.npz-file)

filc=" ".join(sys.argv[1:]).split('.')[0]+'.npz'
npzfile = np.load(filc)
c=npzfile['c']
b=npzfile['b']
A=npzfile['A']
bix=npzfile['bix']
zcheat=npzfile['zcheat']
xcheat=npzfile['xcheat']

bix=bix-1

t1=time.time()

[m,n] = np.shape(A)
print('Rows: '+repr(m)+' cols: '+repr(n))

# Create nix
nix=np.setdiff1d(range(n), bix) 

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


    # calc most negative reduced cost, rc_min,
    # and index for entering variable, inkvar
    # --------


    #reduced cost with a tolerance of 10^-6
    if rc_min >= -1.0E-6:
        print('Ready')
        iter=-1
 
        # construct solution, x, and check it
        # --------

        diffx = np.linalg.norm(x-xcheat)
        diffz = z-zcheat
        print('xdiff: '+repr(diffx))
        print('zdiff: '+repr(diffz))
    else:
        # calc entering column, a
        # --------

        if max(a) <= 0 :
            # unbounded solution
            print('Unbounded solution!')
            iter=-1
        else:
            # calc leaving var, utgvar
            # --------


            print(' Iter: '+repr(iter)+' z: '+repr(z)+' rc: '+repr(rc_min)+' ink: '+repr(inkvar+1)+' utg: '+repr(utgvar+1))

            # make new partition
            # --------


elapsed = time.time() - t1
print('Elapsed time: '+repr(elapsed))

