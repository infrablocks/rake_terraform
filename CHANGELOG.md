## Unreleased

## 1.23.0 (June 30th, 2022)

IMPROVEMENTS

* Allow environment to be provided for command invocation.

## 1.22.0 (March 19th, 2022)

IMPROVEMENTS

* Add support for fetching ARM Terraform binaries.

## 1.21.0 (January 30th, 2022)

IMPROVEMENTS

* Upgrade to latest ruby_terraform.

## 0.17.0 (May 1st, 2018)

IMPROVEMENTS:

* A validate task is now included and installed as part of the default task
  definition. 

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
