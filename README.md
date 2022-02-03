# Tape Recorder Digital Equalisations

This repository contains the code of a correction workflow and digital filters for restoring open-reel tape recordings digitised with incorrect speeds and equalisation standards. This tool can save (at least partially) the original content and can be used to create access copies listenable by users. The speed and equalisation standards considered in this work are the ones provided by a tape recorder Studer A810.

There are two main directories (**bold** indicates directory names):

- **correction**: it contains the files to perform the digital correction of an audio file resulting from the digitisation of an audio magnetic tape (see the inner README for further instructions);
- **evaluation**: it contains the files used to compare the samples described in the experiment.

## Getting Started

All code is written for Matlab R2020b. Code within **correction** directory should work also for GNU Octave, but please refer to the inner README for more information.

### Prerequisites

An activated copy of Matlab (tested on R2020b) or GNU Octave with “control” and “signal” packages installed.

## Authors

- **Nadir Dalla Pozza** - *Main developer*
- **Kurt James Werner** - *External Supervisor*
- [**Niccolò Pretto**](http://www.dei.unipd.it/~prettoni/) - *Supervisor*

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## References

[1] Niccolò Pretto, Nadir Dalla Pozza, Alberto Padoan, Anthony Chmiel, Kurt James Werner, Alessandra Micalizzi, Emery Schubert, Antonio Rodà, Simone Milani and Sergio Canazza, *A workflow and digital filters for compensating speed and equalization errors on digitized audio open-reel magnetic tapes*, Journal of Audio Engineering Society, 2022.
