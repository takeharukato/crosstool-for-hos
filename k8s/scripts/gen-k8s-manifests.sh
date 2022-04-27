#!/bin/bash
#
# -*- coding:utf-8 mode: bash-mode -*-
#
# Hyper Operating System用クロス開発環境構築スクリプト (Kubernetesマニフェストファイル)
#
# Copyright (C) 1998-2022 by Project HOS
# http://sourceforge.jp/projects/hos/
#

## -- 動作設定関連変数の開始 --

# コンパイル対象CPU
if [ "x${TARGET_CPUS}" = "x" ]; then
    TARGET_CPUS="sh2 h8300 i386 riscv32 riscv64 mips mipsel microblaze microblazeel arm armhw"
    echo "No target cpus specified, build all: ${TARGET_CPUS}"
else
    echo "Target CPUS: ${TARGET_CPUS}"
fi

#
#アーカイブ展開時のディレクトリ名
#
declare -A tool_names=(
    ["binutils"]="binutils-2.38"
    ["gcc"]="gcc-11.2.0"
    ["newlib"]="newlib-4.1.0"
    ["gdb"]="gdb-11.2"
    ["qemu"]="qemu-6.2.0"
    ["i386-qemu"]="qemu-6.1.0"
    ["h8300-binutils"]="binutils-2.24"
    ["h8300-gcc"]="gcc-8.4.0"
    ["h8300-newlib"]="newlib-2.5.0"
    ["sh2-newlib"]="newlib-2.5.0"
    )
#
#アーカイブファイル名
#
declare -A tool_archives=(
    ["binutils-2.38"]="binutils-2.38.tar.gz"
    ["gcc-11.2.0"]="gcc-11.2.0.tar.gz"
    ["newlib-4.1.0"]="newlib-4.1.0.tar.gz"
    ["gdb-11.2"]="gdb-11.2.tar.gz"
    ["qemu-6.1.0"]="qemu-6.1.0.tar.xz"
    ["qemu-6.2.0"]="qemu-6.2.0.tar.xz"
    ["binutils-2.24"]="binutils-2.24.tar.gz"
    ["gcc-8.4.0"]="gcc-8.4.0.tar.gz"
    ["newlib-2.5.0"]="newlib-2.5.0.tar.gz"
    ["gdb-7.12"]="gdb-7.12.tar.gz"
    )

#
#URL
#
declare -A tool_urls=(
    ["binutils-2.38"]="https://ftp.gnu.org/gnu/binutils/binutils-2.38.tar.gz"
    ["gcc-11.2.0"]="https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz"
    ["newlib-4.1.0"]="https://sourceware.org/pub/newlib/newlib-4.1.0.tar.gz"
    ["gdb-11.2"]="https://ftp.gnu.org/gnu/gdb/gdb-11.2.tar.gz"
    ["qemu-6.1.0"]="https://download.qemu.org/qemu-6.1.0.tar.xz"
    ["qemu-6.2.0"]="https://download.qemu.org/qemu-6.2.0.tar.xz"
    ["binutils-2.24"]="https://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz"
    ["gcc-8.4.0"]="https://ftp.gnu.org/gnu/gcc/gcc-8.4.0/gcc-8.4.0.tar.gz"
    ["newlib-2.5.0"]="https://sourceware.org/pub/newlib/newlib-2.5.0.tar.gz"
    ["gdb-7.12"]="https://ftp.gnu.org/gnu/gdb/gdb-7.12.tar.gz"
    )

#
# QEmuのターゲット
#
declare -A qemu_targets=(
    ["i386"]="i386-softmmu,i386-linux-user"
    ["riscv32"]="riscv32-softmmu,riscv32-linux-user"
    ["riscv64"]="riscv64-softmmu,riscv64-linux-user"
    ["mips"]="mips-softmmu,mips-linux-user"
    ["mipsel"]="mipsel-softmmu,mipsel-linux-user"
    ["arm"]="arm-softmmu,arm-linux-user"
    ["armhw"]="arm-softmmu,arm-linux-user"
    ["microblaze"]="microblaze-softmmu,microblaze-linux-user"
    ["microblazeel"]="microblazeel-softmmu,microblazeel-linux-user"
    )

