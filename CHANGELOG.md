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
