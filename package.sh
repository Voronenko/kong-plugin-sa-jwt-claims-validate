#!/bin/bash

set -e

PLUGIN=`basename "$PWD"`
VERSION=`echo *.rockspec | sed "s/^.*-\([0-9.]*\.[0-9]*\.[0.-9]*-[0-9]*\)\.rockspec/\1/"`

echo "Building plugin $PLUGIN with version $VERSION"

#-------------------------------------------------------
# Remove existing archive directory and create a new one
#-------------------------------------------------------
echo Remove existing archive directory and create a new on
rm -rf $PLUGIN || true
rm -f $PLUGIN-$VERSION.tar.gz || true
mkdir -p $PLUGIN

#----------------------------------------------
# Copy files to be archived to archive directory
#----------------------------------------------
echo Copy files to be archived to archive directory
cp -R ./kong $PLUGIN
cp README.md LICENSE *.rockspec $PLUGIN

#--------------
# Archive files
#--------------
echo Archive files
tar cvzf $PLUGIN-$VERSION.tar.gz $PLUGIN

#-------------------------
# Remove archive directory
#-------------------------
echo Remove archive directory
rm -rf $PLUGIN || true

#-------------------------
# Create a rock
#-------------------------
#echo Make rock
#luarocks make
#echo Pack rock
#luarocks pack $PLUGIN $VERSION
