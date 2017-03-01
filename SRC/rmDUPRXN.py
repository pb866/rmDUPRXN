import sys
import lhandle as lh
reload(sys)
sys.setdefaultencoding('UTF8')

# Retrieve file name from script arguments
try:
    ftee = sys.argv[1]
except:
    ftee = raw_input("Enter tee file from 'make kpp' process: ")

# Assure input file is one folder level above:
if ftee[:2] != '../':
    ftee = '../'+ftee


# Open input file
with open(ftee, 'r')  as f:
# save all lines in an array
    ll = f.readlines()
# find warnings about duplicate reactions
    duprxn = [dr for dr in ll if ": Duplicate equation: " in dr]
dupind, lkpp = lh.retrSTRNG(duprxn)

lh.wrtKPP(dupind,lkpp)
