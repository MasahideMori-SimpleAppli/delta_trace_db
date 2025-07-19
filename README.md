# delta_trace_db

(en)Japanese ver is [here](https://github.com/MasahideMori-SimpleAppli/delta_trace_db/blob/main/README_JA.md).  
(ja)この解説の日本語版は[ここ](https://github.com/MasahideMori-SimpleAppli/delta_trace_db/blob/main/README_JA.md)にあります。

## Overview
"DeltaTraceDB" is an in-memory database that stores data in units of lists of classes.
This database allows you to register class structures as they are in the database,  
and allows full-text searches of the elements of the registered classes.  
In addition, queries are also classes, and can have DB operation information consisting of   
who, when, what, why, and from.  
If serialized and saved, it provides a very rich source of information for security audits and 
usage analysis.  
This is particularly useful in projects with various constraints, such as medical use.  
In addition, for when, the TemporalTrace class has a complete tracing function for   
the communication path and each arrival time.  
I think this would be useful, for example, in space-scale communication networks and relay servers,
where non-negligible delays occur even at the speed of light.

## Speed
This package is an in-memory database, so it is generally fast.  
There is usually no problem with around 100,000 records.  
I recommend that you test it in an actual environment using speed_test.dart in the test folder.  
However, since it consumes RAM capacity according to the amount of data,  
if you need an extremely large database, consider using a general database.  
For reference, below are the results of a speed test (test/speed_test.dart) run on a slightly  
older PC equipped with a Ryzen 3600 CPU.  
The test conditions were chosen to take a sufficiently long time, but I think it will rarely cause   
any problems in practical use.  

```text
speed test for 100000 records                                                                                                                                                                                
start add
end add: 169 ms
start getAll (with object convert)
end getAll: 277 ms
returnsLength:100000
start save (with json string convert)
end save: 332 ms
start load (with json string convert)
end load: 248 ms
start search (with object convert)
end search: 514 ms
returnsLength:100000
start search paging, half limit pre search (with object convert)
end search paging: 414 ms
returnsLength:50000
start search paging by obj (with object convert)
end search paging by obj: 419 ms
returnsLength:50000
start search paging by offset (with object convert)
end search paging by offset: 395 ms
returnsLength:50000
start update at half index and last index object
end update: 59 ms
start updateOne of half index object
end updateOne: 13 ms
start conformToTemplate
end conformToTemplate: 68 ms
start delete half object (with object convert)
end delete: 241 ms
returnsLength:50000
```

## Usage
Please check out the Examples tab in pub.dev.  
Also, if you need a more complex example than the examples, check out the test folder.  

## Support
There is no support, but bugs are likely to be fixed.
If you find any issues, please open an issue on Github.

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

Copyright 2025 Masahide Mori

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.  

## Copyright notice
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.