#
# QEmuのCPU名
#
declare -A qemu_cpus=(
    ["i386"]="i386"
    ["riscv32"]="riscv32"
    ["riscv64"]="riscv64"
    ["mips"]="mips"
    ["mipsel"]="mipsel"
    ["arm"]="arm"
    ["armhw"]="arm"
    ["microblaze"]="microblaze"
    ["microblazeel"]="microblazeel"
    )

#
# QEmuの起動オプション
#
declare -A qemu_opts=(
    ["i386"]="-boot a -drive file=sampledbg.img,format=raw,if=floppy,media=disk,readonly=off,index=0 -serial mon:stdio -nographic"
    ["riscv32"]="-bios none -machine virt -m 32M -serial mon:stdio -nographic -kernel sampledbg.elf"
    ["riscv64"]="-bios none -machine virt -m 32M -serial mon:stdio -nographic -kernel sampledbg.elf"
    )

#
# ターゲット名
#
declare -A cpu_target_names=(
    ["arm-elf"]="arm-none-eabi"
    ["armhw-elf"]="arm-eabihf"
    ["h8300-elf"]="h8300-elf"
    ["sh2-elf"]="sh-elf"
    )

#
# ターゲット用cflags
#
declare -A cpu_target_cflags=(
    ["h8300-elf"]="-mh"
    )

#
#ターゲットボードリスト
#
board_list=( \
	     "mips:jelly:sample/mips/jelly/gcc:sampledbg.elf" \
		 "i386:pcat:sample/ia32/pcat/gcc:sampledbg.out" \
		 "microblazeel:mb_v8_axi:sample/mb/mb_v8_axi/gcc:sampledbg.elf" \
		 "microblaze:smm:sample/mb/smm/gcc:sampledbg.elf" \
		 "sh2:sh7262:sample/sh/sh7262/gcc:sampledbg.out" \
		 "sh2:sh7144:sample/sh/sh7144/gcc:sampledbg.out" \
		 "h8300:h83069:sample/h8/h83069/gcc:sampledbg.out" \
		 "riscv64:virt:sample/riscv/virt/gcc:sampledbg.elf" \
		 "riscv32:virt:sample/riscv/virt/gcc:sampledbg.elf" \
		 "arm:zynqmp_rpu_cpp:sample/arm/zynqmp_rpu_cpp/gcc:sampledbg.elf" \
		 "arm:stm32f103:sample/arm/stm32f103/gcc:sampledbg.elf" \
		 "arm:zynq7000:sample/arm/zynq7000/gcc:sampledbg.elf" \
		 "arm:zynqmp_rpu:sample/arm/zynqmp_rpu/gcc:sampledbg.elf" \
		 "arm:lpc1114:sample/arm/lpc1114/gcc:sampledbg.elf" \
		 "arm:aduc7000:sample/arm/aduc7000/gcc:sampledbg.out" \
		 "arm:lpc2000:sample/arm/lpc2000/gcc:sampledbg.out" \
		 "armhw:zynqmp_rpu_cpp:sample/arm/zynqmp_rpu_cpp/gcc:sampledbg.elf" \
		 "armhw:stm32f103:sample/arm/stm32f103/gcc:sampledbg.elf" \
		 "armhw:zynq7000:sample/arm/zynq7000/gcc:sampledbg.elf" \
		 "armhw:zynqmp_rpu:sample/arm/zynqmp_rpu/gcc:sampledbg.elf" \
		 "armhw:lpc1114:sample/arm/lpc1114/gcc:sampledbg.elf" \
		 "armhw:aduc7000:sample/arm/aduc7000/gcc:sampledbg.out" \
		 "armhw:lpc2000:sample/arm/lpc2000/gcc:sampledbg.out" \
	   )


#
# イメージファイル中のCPU名
#
declare -A container_image_cpus=(
    ["sh2"]="sh2"
    ["h8300"]="h8300"
    ["i386"]="i386"
    ["riscv32"]="riscv"
    ["riscv64"]="riscv"
    ["mips"]="mips"
    ["mipsel"]="mips"
    ["microblaze"]="microblaze"
    ["microblazeel"]="microblaze"
    ["arm"]="arm"
    ["armhw"]="arm"
    )
#
# HOSソースコード展開名
#
MKCROSS_HOS_SRCDIR="hos-v4a"

#
# リモートGDB接続先ポート
#
MKCROSS_REMOTE_GDB_PORT=1234

#
# イメージファイルGitHubオーナ名
#
MKCROSS_GITHUB_REPO_OWNER="takeharukato"

