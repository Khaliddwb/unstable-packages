#!/bin/bash
##
##  Determine modified packages and build/upload them.
##

set -e

###############################################################################
##
##  Preparation.
##
###############################################################################

REPO_DIR=$(realpath "$(dirname "$(realpath "$0")")/../")
cd "$REPO_DIR" || {
	echo "[!] Failed to cd into '$REPO_DIR'."
	exit 1
}

DO_UPLOAD=false
if [ $# -ge 1 ]; then
	if [ "$1" = "--upload" ]; then
		DO_UPLOAD=true
	fi
fi

if [ "$LEGACY_ANDROID" = "true" ]; then
	BUILD_ENVIRONMENT="termux-packages-legacy"
else
	BUILD_ENVIRONMENT="termux-packages"
fi

if ! $DO_UPLOAD; then
	echo "[*] Initializing submodules:"
	echo
	git submodule update --init
	echo

	echo "[*] Copying packages to build environment:"
	echo
	for pkg in "${REPO_DIR}"/packages/*; do
		if [ -d "$pkg" ]; then
			if [ ! -e "${REPO_DIR}/${BUILD_ENVIRONMENT}/packages/$(basename "$pkg")" ]; then
				echo "    - $(basename "$pkg")"
				cp -a "$pkg" "${REPO_DIR}/${BUILD_ENVIRONMENT}"/packages/
			else
				echo "    - $(basename "$pkg"): package already exist, skipping"
			fi
		fi
	done
	echo
fi

###############################################################################
##
##  Determining changes.
##
###############################################################################

set +e

# Process tag '%ci:no-build' that may be added as line to commit message.
# Will force CI to exit with status 'passed' without performing build.
if grep -qiP '^\s*%ci:no-build\s*$' <(git log --format="%B" -n 1 "$CIRRUS_CHANGE_IN_REPO"); then
	echo "[*] Exiting with status 'passed' (tag '%ci:no-build' applied)."
	exit 0
fi

# Process tag '%ci:reset-backlog' that may be added as line to commit message.
# Will force CI to build changes only for the current commit.
if grep -qiP '^\s*%ci:reset-backlog\s*$' <(git log --format="%B" -n 1 "$CIRRUS_CHANGE_IN_REPO"); then
	echo "[*] Building only last pushed commit (tag '%ci:reset-backlog' applied)."
	unset CIRRUS_LAST_GREEN_CHANGE
	unset CIRRUS_BASE_SHA
fi

if [ -z "$CIRRUS_PR" ]; then
	if [ -z "$CIRRUS_LAST_GREEN_CHANGE" ]; then
		UPDATED_FILES=$(git diff-tree --no-commit-id --name-only -r "$CIRRUS_CHANGE_IN_REPO" 2>/dev/null | grep -P "packages/")
	else
		UPDATED_FILES=$(git diff-tree --no-commit-id --name-only -r "${CIRRUS_LAST_GREEN_CHANGE}..${CIRRUS_CHANGE_IN_REPO}" 2>/dev/null | grep -P "packages/")
	fi
else
	# Pull requests are handled in a bit different way.
	UPDATED_FILES=$(git diff-tree --no-commit-id --name-only -r "${CIRRUS_BASE_SHA}..${CIRRUS_CHANGE_IN_REPO}" 2>/dev/null | grep -P "packages/")
fi

## Determine modified packages.
existing_dirs=""
for dir in $(echo "$UPDATED_FILES" | grep -oP "packages/[a-z0-9+._-]+" | sort | uniq); do
	if [ -d "${REPO_DIR}/${dir}" ]; then
		existing_dirs+=" $dir"
	fi
done
PACKAGE_DIRS="$existing_dirs"
unset dir existing_dirs

## Get names of modified packages.
PACKAGE_NAMES=$(echo "$PACKAGE_DIRS" | sed 's/packages\///g')
if [ -z "$PACKAGE_NAMES" ]; then
	echo "[*] No modified packages found." >&2
	exit 0
fi

if [ "$LEGACY_ANDROID" = "true" ]; then
	## We have some packages disabled for Android API 21.
	## Exclude such packages from the build.
	EXCLUDED_PACKAGES="hashcat"
	
	for excluded_pkg in $EXCLUDED_PACKAGES; do
		PACKAGE_NAMES=$(echo "$PACKAGE_NAMES" | sed "s/\<${excluded_pkg}\>//g")
	done
	unset excluded_pkg
fi

set -e

###############################################################################
##
##  Building packages.
##
###############################################################################

if ! $DO_UPLOAD; then
	echo "[*] Building packages: $PACKAGE_NAMES"
	echo
	if [ "$LEGACY_ANDROID" = "true" ]; then
		echo "    Target OS: Android 5 (API level 21)"
	else
		echo "    Target OS: Android 7 (API level 24)"
	fi
	if [ -n "$CIRRUS_PR" ]; then
		echo "    Pull request: https://github.com/termux/unstable-packages/pull/${CIRRUS_PR}"
	else
		if [ -n "$CIRRUS_LAST_GREEN_CHANGE" ]; then
			echo "    Changes: ${CIRRUS_LAST_GREEN_CHANGE}..${CIRRUS_CHANGE_IN_REPO}"
		else
			echo "    Changes: ${CIRRUS_CHANGE_IN_REPO}"
		fi
	fi

	cd "${REPO_DIR}/${BUILD_ENVIRONMENT}" || {
		echo "[!] Failed to cd into '${REPO_DIR}/${BUILD_ENVIRONMENT}'."
		exit 1
	}

	echo
	for pkg in $PACKAGE_NAMES; do
		./build-package.sh -a "$TERMUX_ARCH" -I "$pkg"
	done
	echo
fi

###############################################################################
##
##  Storing packages in cache.
##
###############################################################################

if [ "$CIRRUS_BRANCH" = "master" ]; then
	if ! $DO_UPLOAD; then
		if [ "$LEGACY_ANDROID" = "true" ]; then
			ARCHIVE_NAME="debs-legacy-${TERMUX_ARCH}-${CIRRUS_CHANGE_IN_REPO}.tar.gz"
		else
			ARCHIVE_NAME="debs-${TERMUX_ARCH}-${CIRRUS_CHANGE_IN_REPO}.tar.gz"
		fi

		if [ -d "${REPO_DIR}/${BUILD_ENVIRONMENT}/debs" ]; then
			echo "[*] Archiving packages into '${ARCHIVE_NAME}'."
			tar zcf "$ARCHIVE_NAME" debs

			echo "[*] Uploading '${ARCHIVE_NAME}' to cache:"
			echo
			curl --upload-file "$ARCHIVE_NAME" \
				"http://$CIRRUS_HTTP_CACHE_HOST/${ARCHIVE_NAME}"
			echo
		fi
	else
		for arch in aarch64 arm i686 x86_64; do
			if [ "$LEGACY_ANDROID" = "true" ]; then
				ARCHIVE_NAME="debs-legacy-${arch}-${CIRRUS_CHANGE_IN_REPO}.tar.gz"
			else
				ARCHIVE_NAME="debs-${arch}-${CIRRUS_CHANGE_IN_REPO}.tar.gz"
			fi

			echo "[*] Downloading '$ARCHIVE_NAME' from cache:"
			echo
			curl --output "/tmp/${ARCHIVE_NAME}" \
				"http://$CIRRUS_HTTP_CACHE_HOST/${ARCHIVE_NAME}"
			echo

			if [ -s "/tmp/${ARCHIVE_NAME}" ]; then
				echo "[*] Unpacking '/tmp/${ARCHIVE_NAME}':"
				echo
				tar xvf "/tmp/${ARCHIVE_NAME}"
				echo
			else
				echo "[!] Empty archive '/tmp/${ARCHIVE_NAME}'."
			fi
		done

		echo "[*] Uploading packages to Bintray:"
		echo
		if [ "$LEGACY_ANDROID" = "true" ]; then
			"${REPO_DIR}/scripts/package_uploader_legacy.sh" -p "${PWD}/debs" $PACKAGE_NAMES
		else
			"${REPO_DIR}/scripts/package_uploader.sh" -p "${PWD}/debs" $PACKAGE_NAMES
		fi
	fi
fi
