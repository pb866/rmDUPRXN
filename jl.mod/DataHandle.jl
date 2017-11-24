__precompile__()


"""
# Module DataHandle

Functions for file and data handling needed by script `rmDUPRXN` to merge
duplicate reactions in a kpp file.

# Public functions
- find_rxn
- split_mech
- get_mechdata
- merge_DUPL
- wrt_mech

# Private functions
- get_bratio
- combine_spc
"""
module DataHandle

# Import functions
import fhandle.test_dir

### Public functions ###
export find_rxn,
       split_mech,
       get_mechdata,
       merge_DUPL,
       wrt_mech


"""
    function find_rxn(mech)

Find the first line with a reaction in the data lines `mech` of a kpp file.
"""
function find_rxn(mech)
  try
    return find([contains(line,"#EQUATIONS") for line in mech])[1]+1
  catch
    println("Missing keyword '#EQUATIONS' for start of reactions. Script stopped.")
    exit()
  end
end #function find_rxn


"""
    split_mech(kpp,start_rxn)

Return an array `mech` with the reaction numbers, the mechanistic and kinetic data
retrieved from the data `kpp` with all lines from a kpp file. The data retrieval
is started at line `start_rxn` with the first reaction.
"""
function split_mech(kpp,start_rxn)
  # Initialise mech
  mech = []
  # Loop over all reaction lines of the kpp file
  for line in kpp[start_rxn:end]
    # Save empty or comment lines unchanged and split reaction lines in an array
    # holding the reaction number, mechanistic and kinetic data
    if line==""
      push!(mech,line)
    elseif line[1:2]=="//"
      push!(mech,line)
    else
      # Use regex to find reaction numbers, mechanistic and kinetic data
      nmbr = match(r"^{(.*)}",line).captures[1]
      rxn = strip(match(r"}(.*):",line).captures[1])
      kindata = strip(match(r":(.*);",line).captures[1])
      # Save split reaction data in mech
      push!(mech,[nmbr rxn kindata])
    end
  end

  # Return the final mechanism array
  return mech
end #function split_mech


"""
    get_mechdata(mech)

Return reaction numbers `label`, reactants `educt`, products `product`, and
kinetic data `kindata` from the data saved in `mech`.
"""
function get_mechdata(mech)

  # Initialise output arrays
  educts = []; products = []; kindata = []; label = []

  # Loop over mechanism data
  for (i, data) in enumerate(mech)
    if typeof(data) == String
      # Store dummy data for empty and comment lines
      push!(label,data); push!(kindata,"//")
      push!(educts,[1 "//" "//"]); push!(products,[1 "//" "//"])
    else
      # Split mechanistic data into arrays of single reactants and products
      ed, prod = split.(strip.(split(data[2],"=")),"+")
      ed = strip.(ed); prod = strip.(prod)
      ed = split.(ed," "); prod = split.(prod," ")

      # Retrieve branching ratios associated with each species or assign br = 1
      edmat = get_bratio(ed); prodmat = get_bratio(prod)
      # Combine same educts/products and adjust the branching ratios
      edmat = combine_spc(edmat); prodmat = combine_spc(prodmat)

      # Save reaction numbers, educt/product arrays and kinetic data
      push!(educts,edmat); push!(products,prodmat)
      push!(label,data[1]); push!(kindata,data[3])
    end
  end

  # Return adjusted mechanism data
  return label, educts, products, kindata
end #function get_mechdata


"""
    merge_DUPL(label, educts, products, kindata)

Find duplicate reactions by comparing `educts` and `products` and combining the
kinetic data `kindata`. The first reaction is printed, for the other reactions
a comment is printed in the kpp file in which reaction with what `label` the
reaction has been merged.

Returns adjusted labels, educts, products, and kinetic data.
"""
function merge_DUPL(label, educts, products, kindata)

  # Loop over reactions
  for i = 1:length(kindata)-1
    if kindata[i] != "//" # Ignore comments and empty lines
      for j = i+1:length(kindata)
        # Find reactions with equal educts and products
        if educts[i][:,2:3] == educts[j][:,2:3] && products[i][:,2:3] == products[j][:,2:3]
          # Combine the kinetic data
          if kindata[i] == kindata[j]
            kindata[i] = "2.0*("*kindata[i]*")"
          else
            kindata[i] *= "+"*kindata[j]
          end
          # Delete second reaction and put a comment in the kpp file
          kindata[j] = "//"
          label[j] = "//Reaction $(label[j]) has been merged with reaction $(label[i])"
        end
      end
    end
  end

  # Restore the original order of species in the reaction
  for i = 1:length(educts)  educts[i] = sortrows(educts[i],by=x->x[1])  end
  for i = 1:length(products)  products[i] = sortrows(products[i],by=x->x[1])  end

  # Return the adjusted mechanism data
  return label, educts, products, kindata
