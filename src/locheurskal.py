import numpy as np
import time
import sys
import copy

epsilon=1

problem=" ".join(sys.argv[1:]).split('.')[0]
file_name=problem+'.npz'

npzfile = np.load(file_name)
#npzfile.files
num_sites=npzfile['m']
num_customers=npzfile['n']
capacity_site=npzfile['s']
demand=npzfile['d']
fixed_cost=npzfile['f']
transport_cost=npzfile['c']

#print 'num_sites:',num_sites,' num_customers:',num_customers
#print 'capacity_site:',capacity_site
#print 'demand:',demand
#print 'fixed_cost:',fixed_cost
#print 'transport_cost:',transport_cost


# initialize solution variables
#x=np.zeros((num_sites,num_customers),dtype=np.int16)
#y=np.zeros((num_sites),dtype=np.int16)

alloc_matrix = np.zeros((num_sites,num_customers), dtype=np.int16)
facility_status = np.zeros((num_sites), dtype=np.int16)

#ss=copy.deepcopy(capacity_site)
#dd=copy.deepcopy(demand)
rem_capacity = copy.deepcopy(capacity_site)
rem_demand = copy.deepcopy(demand)

# Convert cost arrays to floats for large and negative values.
facility_cost = np.array(copy.deepcopy(fixed_cost), dtype=float)
shipping_cost = np.array(copy.deepcopy(transport_cost), dtype=float)


# counter
num_iterations = 0
# Start timer
t1=time.time()
while sum(rem_demand)>0:
    # find facility, find customer, send, at min cost
    # set x and y
    # deduct from ss and dd, 
    # -------- 



elapsed = time.time() - t1
print('Tid: '+str('%.4f' % elapsed))

cost=sum(sum(np.multiply(transport_cost,x))) + epsilon*np.dot(fixed_cost,y)
print('Problem:',problem,' Totalkostnad: '+str(cost))
print('y:',y)
print('Antal byggda fabriker:',sum(y),'(av',num_sites,')')