## -- 動作設定関連変数のおわり --

#
#スクリプト配置先ディレクトリ
#
MKCROSS_SCRIPTS_DIR=$(cd $(dirname $0);pwd)
#
# TOPディレクトリ
#
MKCROSS_TOP_DIR="${MKCROSS_SCRIPTS_DIR}/../.."

#
#インストール先
#
CROSS_PREFIX="/opt/hos/cross"
# lmodのモジュールファイル
LMOD_MODULE_DIR="${CROSS_PREFIX}/lmod/modules"
# シェルの初期化ファイル
SHELL_INIT_DIR="${CROSS_PREFIX}/etc/shell/init"
# Hos開発ユーザ名
DEVLOPER_NAME="hos"
# Hos開発者ユーザID
DEVLOPER_UID=2000
# Hos開発者グループID
DEVLOPER_GID=2000
# Hos開発者シェル
DEVLOPER_SHELL="/bin/bash"
# Hos開発者ホームディレクトリ
DEVLOPER_HOME="/home/${DEVLOPER_NAME}"

# コンパイル対象CPUの配列
targets=(`echo ${TARGET_CPUS}`)

# コンパイル作業のトップディレクトリ
TOP_DIR=`pwd`
# k8s 関連ファイル
MKCROSS_K8S_DIR="${MKCROSS_TOP_DIR}/k8s"
# k8s マニュフェストファイル
K8S_MANIFESTS_DIR="${MKCROSS_K8S_DIR}/manifests"
# ダウンロードアーカイブ格納ディレクトリ
DOWNLOADS_DIR=${TOP_DIR}/downloads

# ターゲット用の最適化フラグ
MKCROSS_OPT_FLAGS_FOR_TARGET="-g -O2 -finline-functions"
#
#ツール名を取得する
# get_tool_name CPU名 ツール種別
#
get_tool_name(){
    local cpu
    local tool
    local tool_key
    local archive_key
    local rc

    cpu=$1
    tool=$2

    rc="None"

    if [ "x${tool_names[${tool}]}" != "x" ]; then
	rc="${tool_names[${tool}]}"
    fi

    #
    # CPU固有
    #
    tool_key="${cpu}-${tool}"

    if [ "x${tool_names[${tool_key}]}" != "x" ]; then
	    rc="${tool_names[${tool_key}]}"
    fi

    echo "${rc}"
}

#
#アーカイブ名を取得する
# get_archive_name CPU名 ツール種別
#
get_archive_name(){
    local cpu
    local tool
    local tool_key
    local archive_key
    local archive
    local rc

    cpu=$1
    tool=$2

    rc="None"

    if [ "x${tool_names[${tool}]}" != "x" ]; then
	archive_key="${tool_names[${tool}]}"
	archive="${tool_archives[${archive_key}]}"
	    if [ "x${archive}" != "x" ]; then
	        rc="${archive}"
    	fi
    fi

    #
    # CPU固有
    #
    tool_key="${cpu}-${tool}"

    if [ "x${tool_names[${tool_key}]}" != "x" ]; then
	    archive_key="${tool_names[${tool_key}]}"
	    archive="${tool_archives[${archive_key}]}"
    	if [ "x${archive}" != "x" ]; then
	        rc="${archive}"
    	fi
    fi

    echo "${rc}"
}

download_archives(){
    local tool
    local cpu
    local tool_key
    local archive_key
    local url

    mkdir -p ${DOWNLOADS_DIR}

    pushd ${DOWNLOADS_DIR}

    for tool in "binutils" "gcc" "newlib" "gdb" "qemu"
    do
	#
	# 共通アーカイブのダウンロード
	#
	    if [ "x${tool_names[${tool}]}" != "x" ]; then
	       archive_key="${tool_names[${tool}]}"
	       url="${tool_urls[${archive_key}]}"
	       if [ "x${url}" != "x" ]; then
	    	    echo "download ${tool} from ${url}"
	        	curl -s -OL "${url}"
	        fi
	    fi

	#
	# CPU固有のアーカイブをダウンロード
	#
    	for cpu in "${targets[@]}"
    	do
    	    tool_key="${cpu}-${tool}"
    	    if [ "x${tool_names[${tool_key}]}" != "x" ]; then
    		    archive_key="${tool_names[${tool_key}]}"
	    	    url="${tool_urls[${archive_key}]}"
	    	    if [ "x${url}" != "x" ]; then
	    	        echo "${cpu} uses ${tool} from ${url}"
	    	        curl -s -OL "${url}"
	    	    fi
	        fi
	    done
    done

    popd
}



