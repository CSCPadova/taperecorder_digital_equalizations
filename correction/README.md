# correction #

The code contained in this directory can be used to correct the equalisation of an audio file following the specifications of CCIR and NAB equalisation standards, which are implemented in the reference tape recorder, the Studer A810.

## Installation

This code is written for Matlab R2020b, but it should work also for Octave: it is therefore only necessary to open the file in the desired IDE.

However, no Octave guarantee is provided, since Matlab and Octave methods differs in the implementation and could lead to slightly different results.

## Usage ##

The file to be executed is "main.m", which then calls file "correction.m" and eventually those contained in **plot_functions** directory.

File "main.m" presents the interaction with the user, where the input file and all equalisation parameters can be specified. By enabling specific flags, it also permits to:

- Plot several graphs related to the created filters;
- Save the impulse response in wave format of the filters.

All files are extensively commented and during execution there are several displayed messages that inform the user about the current status.