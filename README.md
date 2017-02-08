release
=======

## Status
[![alt text][2]][1]

## Introduction

The bytepark release manager is a Bash shell script that provides different ways of deploying files. Currently the following methods are available:

* deploy - syncronisation of the files from development (in house) with the target system
* tarball - generates a gzipped tarball
* rpm - generates a rpm package
* deb - generates a deb package
* dump - the inversion of deploy (we get a live copy into our development setup)

There is currently a dependency to "dialog" - in order to show interface widgets in interactive mode.

## Programm invocation

The release manager when invoked without further arguments enters interactive mode.

## Workspace support

The tool now supports a permanent workspace to enhance the speed of releases. In the base working directory another directory layer is added. The new directories are __workspace__ and __build__.
  
_git_ now performs either a pull or a clone depending on whether the workspace already exists. 

Two new function hooks are introduced. __function_build_workspace__ and __function_build_deploy__. These are to replace __function_clone_post__. All actions to take that should last between relases, i.e. `composer install --no-dev` or `npm run build`, must be located in __function_build_workspace__. The release specific and cleanup actions must be located in __function_build_deploy__.

To enforce the changes in the specific release configuration, the new variable CONFIG_VERSION is tested for existence and the value _2_. If not set or not set to _2_ the tool will exit with a corresponding error message.

## Options

By executing ./release.sh -h you receive the full list of options

    bytepark release manager - $VERSION 
      Usage: release [OPTIONS]
 
    When OPTIONS is omitted the release manager executes
    in interactive mode, guiding the user in a step by step
    wizard through the release.
 
    Available options:
 	-m	the method to use [deploy,tarball,rpm,deb,dump]
 	-t	the target system
 	-b	optional git branch to release
 	-r	optional git tag to release
 
 	-f	direct execution (CAUTIOUS USE - no summary)
 	-d	include database dump (CAUTIOUS USE - database is moved)
 	-u	update repo server
 
 	-v	version
 	-h	help text


[1]: https://travis-ci.org/bytepark/release
[2]: https://api.travis-ci.org/bytepark/release.svg (build status)
