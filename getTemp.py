#!/usr/bin/env python
#script to read a file and extract a number

fo = open("/usr/local/bin/sysTemp") # Open a file
str = fo.read(); # read characters in sysTemp
fo.close() # close opened file
print('string = ',str) # print string to check
t=eval(str) # convert string into number
print ('extracted number = ',t) # print evaluated number
t2=t*2 # multiply by 2, evaluated number
print('twice temp in milli-degrees = ',t2) # print result of multiplication
t3=(t/1000.00) # convert five figure temp (milli-degrees) to degrees to two decimal places
print ('temperature in degrees = ',t3) # print result

