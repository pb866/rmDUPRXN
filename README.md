rmDUPRXN
========

Julia script to merge duplicate reactions in a kpp file by adding up the kinetic
data and deleting all but the first reaction. Comments in place of the deleted
reactions point to the new reactions with the merged kinetic data.

A previous and far more complicated python version exists in the _python_ folder,
but is now depricated. For more information, see the old [README](python/README.md).

The script is designed for the DSMACC version DSMACC-testing from:
https://github.com/pb866/DSMACC-testing.git.  
Follow the instructions below to install and run the script.


Installation
------------

Copy the julia script `rmDUPRXN.jl` and the `jl.mod` folder with the module with
programme-specific functions to `./mechanisms/programs/` in the DSMACC repository.
Alternatively, you can clone this repository or create a git submodule in
`./mechanisms/programs/`.

You will also need a general module for file handling shared by various julia scripts,
which can be obtained from the [auxdata repository](https://github.com/pb866/auxdata.git).
Clone the repository or copy the `fhandle.jl` from the `jl.mod` folder to a directory
of your liking.


Using the script
----------------

The script merges duplicate reactions in the file `ifile` and writes the revised
mechanism to the file `ofile`. If `ofile` is obsolete, `ifile` will be overwritten.
Additionally, you need to specify the `directory` of the `fhandle` module or the
default folder path `/Applications/bin/data/jl.mod/` will be used.  
If you omit the input file name, you will be ask for it during the execution of
the script. Run the script with:

```
julia rmDUPRXN.jl [<ifile> [<ofile> [<directory>]]]
```

The script is designed to be placed in `./mechanisms/programs/` in the DSMACC repository
and be executed either from the main repository folder (`./mechanisms/programs/rmDUPRXN/`)
or the `./mechanisms/` folder. If run from either of these locations, the folder path
for the input and output file in the script arguments is optional, if the mechanisms are
placed in the `mechanisms` folder, and will be added by the script automatically.

If different directories are used, the below adjustments have to be made in the main
script `rmDUPRXN.jl`.


Adjusting the script
--------------------

The script is designed to be placed in `./mechanisms/programs/rmDUPRXN/` and be
executed from this folder or the `./mechanisms/` folder in the DSMACC repository.
If you have any other file structure and your `jl.mod` folder is not in the same
folder as the main script, you need to push the folder path to `LOAD_PATH` on
l. 20 of `rmDUPRXN.jl`.

Furthermore, the script relies on an external module `fhandle`, which can be obtained
from https://github.com/pb866/auxdata.git. The folder path, where `fhandle` is stored has
to be specified in the third script argument, if different from the default directory
`/Applications/bin/data/jl.mod/`. It is convenient to change the default directory
to your location of `fhandle`, if the script is used regularly, which can be done
on l. 16 of `rmDUPRXN.jl`.


Version history
===============

Version 2.0
-----------
- Julia script merging duplicate reactions directly from kpp file without the
  need of the kpp warnings in a tee file
- Additional option to write revised reactions to a different output file


Version 1.0
-----------
- Python script merging duplicate reactions from the warning messages of the last
  kpp run written to a tee file
