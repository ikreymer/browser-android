#!/bin/bash

filename=`openssl x509 -in $1  -hash -noout`
> $filename".0"

# blob data, text and fingerprint information
openssl x509 -in $1 >> $filename.0
openssl x509 -in $1  -text -fingerprint -noout >> $filename.0

adb shell mount -o remount,rw /system
adb push $filename.0 /system/etc/security/cacerts
