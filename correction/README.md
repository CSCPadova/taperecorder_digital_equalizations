# correction #

The code contained in this directory can be used to correct the equalisation of an audio file following the specifications of CCIR and NAB equalisation standards, which are implemented in the reference tape recorder, the Studer A810.

## Getting Started

This code is written for Matlab R2020b, but it should work also for GNU Octave: it is therefore only necessary to open the file in the desired IDE.

However, no Octave guarantee is provided, since Matlab and Octave methods differs in the implementation and could lead to slightly different results.

### Prerequisites

An activated copy of Matlab (tested on R2020b) or GNU Octave.

## Usage ##

The file to be opened and executed is "main.m", which then calls file "correction.m" and eventually those contained in **plot_functions** directory. It is not necessary to manually add any file to the Matlab path.

File "main.m" presents the interaction with the user, where the input file and all equalisation parameters can be specified. By enabling specific flags, it also permits to:

- Plot several graphs related to the created filters;
- Save the impulse response in wave format of the filters.

All files are extensively commented and during execution there are several displayed messages that inform the user about the current status.

## Authors

- **Nadir Dalla Pozza** - *Main developer*
- **Niccolò Pretto** - *Supervisor*
- **Kurtis James Werner** - *Consultant*

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## References

[1] Niccolò Pretto, Nadir Dalla Pozza, Alberto Padoan, Anthony Chmiel, Kurt James Werner, Alessandra Micalizzi, Emery Schubert, Antonio Rodà, Simone Milani and Sergio Canazza, *A workflow and digital filters for compensating speed and equalization errors on digitized audio open-reel magnetic tapes*, 2022.

