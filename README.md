release
=======

## Status
[![alt text][2]][1]

## Installation

The bytepark release manager should be installed - at the moment - as a clone of a 3.x tag.

The current stable tag is __3.0.5__.

The release manager __SHOULD__ never be invoked as clone of the master branch!

So to install the release manager issue the following commands:

    git clone -b 3.0 https://github.com/bytepark/release.git <target_directory>
    cd <target_directory>
    git checkout 3.0.5

## Introduction

The bytepark release manager is a collection of Bash shell script that provides different ways of releasing project files. Currently the following methods are available:

* rsync - rsync of files to target system
* tarball - generates a gzipped tarball
* rpm - generates a rpm package
* deb - generates a deb package
* dump - the inversion of rsync (we get a live copy into our development setup)

There is an optional dependency to "dialog" - in order to show interface widgets in interactive mode.

## Programm invocation

The release manager when invoked without further arguments enters interactive mode.

## Options

By executing ./release.sh -h you receive the full list of options

    bytepark release manager - $VERSION 
    Usage: release [OPTIONS]
 
    When OPTIONS is omitted the release manager executes
    in interactive mode, guiding the user in a step by step
    wizard through the release.
 
    Available options:
    -m  the method to use [rsync,tarball,rpm,deb,dump] 
    -t  the target system
    -b  optional git branch to release
    -r  optional git tag to release
 
    -f  direct execution (CAUTIOUS USE - no summary)
    -d  include database dump (CAUTIOUS USE - database is moved)
    -u  update repo server
 
    -v  version
    -h  help text


[1]: https://travis-ci.org/bytepark/release
[2]: https://api.travis-ci.org/bytepark/release.svg (build status)
