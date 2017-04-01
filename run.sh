android_arch=$ANDROID_ARCH
if [ -z "$android_arch" ]
then
    android_arch="arm"
fi

PATH=$PATH:${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools

echo "hw.keyboard = yes" >> ~/.android/avd/${android_arch}.avd/config.ini

#export LD_LIBRARY_PATH="/opt/android-sdk-linux/tools/lib64/:$LD_LIBRARY_PATH"

# Set up and run emulator
run_browser emulator64-${android_arch} -avd ${android_arch} -noaudio -gpu off -verbose -qemu &

PID=$!

sleep 10

if [[ -n "$PROXY_GET_CA" ]]; then
    curl -x "$PROXY_HOST:$PROXY_PORT"  "$PROXY_GET_CA" > /tmp/proxy-ca.pem
    bash /app/addcert.sh /tmp/proxy-ca.pem
fi

wait $PID


