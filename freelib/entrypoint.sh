#!/bin/bash

if [ -z "${FREELIB_INPX_FILE}" ]; then
  echo "Please specify path to .inpx file in FREELIB_INPX_FILE environment variable"
  exit 1
fi

if [ ! -e "${FREELIB_INPX_FILE}" ]; then
  echo "File ${FREELIB_INPX_FILE} not found"
  exit 1
fi

if [ -z "${FREELIB_LIBRARY_DIR}" ]; then
  echo "Please specify path to the library in FREELIB_LIBRARY_DIR environment variable"
  exit 1
fi

if [ ! -d "${FREELIB_LIBRARY_DIR}" ]; then
  echo "Directory ${FREELIB_LIBRARY_DIR} not found"
  exit 1
fi

if [ ! -e "${FREELIB_DATABASE_PATH}" ]; then
  echo "Please specify path to the sqlite3 file in FREELIB_DATABASE_PATH environment variable"
  exit 1
fi

LIBRARY_NAME="${FREELIB_LIBRARY_NAME:-home_library}"

echo "Ensure database directory exists"
mkdir -p -v "$(dirname ${FREELIB_DATABASE_PATH})"
touch "${FREELIB_DATABASE_PATH}"

/opt/bin/freelib --set-db "${FREELIB_DATABASE_PATH}"

echo "Ensure library is created"
if [ -s "${FREELIB_DATABASE_PATH}" ]; then
  _lib="$(sqlite3 "${FREELIB_DATABASE_PATH}" "select * from lib where name = \"${LIBRARY_NAME}\";")"
else
  _lib=""
fi
if [ -z "${_lib}" ]; then 
  echo "Library ${LIBRARY_NAME} not found, create"
  /opt/bin/freelib --lib-ad -name "${LIBRARY_NAME}" -inpx "${FREELIB_INPX_FILE}" -path "${FREELIB_LIBRARY_DIR}"
else
  _id=$(echo "${_lib}" | awk -F"|" '{print $1}')
  _path=$(echo "${_lib}" | awk -F"|" '{print $3}')
  _inpx=$(echo "${_lib}" | awk -F"|" '{print $4}')
  if [ "${_path}" != "${FREELIB_LIBRARY_DIR}" ] || [ "${_inpx}" != "${FREELIB_INPX_FILE}" ]; then
    echo "Library paths changed, update"
    /opt/bin/freelib --lib-sp -id "${_id}" -inpx "${FREELIB_INPX_FILE}" -path "${FREELIB_LIBRARY_DIR}"
  fi
fi

echo "Update library"
/opt/bin/freelib --lib-up "${_id:-1}"

echo "Start server"
/opt/bin/freelib -s