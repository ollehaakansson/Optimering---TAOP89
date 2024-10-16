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

# ---------
# find facility, find customer, send, at min cost
# set x and y
# deduct from ss and dd, 
# -------- 
while sum(rem_demand)>0:
    #initialize helping variables
    # inf to be replaced with an actual cost and -1 = no selected
    min_facility_cost = float('inf')
    selected_facility = -1
    min_shipping_cost = float('inf')
    selected_customer = -1
    
    # select facility with the lowest cost
    for facility_index in range(len(facility_cost)):
        if facility_cost[facility_index] >= 0 and facility_cost[facility_index] < min_facility_cost:
            min_facility_cost = facility_cost[facility_index]
            selected_facility = facility_index

    # select the customer with the lowest shipping cost for the chosen facility
    for customer_index in range(len(shipping_cost[selected_facility])):
        if shipping_cost[selected_facility][customer_index] < min_shipping_cost:
            min_shipping_cost = shipping_cost[selected_facility][customer_index]
            selected_customer = customer_index



elapsed = time.time() - t1
print('Tid: '+str('%.4f' % elapsed))

cost=sum(sum(np.multiply(transport_cost,x))) + epsilon*np.dot(fixed_cost,y)
print('Problem:',problem,' Totalkostnad: '+str(cost))
print('y:',y)
print('Antal byggda fabriker:',sum(y),'(av',num_sites,')')
