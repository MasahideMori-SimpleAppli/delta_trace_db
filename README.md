# delta_trace_db

(en)Japanese ver is [here](https://github.com/MasahideMori-SimpleAppli/delta_trace_db/blob/main/README_JA.md).  
(ja)この解説の日本語版は[ここ](https://github.com/MasahideMori-SimpleAppli/delta_trace_db/blob/main/README_JA.md)にあります。

## Caution
This software is currently under development.
Please note that it will not be available for use until this notice is removed.

## Plans for future updates
1. Add limited layers.
2. Add complex search methods.

## Overview
DeltaTraceDB is an in-memory database that simplifies change tracking and management by logging each operation as a delta.  
It is designed for sites with specific requirements, such as Japanese medical institutions,  
with a particular emphasis on small-scale, low-cost operations.  

The software is suitable for small- to medium-sized projects where low-volume data management,  
cost-efficiency, and security are priorities, and was developed with the aim of reducing the social burden of an aging population in mind.  
For large data sets and search speed requirements, we recommend using a general database.  

## Usage
Please check out the Examples tab in pub.dev.

## Support
Basically no support.  
If you have any problem please open an issue on Github.
This package is low priority, but may be fixed.

## About version control
The C part will be changed at the time of version upgrade.  
However, versions less than 1.0.0 may change the file structure regardless of the following rules.  
- Changes such as adding variables, structure change that cause problems when reading previous files.
    - C.X.X
- Adding methods, etc.
    - X.C.X
- Minor changes and bug fixes.
    - X.X.C

## License
This software is released under the Apache-2.0 License, see LICENSE file.

## Copyright notice
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.