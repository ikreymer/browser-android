#!/bin/bash

#filename=`openssl x509 -in $1  -hash -noout`
#> $filename".0"
filename=$(openssl x509 -inform PEM -subject_hash_old -in $1 | head -n 1)
cat $1 > $filename.0

# blob data, text and fingerprint information
openssl x509 -inform PEM -text -in $1 -noout >> $filename.0
openssl x509 -in $1  -text -fingerprint -noout >> $filename.0

until adb shell mount -o remount,rw /system
do
  sleep 0.5
  echo "retry cert push"
done

adb push $filename.0 /system/etc/security/cacerts
adb shell chmod 644 /system/etc/security/cacerts/$filename.0

