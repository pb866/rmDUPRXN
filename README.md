rmDUPRXN
========

Python script to remove duplicate reactions from a kpp file and re-write
first entry with an overall reaction rate constant as sum of individual
rate constants. (Currently tested only for replacements in a single kpp
file.)

The script is designed for the DSMACC version DSMACC-testing from:
https://github.com/pb866/DSMACC-testing.git


Using the script
----------------

The script reads the warnings about duplicate reactions from the KPP
screen output from a file. So before the script, run KPP and write the
stdout to a file, e.g. by:

```shel
make kpp | tee make.tee
```

Run the script _rmDUPRXN_ with the command:

```shel
python rmDUPRXN.py [<input file>]
```

The scipt has the the optional argument for the tee file name. If
obsolete, the default name _make.tee_ is used.

Furthermore, the script has to be stored in a folder 1 level below the
main folder. The designated folder is _AnalysisTools_, but may be changed
to any folder that is placed in the main _DSMACC_ folder. The kpp file
must be placed in the _mechanisms_ folder, which is in the main _DSMACC_
folder. This way, the script can be directly applied in the
_DSMACC-testing_ environment.

If the tee file name is passed to the script (default or any other name),
it may be given with the path `../mechanisms/` to use the UNIX auto
complete function or without it for faster typing of the name. In the
latter case, the script will add the folder path to the file name.

There is no need to specify the _KPP file name_ as it is derived from
the _KPP_ warning messages.


Structure of the script
-----------------------

### Main script _rmDUPRXN_

- Reads in tee file name or uses default
- Retrieves warning messages from KPP screen output
- Calls _retrRXN_ from _srchRXN_ to generate dictionary with kinetic
  and mechanistic data and all line numbers of duplicate reactions
  from KPP warning messages
- Calls _cmbnRATES_ from _frmtRXN_ to reformat kinetic data and assign
  an overall rate constant as sum of individual constants (and product
  of individual constants of same kind)
- Calls _wrtKPP_ from _fhandle_ to rewrite the KPP file and replace
  duplicate reactions with one reaction with an overall rate constant


### Library _srchRXN_

- With function _retrRXN_ that loops over warning messages and retrieves
  line number of duplicate entry, and reaction number of duplicate reactions.
- _retrRXN_ calls _fndDRXN_ to find the actual line numbers in the KPP file from
  the warning messsage information.
- _fndDRXN_ uses _react_ to derive reactants and products from each KPP
  line rather than comparing the reaction strings as species might be in
  different order in the duplicate reactions.
- _retrRXN_ calls _makeDICT_ to generate a dictionary with information
  about kinetic and mechanistic data as well as line numbers of the
  duplicate reactions and passes them back to the main script together
  with the file name.
