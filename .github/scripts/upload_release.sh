#!/bin/bash
#
# Create a release on GitHub

if [ ! -e "RELEASE.md" ]; then
	echo "ERROR - No RELEASE.md file located!"
	echo "Please create a RELEASE.md file in the root of your repository"
	echo "  which contains the release notes for this version."
	exit 1
fi

if [ "$REF" == "" ]; then
	echo "ERROR - No 'REF' environment variable set!"
	echo "Example YAML step:"
	echo "      - name: Create Release"
	echo "        id: create_release"
	echo "        env:"
	echo "          REF: \${{ github.ref }}"
	exit 1
fi

if [[ "$REF" =~ "refs/heads/" ]]; then
	BRANCH="${REF//refs\/heads\//}"
	TAG="$BRANCH-$(date +%Y%m%d%H%M%S)"
	echo "Uploading $1 to release $BRANCH"
	gh release upload $BRANCH "$1"
elif [[ "$REF" =~ "refs/tags" ]]; then
	TAG="${REF//refs\/tags\//}"
	echo "Creating release with tag $TAG"
	URL="$(gh release create "$TAG" -d -F RELEASE.md --title "$PROJECT $TAG")"
	if [ $? -eq 0 ]; then
		echo "RELEASE_URL=$URL" >> $GITHUB_ENV
	else
		exit 1
	fi
else
	echo "ERROR - Invalid 'REF' environment variable value!"
	echo "Expected 'REF' to be either 'refs/heads/...' or 'refs/tags/...'"
	exit 1
fi