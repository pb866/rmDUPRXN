#!/usr/local/anaconda/bin/julia


"""
# Module rmDUPRXN

Merge duplicate reactions in a kpp file by adding up the kinetic data and
deleting all but the first reaction.
"""
module rmDUPRXN

println("initialise...")
# Define location of self-made modules
# (use 3. script argument for general module path)
try push!(LOAD_PATH,ARGS[3])
catch
  push!(LOAD_PATH,"/Applications/bin/data/jl.mod")
  push!(LOAD_PATH,"~/Util/auxdata/jl.mod")
end
# Assume either DSMACC/mechanisms or DSMACC/mechanisms/programs/rmDUPRXN
# as current directory, other wise add/adjust folder path here:
push!(LOAD_PATH,"./jl.mod"); push!(LOAD_PATH,"programs/rmDUPRXN/jl.mod")
if splitdir(pwd())[2] != "mechanisms"  def_dir = "../.."
else def_dir = "."
end
# Load modules/functions
using fhandle: test_file, rdfil
using DataHandle
# Set missing arguments to empty strings
for i = 1:2-length(ARGS)  push!(ARGS,"")  end

println("read data...")
# Read all lines from kpp file
ARGS[1] = test_file(ARGS[1], default_dir=def_dir)
kpp = rdfil(ARGS[1])
# Define start of reactions and get mechanism data
start_rxn = find_rxn(kpp)
mech = split_mech(kpp, start_rxn)
# Split data into reaction numbers, educts/products, and kinetic data
label, educts, products, kindata = get_mechdata(mech)
# Merge duplicate reactions
println("merge duplicate reactions...")
label, educts, products, kindata = merge_DUPL(label, educts, products, kindata)
# Print reactions to output file (defined by 2. script argument)
# or overwrite kpp file, if 2. argument is blank
println("write revised mechanism...")
wrt_mech(ARGS[1:2], def_dir, start_rxn, kpp, label, educts, products, kindata)
println("done.")
end #module rmDUPRXN
