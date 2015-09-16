#
# bytepark release manager - method.sh
#
# (c) 2011-2015 bytepark GmbH
#
# Please see the README file for further information.
# See the license information in the bundled LICENSE file.
#
# Template interface for the release method

METHOD_RSYNC=0
METHOD_TARBALL=1
METHOD_RPM=2
METHOD_DEB=3
METHOD_DUMP=4
METHOD_UPSYNC=5

METHODS=( rsync tarball rpm deb dump upsync )
METHOD_LABELS=( "Make a rsync deploy to a remote site" "Build a gzipped tarball" "Build a RPM Package" "Build a DEB Package" "Dump data from remote site" "Upsync data to remote site" )
