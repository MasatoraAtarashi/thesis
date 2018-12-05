#!/usr/bin/env bash

set -eux

PDF_FILE="build/thesis.pdf"
TAG=$(date +'%Y%m%d.%H%M%S')
DATE=$(date +'%Y/%m/%d %H:%M:%S')

git tag $TAG
git push --tags
echo "New tag: $TAG"

$GHR -n "$DATE" --prerelease --delete --replace "$TAG" "$PDF_FILE"
