#!/bin/bash

echo "Creating project for package"

if [ -z "${UNITY_APP}" ]; then
  echo "UNITY_APP env var not defined. Cannot find installed Unity version."
  exit 1
fi

PACKAGE_FILE="$(pwd)/package.json"

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Project is not a package."

    if [ ! -z "${UNITY_PROJECT_FOLDER}" ]; then
      #If environment configured a project folder use that to set the path
      UNITY_PROJECT_PATH="$(pwd)/${UNITY_PROJECT_FOLDER}"
    else
      #If environment configuration not set then assume repo root is project root
      UNITY_PROJECT_PATH="$(pwd)"
    fi

    echo "Project Path: ${UNITY_PROJECT_PATH}"
    echo "If project path is incorrect make sure to correctly configure the UNITY_PROJECT_FOLDER environment variable"
    export UNITY_PROJECT_PATH
    exit 0;
fi

echo "Test target is a package"
echo "Creating project for testing"
UNITY_PROJECT_PATH="${HOME}/TestProject"
export UNITY_PROJECT_PATH
echo "Project Path: ${UNITY_PROJECT_PATH}"

#Create Project
"${UNITY_APP}/Contents/MacOS/Unity" \
    -batchmode \
    -nographics \
    -quit \
    -logFile - \
    -projectPath "${UNITY_PROJECT_PATH}"  || exit 1

#Modify packages to include our test package
echo "Adding package name to manifest.json"
MANIFEST_FILE="${UNITY_PROJECT_PATH}/Packages/manifest.json"
if [ ! -f "${MANIFEST_FILE}" ]; then
  echo "Packages/manifest.json file not found in created project."
fi

PACKAGE_NAME=$(jq '.name' "${PACKAGE_FILE}")
jq ".dependencies += { \"${PACKAGE_NAME}\" : \"file:$(pwd)\" }" > "${MANIFEST_FILE}" || exit 1