#!/usr/bin/env bash

### Windows
# to run with Bash: "C:\Program Files\Git\bin\bash.exe" ./build/build.sh
###

export APP_NAME="VSCodium"
export CI_BUILD="no"
export SHOULD_BUILD="yes"
export SKIP_ASSETS="yes"
export SKIP_BUILD="no"
export SKIP_SOURCE="no"
export VSCODE_LATEST="no"
export VSCODE_QUALITY="stable"

while getopts ":ilop" opt; do
  case "$opt" in
    i)
      export VSCODE_QUALITY="insider"
      ;;
    l)
      export VSCODE_LATEST="yes"
      ;;
    o)
      export SKIP_BUILD="yes"
      ;;
    p)
      export SKIP_ASSETS="no"
      ;;
    s)
      export SKIP_SOURCE="yes"
      ;;
  esac
done

case "${OSTYPE}" in
  darwin*)
    export OS_NAME="osx"
    ;;
  msys* | cygwin*)
    export OS_NAME="windows"
    ;;
  *)
    export OS_NAME="linux"
    ;;
esac

UNAME_ARCH=$( uname -m )

if [[ "${UNAME_ARCH}" == "arm64" ]]; then
  export VSCODE_ARCH="arm64"
elif [[ "${UNAME_ARCH}" == "ppc64le" ]]; then
  export VSCODE_ARCH="ppc64le"
else
  export VSCODE_ARCH="x64"
fi

echo "OS_NAME=\"${OS_NAME}\""
echo "SKIP_SOURCE=\"${SKIP_SOURCE}\""
echo "SKIP_BUILD=\"${SKIP_BUILD}\""
echo "SKIP_ASSETS=\"${SKIP_ASSETS}\""
echo "VSCODE_ARCH=\"${VSCODE_ARCH}\""
echo "VSCODE_LATEST=\"${VSCODE_LATEST}\""
echo "VSCODE_QUALITY=\"${VSCODE_QUALITY}\""

if [[ "${SKIP_SOURCE}" == "no" ]]; then
  rm -rf vscode* VSCode*

  . get_repo.sh
  . version.sh

  # save variables for later
  echo "MS_TAG=\"${MS_TAG}\"" > build.env
  echo "MS_COMMIT=\"${MS_COMMIT}\"" >> build.env
  echo "RELEASE_VERSION=\"${RELEASE_VERSION}\"" >> build.env
  echo "BUILD_SOURCEVERSION=\"${BUILD_SOURCEVERSION}\"" >> build.env
else
  if [[ "${SKIP_ASSETS}" != "no" ]]; then
    rm -rf VSCode*
  fi

  . build.env

  echo "MS_TAG=\"${MS_TAG}\""
  echo "MS_COMMIT=\"${MS_COMMIT}\""
  echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""
  echo "BUILD_SOURCEVERSION=\"${BUILD_SOURCEVERSION}\""
fi

if [[ "${SKIP_BUILD}" == "no" ]]; then
  if [[ "${SKIP_SOURCE}" != "no" ]]; then
    cd vscode || { echo "'vscode' dir not found"; exit 1; }

    git add .
    git reset -q --hard HEAD

    cd ..
  fi

  . build.sh

  if [[ "${VSCODE_QUALITY}" == "insider" && "${VSCODE_LATEST}" == "yes" ]]; then
    echo "$( cat "insider.json" | jq --arg 'tag' "${MS_TAG/\-insider/}" --arg 'commit' "${MS_COMMIT}" '. | .tag=$tag | .commit=$commit' )" > "insider.json"
  fi
fi

if [[ "${SKIP_ASSETS}" == "no" ]]; then
  if [[ "${OS_NAME}" == "windows" ]]; then
    rm -rf build/windows/msi/releasedir
  fi

  . prepare_assets.sh
fi
