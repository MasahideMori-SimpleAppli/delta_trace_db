# delta_trace_db

(en)Japanese ver is [here](https://github.com/MasahideMori-SimpleAppli/delta_trace_db/blob/main/README_JA.md).  
(ja)この解説の日本語版は[ここ](https://github.com/MasahideMori-SimpleAppli/delta_trace_db/blob/main/README_JA.md)にあります。

## Caution
This software is currently under development.
Please note that it will not be available for use until this notice is removed.

## Overview
An in-memory database that logs each operation (using a unit called delta) to make it easy to track and manage differences.
It is optimized for sites with specific requirements, including medical institutions in Japan.
This software is not designed for large-scale operation.
This software is useful for small-scale data sets where convenience, cost, security, etc. are more important than search speed.
In all other cases, please consider a traditional database.

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