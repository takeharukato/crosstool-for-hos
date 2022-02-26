#
# -*- coding:utf-8 mode: dockerfile-mode -*-
#

# Ubuntu環境を使用
FROM ubuntu
LABEL maintainer="Takeharu KATO"
# tzdataインストール時にタイムゾーンを聞かないようにする
ENV DEBIAN_FRONTEND=noninteractive
# インストール先
ENV PREFIX=/opt/riscv
# QEmuの版数
ENV QEMU_VERSION=qemu-6.2.0
# QEmuのターゲット
ENV QEMU_TARGETS=riscv32-softmmu,riscv64-softmmu,riscv32-linux-user,riscv64-linux-user
# PATHの設定
ENV PATH=${PATH}:${PREFIX}/bin
#
#事前準備
#

# 基本コマンド
RUN apt update; \
    apt install -y language-pack-ja-base language-pack-ja; \
    apt install -y git; \
    apt install -y wget; \
    apt install -y ninja-build;
# コンパイル環境
RUN apt install -y autoconf automake autotools-dev curl python3 libmpc-dev \
    libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
    libtool patchutils bc zlib1g-dev libexpat-dev;
#
#QEMUのインストール
#
# QEMU構築に必要なパッケージのインストール
RUN apt install -y giflib-tools libpng-dev libtiff-dev libgtk-3-dev \
    libncursesw6 libncurses5-dev libncursesw5-dev libgnutls30 nettle-dev \
    libgcrypt20-dev libsdl2-dev libguestfs-tools python3-brlapi \
    bluez-tools bluez-hcidump bluez libusb-dev libcap-dev libcap-ng-dev \
    libiscsi-dev  libnfs-dev libguestfs-dev libcacard-dev liblzo2-dev \
    liblzma-dev libseccomp-dev libssh-dev libssh2-1-dev libglu1-mesa-dev \
    mesa-common-dev freeglut3-dev ngspice-dev libattr1-dev libaio-dev \
    libtasn1-dev google-perftools libvirglrenderer-dev multipath-tools \
    libsasl2-dev libpmem-dev libudev-dev libcapstone-dev librdmacm-dev \
    libibverbs-dev libibumad-dev libvirt-dev libffi-dev libbpfcc-dev \
    libdaxctl-dev ;
# アーカイブ取得
RUN wget -q https://download.qemu.org/${QEMU_VERSION}.tar.xz ;
# アーカイブ展開
RUN tar xf ${QEMU_VERSION}.tar.xz ;
# コンパイル～インストール
RUN mkdir -p ${QEMU_VERSION}/build;     \
    cd ${QEMU_VERSION}/build;           \
    ../configure                        \
    --prefix=${PREFIX}                  \
    --target-list=${QEMU_TARGETS}       \
    --enable-tcg-interpreter            \
    --enable-modules                    \
    --enable-membarrier                 \
    --enable-profiler                   \
    --disable-werror ;                  \
    make -j `nproc` V=1 ;	        \
    make install ;                      \
    cd ../..;                           \
    rm -fr ${QEMU_VERSION};
# アーカイブの削除
RUN rm -f ${QEMU_VERSION}.tar.xz ;

# クロスコンパイラのインストール
# https://github.com/riscv-collab/riscv-gnu-toolchain
# の手順に従って実施

# 64bit版/32bit版をそれぞれ構築
RUN git clone https://github.com/riscv/riscv-gnu-toolchain ; \
    mkdir -p riscv-gnu-toolchain/build64 ;                 \
    mkdir -p riscv-gnu-toolchain/build32 ;                 \
    cd riscv-gnu-toolchain/build64;			   \
    ../configure --prefix=${PREFIX};			   \
    make -j `nproc`;					   \
    make install;                                          \
    cd ../..;                                              \
    cd riscv-gnu-toolchain/build32;			   \
    ../configure                                           \
    --prefix=${PREFIX} 			                   \
    --with-arch=rv32gc                                     \
    --with-abi=ilp32d ;                                    \
    make -j `nproc`;					   \
    make install;                                          \
    cd ../..;                                              \
    rm -fr riscv-gnu-toolchain;

# インストールファイル表示
RUN ls -lR ${PREFIX}