#
# generate_k8s_manifest_file ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ ツールチェイン種別
#
generate_k8s_manifest_file(){
    local cpu="$1"
    local target="$2"
    local prefix="$3"
    local target_var
    local image_cpu
    local this_image_name

    target_var=`echo ${target}|sed -e 's|-|_|g'`

    qemu_cpu="${qemu_cpus[${cpu}]}"
    qemu_opt="${qemu_opts[${cpu}]}"

    image_cpu="${cpu}"
    if [ "x${container_image_cpus[${cpu}]}" != "x" ]; then
	image_cpu="${container_image_cpus[${cpu}]}"
    fi
    this_image_name="ghcr.io/${MKCROSS_GITHUB_REPO_OWNER}/crosstool-for-hos-${image_cpu}:latest"

    echo "@@@ Kubernetes Manifest Settings @@@"
    echo "target:${target}"
    echo "Sysroot:${sys_root}"
    echo "BuildDir:${build_dir}"
    echo "SourceDir:${src_dir}"
    echo "ImageName:${this_image_name}"
    if [ "x${qemu_cpu}" != "x" ]; then
	    echo "QEmuCPUName:${qemu_cpu}"
    fi

    if [ "x${qemu_opt}" != "x" ]; then
	    echo "QEmuCPUName:${qemu_opt}"
    fi
    cat <<EOF|sed -e "s|__CPU_NAME__|${image_cpu}|g" \
		  -e "s|__DEVLOPER_UID__|${DEVLOPER_UID}|g" \
		  -e "s|__DEVLOPER_GID__|${DEVLOPER_GID}|g" \
		  -e "s|__CONTAINER_IMAGE__|${this_image_name}|g" \
		  -e "s|__DEVLOPER_HOME__|${DEVLOPER_HOME}|g"  \
		  > ${K8S_MANIFESTS_DIR}/hos-${image_cpu}.yaml
apiVersion: v1
kind: Pod
metadata:
  name: hos-__CPU_NAME__
spec:
  securityContext:
    runAsUser: __DEVLOPER_UID__
    runAsGroup: __DEVLOPER_GID__
    fsGroup: __DEVLOPER_GID__
  volumes:
  - name: source-storage
    emptyDir: {}
  containers:
  - name: hos-__CPU_NAME__
    image: __CONTAINER_IMAGE__
    imagePullPolicy: Always
    volumeMounts:
    - name: source-storage
      mountPath: __DEVLOPER_HOME__/src
    stdin: true
    tty: true
    env:
    ports:
    workingDir: __DEVLOPER_HOME__
EOF



}

main(){
    local cpu
    local prefix
    local build_dir
    local src_dir
    local orig_path
    local target_name
    local toolchain_type

    #
    # 事前準備
    #
    orig_path="${PATH}"


    # 各CPU向けの設定を生成
    for cpu in "${targets[@]}"
    do

	toolchain_type="elf"

    	build_dir="${TOP_DIR}/${cpu}/build"
    	src_dir="${TOP_DIR}/${cpu}/src"
    	prefix="${CROSS_PREFIX}/${cpu}"

    	target_name="${cpu}-unknown-${toolchain_type}"
    	if [ "x${cpu_target_names[${cpu}-${toolchain_type}]}" != "x" ]; then
	        target_name="${cpu_target_names[${cpu}-${toolchain_type}]}"
	    fi

	    echo "@@@ ${cpu} @@@"
	    echo "Target:${target_name}"
	    echo "Prefix:${prefix}"
	    echo "BuildDir:${build_dir}"
	    echo "SourceDir:${src_dir}"

	    generate_k8s_manifest_file \
	        "${cpu}" "${target_name}" "${prefix}" "${src_dir}" "${build_dir}" "${toolchain_type}"


	#
	# 一時ディレクトリを削除
	#
	    if [ -f "${build_dir}" ]; then
	        rm -fr "${build_dir}"
	    fi

	    if [ -f "${src_dir}" ]; then
	        rm -fr "${src_dir}"
	    fi

    done


    echo "Complete"
}

main $@
