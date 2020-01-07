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

sbt clean compile assembly

jar_path="/github/workspace/target/scala-2.10/data-sync.jar"
python -m awscli s3 cp ${jar_path} s3://${BUCKET_NAME}/share/lib/v${releaseVersion}/data-sync_5.6.jar --profile ga

sbt -DelasticVersion=2.3 clean compile assembly
python -m awscli s3 cp ${jar_path} s3://${BUCKET_NAME}/share/lib/v${releaseVersion}/data-sync_2.3.jar --profile ga
