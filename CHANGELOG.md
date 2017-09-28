## 0.16.0 (September 28th, 2017)

IMPROVEMENTS:

* The state file can now be specified as a lambda that receives task arguments
  and parameters and is expected to return the state file path.

## 0.11.1 (September 3rd, 2017)

IMPROVEMENTS:

* The plan rake task now passes from_module to init to specify the source 
  module

## 0.11.0 (September 3rd, 2017)

BACKWARDS INCOMPATIBILITIES / NOTES:

* Due to backwards incompatible changes in terraform 0.10, this release will
  only work with terraform >= 0.10.

IMPROVEMENTS:

* The provision rake task now passes from_module to init to specify the source 
  module
* The provision rake task now passes auto_approve as true to apply in 
  preparation for an upcoming terraform release that will set this flag to 
  false by default.
