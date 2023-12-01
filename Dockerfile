# FROM ubuntu:22.04
FROM ubuntu:18.04

RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends software-properties-common gpg-agent
RUN add-apt-repository -y ppa:gnuradio/gnuradio-releases
RUN add-apt-repository -y ppa:git-core/ppa
RUN apt-get install -y --no-install-recommends \
    git \
    build-essential \
    autoconf \
    automake \
    cmake \
    libtool \
    wget \
    qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
    qt5-gtk-platformtheme \
    qttranslations5-l10n \
    libqt5svg5-dev \
    libboost-dev \
    libpulse-dev \
    portaudio19-dev \
    liblog4cpp5-dev \
    gnuradio-dev \
    libairspy-dev \
    libairspyhf-dev \
    libfreesrp-dev \
    libhackrf-dev \
    libusb-1.0-0-dev \
    libsoapysdr-dev \
    soapysdr-module-remote \
    libuhd-dev \
    liborc-0.4-dev \
    libhidapi-dev \
    libfuse2

# libgnuradio-osmosdr0.2.0 gnuradio gr-osmosdr
# qt5-default unavailable using 'qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools' instead

WORKDIR /tmp
RUN git clone https://gitea.osmocom.org/sdr/rtl-sdr.git
RUN mkdir rtl-sdr/build

WORKDIR /tmp/rtl-sdr/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr -DDETACH_KERNEL_DRIVER=ON ..
RUN make -j4
RUN make install
RUN ldconfig

WORKDIR /tmp
RUN git clone https://gitea.osmocom.org/sdr/gr-osmosdr.git && cd gr-osmosdr && git checkout origin/gr3.8 && git cherry-pick -n 9c09c90d920dd4906fa8bb9d8443eef84d2565a3
RUN mkdir gr-osmosdr/build

WORKDIR /tmp/gr-osmosdr/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_MODULES_DIR=/usr/lib/x86_64-linux-gnu/cmake -DENABLE_PYTHON=False ..
RUN make -j4
RUN make install
RUN ldconfig

WORKDIR /tmp/gqrx
COPY cmake cmake
COPY resources resources
COPY new_logo new_logo
COPY src src
COPY dk.* .
COPY CMakeLists.txt .
RUN ls -alh
RUN mkdir build && cd build && cmake .. && make -j2

# Necessary to avoid qt4 qmake error when building AppImage
RUN apt-get install -y qt5-default

COPY appimage.sh .

RUN ls -alh /tmp/gqrx/build
RUN echo git > /tmp/gqrx/build/version.txt

# eof
