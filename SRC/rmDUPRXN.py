import sys
reload(sys)
sys.setdefaultencoding('UTF8')


# Retrieve file name from script arguments
try:
    ifile = sys.argv[1]
except:
    ifile = raw_input("Enter tee file from 'make kpp' process: ")

# Assure input file is one folder level above:
print ifile[:2]
if ifile[:2] != '../':
    ifile = '../'+ifile

print ifile

# Open input file
with open(ifile,'r')  as f:
    lines = f.readlines()
    for i in range(len(lines)):
        print lines[i]
