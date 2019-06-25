#!/bin/sh

set -e

sbt clean compile assembly

# Extract release version from build.sbt
releaseVersion="$(grep "^val releaseVersion = \".*\"" build.sbt | grep "\".*\"" -o | sed "s/\"//g")"
echo $releaseVersion

jar_path="$(grep "\"jar\": .*" project/Jobs | awk -F ":" '{print $2;}' | sed "s/\"//g")"

# Upload jar to bucket
python -m awscli s3 cp ${jar_path} s3://${BUCKET_NAME}/share/lib/${releaseVersion}/
