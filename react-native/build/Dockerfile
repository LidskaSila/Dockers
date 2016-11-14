FROM ubuntu:16.04

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# First, install add-apt-repository and bzip2
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -y install \
software-properties-common python-software-properties \
bzip2 unzip openssh-client git curl \
lib32stdc++6 lib32z1 \
expect build-essential

# Install npm
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get -y install \
nodejs


# Add oracle-jdk7 to repositories
RUN add-apt-repository ppa:webupd8team/java

# Update apt
RUN apt-get update

# Install oracle-jdk7
RUN apt-get -y install oracle-java7-installer

#ENV ANDROID_SDK_URL http://dl.google.com/android/android-sdk_r24.0.2-linux.tgz
#RUN curl -L ${ANDROID_SDK_URL} | tar xz -C /opt

RUN curl -L https://github.com/journeyapps/android-sdk-installer/raw/master/android-sdk-installer | bash /dev/stdin --install="tools,platform-tools,build-tools-23.0.1,android-23,sys-img-armeabi-v7a-android-23,extra-android-support,extra-android-m2repository,extra-google-m2repository" --dir="/opt" --accept="android-sdk-license-c81a61d9|android-sdk-preview-license-c81a61d9"

# Install Android NDK
RUN wget https://dl.google.com/android/ndk/android-ndk-r9d-linux-x86_64.tar.bz2
RUN tar -xvjf android-ndk-r9d-linux-x86_64.tar.bz2 -C /opt
RUN rm android-ndk-r9d-linux-x86_64.tar.bz2

## Install Gradle
#RUN wget https://services.gradle.org/distributions/gradle-2.4-all.zip
#RUN unzip gradle-2.4-all.zip
#RUN mv gradle-2.4 /opt/
#RUN rm gradle-2.4-all.zip

# Environment variables
ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_NDK_HOME /opt/android-ndk-r9d
ENV ANDROID_HOME $ANDROID_SDK_HOME
#ENV GRADLE_HOME /opt/gradle-2.4
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools
ENV PATH $PATH:$ANDROID_NDK_HOME
#ENV PATH $PATH:$GRADLE_HOME/bin

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# Clean up
RUN apt-get clean

# Create Gradle folder
RUN mkdir /root/.gradle