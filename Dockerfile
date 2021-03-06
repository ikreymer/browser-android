#adapted from
#https://github.com/softsam/docker-android-emulator

FROM oldwebtoday/base-browser

# Install all dependencies
RUN apt-get update && \
    apt-get install -qqy software-properties-common && \
    add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y wget openjdk-7-jre-headless libc6-i386 lib32stdc++6 && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install android tools + sdk
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $PATH:${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools

# Set up insecure default key
RUN mkdir -m 0750 /.android
#ADD files/insecure_shared_adbkey /.android/adbkey
#ADD files/insecure_shared_adbkey.pub /.android/adbkey.pub

ARG SDK_BASE=http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz

RUN wget -qO- "$SDK_BASE" | tar -zx -C /opt && \
    echo y | android update sdk --no-ui --all --filter platform-tools --force

# Needed to be able to run VNC - bug of Android SDK
RUN mkdir ${ANDROID_HOME}/tools/keymaps && touch ${ANDROID_HOME}/tools/keymaps/en-us

ARG SDK_STRING="SDK Platform Android 5.1.1, API 22"
ARG SDK_VERS=22

# Install dependencies for emulator
RUN echo y | android update sdk --no-ui --all -t `android list sdk --all|grep "$SDK_STRING" |awk -F'[^0-9]*' '{print $2}'` && \
    echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-$SDK_VERS --force && \
    echo y | android update sdk --no-ui --all --filter sys-img-x86-android-$SDK_VERS --force

RUN echo n | android create avd --force -n "x86" -t android-$SDK_VERS --abi default/x86
RUN echo n | android create avd --force -n "arm" -t android-$SDK_VERS --abi default/armeabi-v7a

# Add entrypoint
ADD run.sh /app/run.sh
ADD addcert.sh /app/addcert.sh
RUN chmod +x /app/run.sh

CMD /app/entry_point.sh /app/run.sh


LABEL wr.name="Android" \
      wr.version="API $SDK_VERS" \
      wr.os="android" \
      wr.release="2016-09-14" \
      wr.icon="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABCUlEQVR4nMWQoU4DYRCEvznopSAQRdQhEGgUFs5cQlA8AQLZUMUb1CEpFslTHJCrgIcgkJCQlCAIqg0Q7gYDSa/8F+o6cnZ2dmdg3lDdoD9INzAPYEVivbOd3YV0UXA5T1uCHjACjUt00s/T9swG4PPSXgUbaFC6Ab74N8JZnrbBhdExsFSxhBKpt+Ci2dm5HP7yi1WR+4axYB9Y+XPJ5XKB1oDdoAEoFnyFY4FRDMSTXE0Hs6PygfDA6B3YC4mFb4zuq1wAp3n6KmhNcoYCu9lNskrEqQ5+XO1NpCvsa+AN6RB7a3oZajo4SrInzAj0AgxtPrpJ9hjSBj8AUOQDm2fEJyW3dbr54xuZP12+ugYsYQAAAABJRU5ErkJggg=="


