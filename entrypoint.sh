#!/bin/bash

set -e

# Extract release version from build.sbt
releaseVersion="$(grep "^.*val releaseVersion.*=.*\".*\"" build.sbt | grep -v '^.*//' | grep "\".*\"" -o | sed "s/\"//g")"
platformFrameworkVersion="$(grep "^.*val platformFrameworkVersion.*=.*\".*\"" project/Versions.scala | grep -v '^.*//' | grep "\".*\"" -o | sed "s/\"//g")"
gitTag=$(git describe --tags)

echo "release version in build.sbt : "${releaseVersion}
echo "gitTag : "${gitTag}
echo "framework version : "${platformFrameworkVersion}

if [[ $gitTag != v* ]]
then
    echo "git tag must starts with v"
    exit 1
fi

if [ "${gitTag:1}" = "${releaseVersion}" ]
then
     if [ "${releaseVersion:0:1}" = "${platformFrameworkVersion:0:1}" ]
     then
         echo "versions validation done"
     else
         echo "major release tag component doesn't match framework version major tag component in project/Versions.scala"
         echo "release version in build.sbt : "${releaseVersion}
         echo "framework version in project/Versions.scala : "${platformFrameworkVersion}
         exit 1
     fi
else
    echo "git tag doesn't match release tag in build.sbt"
    echo "tag : "${gitTag}
    echo "release version in build.sbt : "${releaseVersion}
    exit 1
fi

sbt clean compile assembly

jar_path="$(grep "\"jar\": .*" project/Jobs | awk -F ":" '{print $2;}' | sed "s/\"//g")"

# Upload jar to bucket
python -m awscli s3 cp ${jar_path} s3://${BUCKET_NAME}/share/lib/v${releaseVersion}/
