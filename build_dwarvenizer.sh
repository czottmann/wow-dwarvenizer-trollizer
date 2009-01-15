#!/bin/bash
# $Id: build_dwarvenizer.sh 315 2006-03-04 20:41:18Z carlo $

if [ ! $1 ];
then
    echo "Usage: build_dwarvenizer.sh <version>";
    exit;
fi

zip DwarvenizerTrollizer_$1.zip *.lua *.xml *.toc README CHANGELOG.txt

