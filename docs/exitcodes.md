# bytepark Release Manager - Exit Codes

The release manager can exit with several codes

## Success

0 	success

## Errors

### Invocation/Options CLI

10 When a CLI option is not defined
11 When an option misses an argument
12 When the provided options do not yield a configuration file

### Environment/Bootstrapping

20 When tools are missing on the system
21 When the call is not made in a project directory
22 
23

## Old map

10	not in a project directory
11	no release config dir found
12	no config files in .release
13	$REPOROOT not set in release configuration

20	no option selected

