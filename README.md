release
=======

## Introduction

The bytepark release manager is a Bash shell script that provides different ways of deploying files. Currently the following methods are available:

* deploy - syncronisation of the files from development (in house) with the target system
* tarball - generates a gzipped tarball
* rpm - generates a rpm package
* deb - generates a deb package
* dump - the inversion of deploy (we get a live copy into our development setup)

## Programm invocation

The release manager when invoked without further arguments enters interactive mode.
