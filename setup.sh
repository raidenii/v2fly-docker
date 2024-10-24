#!/bin/sh

# Set ARG
PLATFORM=$1
TAG=$2
if [ -z "$PLATFORM" ]; then
    ARCH="64"
else
    case "$PLATFORM" in
        linux/amd64)
            ARCH="64"
            ;;
        linux/arm64)
            ARCH="arm64-v8a"
            ;;
        *)
            ARCH=""
            ;;
    esac
fi
[ -z "${ARCH}" ] && echo "Error: Unsupported arch, aborting!" && exit 1

if [ -z "${TAG}" ]; then
    BASE_URL="https://github.com/v2fly/v2ray-core/releases/latest/download"
else
    BASE_URL="https://github.com/v2fly/v2ray-core/releases/download/${TAG}"
fi

# Download files
V2RAY_FILE="v2ray-linux-${ARCH}.zip"
DGST_FILE="v2ray-linux-${ARCH}.zip.dgst"
echo "Downloading zip file: ${V2RAY_FILE}"
echo "Downloading zip digest file: ${DGST_FILE}"

wget -O ${PWD}/v2ray.zip ${BASE_URL}/${V2RAY_FILE} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to download v2ray zip for ${ARCH} at ${BASE_URL}/${V2RAY_FILE}, aborting!" && exit 1
fi

wget -O ${PWD}/v2ray.zip.dgst ${BASE_URL}/${DGST_FILE} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to download file digest for ${ARCH} at ${BASE_URL}/${DGST_FILE}, aborting!" && exit 1
fi

echo "Download binary file: ${V2RAY_FILE} ${DGST_FILE} completed"

# Check SHA512
V2RAY_ZIP_HASH=$(sha512sum v2ray.zip | cut -f1 -d' ')
V2RAY_ZIP_DGST_HASH=$(cat v2ray.zip.dgst | grep -e 'SHA512' -e 'SHA2-512' | head -n1 | cut -f2 -d' ')

if [ "${V2RAY_ZIP_HASH}" = "${V2RAY_ZIP_DGST_HASH}" ]; then
    rm -fv v2ray.zip.dgst
else
    echo "Calculated sha512 hash: ${V2RAY_ZIP_HASH}"
    echo "sha512 hash from digest file: ${V2RAY_ZIP_DGST_HASH}"
    echo "Checksums mismatch, aborting!" && exit 1
fi

# Deploy
echo "Deploying v2ray..."
unzip v2ray.zip
chmod +x v2ray start.sh
mv v2ray /usr/bin/
mv start.sh /usr/local/bin
mv *.dat /etc/v2ray

# Clean
echo "Deployment is finished, cleaning up..."
rm -rf ${PWD}/*
echo "Finished building Docker image."
