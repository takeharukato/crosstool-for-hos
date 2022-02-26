#
# -*- coding:utf-8 mode: dockerfile-mode -*-
#

# Ubuntu環境を使用
FROM ubuntu
LABEL maintainer="Takeharu KATO"
# tzdataインストール時にタイムゾーンを聞かないようにする
ENV DEBIAN_FRONTEND=noninteractive
#
#事前準備
#
# 基本コマンド
RUN apt update; \
    apt install -y language-pack-ja-base language-pack-ja \
    git ninja-build python3 python3-dev swig \
    autoconf automake autotools-dev curl python3 libmpc-dev \
    libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
    libtool patchutils bc zlib1g-dev libexpat-dev \
    giflib-tools libpng-dev libtiff-dev libgtk-3-dev \
    libncursesw6 libncurses5-dev libncursesw5-dev libgnutls30 nettle-dev \
    libgcrypt20-dev libsdl2-dev libguestfs-tools python3-brlapi \
    bluez-tools bluez-hcidump bluez libusb-dev libcap-dev libcap-ng-dev \
    libiscsi-dev  libnfs-dev libguestfs-dev libcacard-dev liblzo2-dev \
    liblzma-dev libseccomp-dev libssh-dev libssh2-1-dev libglu1-mesa-dev \
    mesa-common-dev freeglut3-dev ngspice-dev libattr1-dev libaio-dev \
    libtasn1-dev google-perftools libvirglrenderer-dev multipath-tools \
    libsasl2-dev libpmem-dev libudev-dev libcapstone-dev librdmacm-dev \
    libibverbs-dev libibumad-dev libvirt-dev libffi-dev libbpfcc-dev \
    libdaxctl-dev \
    lmod ; \
    mkdir -p /home/cross/mkcross/workdir ;

# クロスコンパイラ作成スクリプトをコピー
COPY scripts/mkcross-elf.sh /home/cross/mkcross
# コンパイル環境生成
RUN  cd /home/cross/mkcross/workdir ; \
    ../mkcross-elf.sh;                \
    rm -fr /home/cross
