#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
rm -drf docs
jazzy   --github_url https://github.com/RiftValleySoftware/RVS_ONVIF\
        --readme ./README.md --theme fullwidth\
        --author The\ Great\ Rift\ Valley\ Software\ Company\
        --author_url https://riftvalleysoftware.com\
        --module RVS_ONVIF_iOS\
        --min-acl public\
        --exclude */RVS_ONVIF_Core_IANATypes.swift\
        --copyright [©2019\ The\ Great\ Rift\ Valley\ Software\ Company]\(https://riftvalleysoftware.com\)
cp icon.png docs/icon.png
cp img/*.* docs/img/
cd "${CWD}"