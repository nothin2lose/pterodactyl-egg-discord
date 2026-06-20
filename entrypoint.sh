#!/bin/bash

MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`

export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

export COREPACK_HOME="/tmp/corepack"
corepack enable

echo "$ cd /home/container"
cd /home/container

if [ "${USER_UPLOADED_FILES}" != "1" ] && [ "${USER_UPLOADED_FILES}" != "true" ] && [ -n "${GIT_ADDRESS}" ]; then
    REPO_URL="${GIT_ADDRESS}"
    case "${REPO_URL}" in
        *.git) ;;
        *) REPO_URL="${REPO_URL}.git" ;;
    esac

    BRANCH="${INSTALL_BRANCH:-main}"

    if [ -n "${GIT_USERNAME}" ] && [ -n "${GIT_ACCESS_TOKEN}" ]; then
        AUTH_URL="https://${GIT_USERNAME}:${GIT_ACCESS_TOKEN}@$(echo "${REPO_URL}" | sed -E 's#https?://##')"
    else
        AUTH_URL="${REPO_URL}"
    fi

    if [ -d .git ]; then
        if [ "${AUTO_UPDATE}" = "1" ] || [ "${AUTO_UPDATE}" = "true" ]; then
            echo "-- Pulling latest changes from ${BRANCH}..."
            git remote set-url origin "${AUTH_URL}" 2>/dev/null || true
            git fetch --all
            git checkout "${BRANCH}" 2>/dev/null || git checkout -b "${BRANCH}" --track "origin/${BRANCH}"
            git pull origin "${BRANCH}" || git pull
        fi
    else
        echo "-- Cloning repository (branch: ${BRANCH})..."
        if ! git clone --single-branch --branch "${BRANCH}" "${AUTH_URL}" .; then
            echo "-- ERROR: git clone failed. Check GIT_ADDRESS, INSTALL_BRANCH, GIT_USERNAME and GIT_ACCESS_TOKEN."
        else
            echo "-- Clone successful."
            ls -la
        fi
    fi
elif [ -z "${GIT_ADDRESS}" ] && [ "${USER_UPLOADED_FILES}" != "1" ] && [ "${USER_UPLOADED_FILES}" != "true" ]; then
    echo "-- WARNING: GIT_ADDRESS is empty. Upload files manually or set Git Repo Address and reinstall."
fi

echo "-- Server started"

${MODIFIED_STARTUP}
