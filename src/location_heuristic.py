import numpy as np
import time
import sys
import copy

e=1

prob=" ".join(sys.argv[1:]).split('.')[0]
fil=prob+'.npz'

npzfile = np.load(fil)
npzfile.files
m=npzfile['m']
n=npzfile['n']
s=npzfile['s']
d=npzfile['d']
f=npzfile['f']
c=npzfile['c']
#print 'm:',m,' n:',n
#print 's:',s
#print 'd:',d
#print 'f:',f
#print 'c:',c

t1=time.time()
x=np.zeros((m,n),dtype=np.int)
y=np.zeros((m),dtype=np.int)

ss=copy.deepcopy(s)
dd=copy.deepcopy(d)

while sum(dd)>0:
    # find facility, find customer, send, at min cost
    # set x and y
    # deduct from ss and dd, 
    # --------



elapsed = time.time() - t1
print 'Tid: '+str('%.4f' % elapsed)

cost=sum(sum(np.multiply(c,x))) + e*np.dot(f,y)
print 'Problem:',prob,' Totalkostnad: '+str(cost)
print 'y:',y
print 'Antal byggda fabriker:',sum(y),'(av',m,')'