end #function merge_DUPL


"""
    wrt_mech(file, start_rxn, kpp, label, educts, products, kindata)

Write revised mechanism to output `file` using the `kpp` data for the non-
mechanistic part of the kpp file until line `start_rxn` and the adjusted
`label`s, `educts`, `products`, and kinetic data `kindata`.
"""
function wrt_mech(file, def_dir, start_rxn, kpp, label, educts, products, kindata)
  # Use file name from second script argument or overwrite input file,
  # if argument is obsolete
  if file[2] == ""  file[2] = file[1]  end
  file[2] = test_dir(file[2],default_dir=def_dir)

  # Write to file
  open(file[2],"w") do f
    # Print initial part of kpp file up to the reaction section
    for line in kpp[1:start_rxn-1]  println(f,line)  end
    for (i, kin) = enumerate(kindata)
      # Print comments and empty lines unchanged
      if kin == "//"  println(f, label[i])
      else
        # Print reaction numbers
        rxn = "{"*label[i]*"}"*" \t "
        # Print reactants (in case of multiple reactants of same kind,
        # don't use branching ratios)
        for j = 1:length(educts[i][:,3])
          for k = 1:Int(educts[i][j,2])
            rxn *= "$(educts[i][j,3]) + "
          end
        end
        # Print reaction sign and products
        rxn = rxn[1:end-2]*"= "
        for j = 1:length(products[i][:,3])
          if products[i][j,2] == 1
            rxn *= products[i][j,3]*" + "
          else
            rxn *= string(products[i][j,2])*" "*products[i][j,3]*" + "
          end
        end
        # Print kinetic data
        rxn = rxn[1:end-2]*": \t"*kindata[i]*" \t;"
        # Write completed reaction to output file
        println(f, rxn)
      end
    end
  end
end #function wrt_mech


### Private functions ###

"""
    get_bratio(rxn)

From species list `rxn` of the lefthand or righthand side of a reaction, retrieve
the associated branching ratios to each species and return the array `mat` with
an index `i` of the original order of the species in the reaction, the branching
ratios `bratio`, and the species name `spc`.
"""
function get_bratio(rxn)
  # Initialise Matrix for species
  mat = Matrix{Any}(0,3)
  # Loop over species
  for i = 1:length(rxn)
    try spc = strip(rxn[i][2])
      # Try to retrieve the branching ratio
      bratio = parse(Float64,rxn[i][1])
      # Store position index, branching ratio and species name for current species
      mat = [mat; i bratio spc]
    catch
      # If no branching ratio exists, store position index, standard branching ratio
      # of 1, and species name
      mat = [mat; i 1.00 strip(rxn[i][1])]
    end
  end

  # Return mechanistic data
  return mat
end #function split_rxn


"""
    combine_spc(mat)

In matrix `mat` with position index, branching ratios and species names, combine
same species by adjusting the branching ratio under the lowest species index and
return the refined matrix sorted by species names.
"""
function combine_spc(mat)
  # Initialise loop counter
  i = 0
  # Loop over species matrix (length might shorten during looping, therefore while loop)
  while i < length(mat[:,1])
    i += 1 # Increase counter
    # Find duplicate species
    hit=find([mat[i,3]==elem for elem in mat[:,3]])
    # Combine branching ratios and delete species with higher position index
    for j = length(hit):-1:2
      mat[hit[1],2] += mat[hit[j],2]
      mat = mat[setdiff(1:end,hit[j]),:]
    end
  end

  # Return revised species matrix sorted by species names
  return mat = sortrows(mat, by=x->x[3])
end #function combine_spc

end #module DataHandle
