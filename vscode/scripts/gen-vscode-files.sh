#!/bin/bash
#
# -*- coding:utf-8 mode: bash-mode -*-
#
# Hyper Operating System用クロス開発環境構築スクリプト
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
# HOSソースコード展開名
#
MKCROSS_HOS_SRCDIR="hos-v4a"

#
# リモートGDB接続先ポート
#
MKCROSS_REMOTE_GDB_PORT=1234
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
#vscodeのテンプレート
#
MKCROSS_VSCODE_TEMPL_DIR="${MKCROSS_TOP_DIR}/docker/vscode"

#
#vscodeの設定ファイル出力先
#
MKCROSS_VSCODE_OUTPUT_DIR="${MKCROSS_TOP_DIR}/vscode/settings"

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
# Hos開発ディレクトリ
DEVLOPER_HOME="/home/${DEVLOPER_NAME}"

# コンパイル対象CPUの配列
targets=(`echo ${TARGET_CPUS}`)

# コンパイル作業のトップディレクトリ
TOP_DIR=`pwd`

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
# generate_vscode_file_one 入力ファイル 出力ファイル ターゲットCPU ターゲット名 プレフィクス QEMUのCPU名 QEMUのオプション ユーザプログラムディレクトリ ユーザプログラムファイル
#
generate_vscode_file_one(){
    local infile="$1"
    local outfile="$2"
    local cpu="$3"
    local target="$4"
    local prefix="$5"
    local qemu_cpu="$6"
    local qemu_opt="$7"
    local prog_dir="$8"
    local prog_file="$9"
    local qemu_cmd

    echo "@@@ Generate: ${outfile} @@@"

    if [ "x${qemu_cpu}" != "x" ]; then
	    qemu_cmd="qemu-system-${qemu_cpu}"
    fi

    rm -f "${outfile}"
    cat "${infile}" |\
	sed -e "s|__CPU__|${cpu}|g" \
	    -e "s|__PREFIX__|${prefix}|g" \
	    -e "s|__GCC_ARCH__|${target}-|g" \
	    -e "s|__REMOTE_GDB_PORT__|${MKCROSS_REMOTE_GDB_PORT}|g" \
	    -e "s|__QEMU__|${qemu_cmd}|g" \
	    -e "s|__QEMU_OPTS__|${qemu_opt}|g" \
	    -e "s|__HOS_REMOTE_USER__|${DEVLOPER_NAME}|g" \
	    -e "s|__CONTAINER_IMAGE__|${THIS_IMAGE_NAME}|g" \
        -e "s|__HOS_HOME_DIR__|${DEVLOPER_HOME}|g" \
	    -e "s|__HOS_USER_PROGRAM_DIR__|${prog_dir}|g" \
	    -e "s|__HOS_USER_PROGRAM_FILE__|${prog_file}|g" \
	> "${outfile}"
}

#
# generate_vscode_file_for_board 出力先ディレクトリ ターゲットCPU ターゲット名 プレフィクス QEMUのCPU名 QEMUのオプション ユーザプログラムディレクトリ ユーザプログラムファイル
#
generate_vscode_file_for_board(){
    local outdir="$1"
    local cpu="$2"
    local target="$3"
    local prefix="$4"
    local qemu_cpu="$5"
    local qemu_opt="$6"
    local prog_dir="$7"
    local prog_file="$8"

    # vscodeのワークスペース定義ディレクトリ
    vscode_workspace_dir="${MKCROSS_VSCODE_OUTPUT_DIR}/${cpu}/${outdir}"
    # vscodeの.devcontainerディレクトリ
    vscode_devcontainer_dir="${vscode_workspace_dir}/.devcontainer"
    # vscodeの.vscodeディレクトリ
    vscode_vscode_dir="${vscode_workspace_dir}/.vscode"

    # vscodeのワークスペース定義ディレクトリを作成
    mkdir -p "${vscode_workspace_dir}"
    # vscodeの.devcontainerディレクトリを作成
    mkdir -p "${vscode_devcontainer_dir}"
    # vscodeの.vscodeディレクトリを作成
    mkdir -p "${vscode_vscode_dir}"

    #
    # 共通ファイル
    #
    generate_vscode_file_one \
	"${MKCROSS_VSCODE_TEMPL_DIR}/sample.code-workspace" \
	"${vscode_workspace_dir}/hos-${cpu}.code-workspace" \
	"${cpu}" \
	"${target}" \
	"${prefix}" \
	"${qemu_cpu}" \
	"${qemu_opt}" \
	"${prog_dir}" \
	"${prog_file}"

    #
    #.vscode/c_cpp_properties.json
    #
    generate_vscode_file_one \
	"${MKCROSS_VSCODE_TEMPL_DIR}/_vscode/c_cpp_properties.json" \
	"${vscode_vscode_dir}/c_cpp_properties.json" \
	"${cpu}" \
	"${target}" \
	"${prefix}" \
	"${qemu_cpu}" \
	"${qemu_opt}" \
	"${prog_dir}" \
	"${prog_file}"

    #
    #.vscode/launch.json
    #
    generate_vscode_file_one \
	"${MKCROSS_VSCODE_TEMPL_DIR}/_vscode/launch.json" \
	"${vscode_vscode_dir}/launch.json" \
	"${cpu}" \
	"${target}" \
	"${prefix}" \
	"${qemu_cpu}" \
	"${qemu_opt}" \
	"${prog_dir}" \
	"${prog_file}"

    #
    #.vscode/tasks.json
    #
    generate_vscode_file_one \
	"${MKCROSS_VSCODE_TEMPL_DIR}/_vscode/tasks.json" \
	"${vscode_vscode_dir}/tasks.json" \
	"${cpu}" \
	"${target}" \
	"${prefix}" \
	"${qemu_cpu}" \
	"${qemu_opt}" \
	"${prog_dir}" \
	"${prog_file}"

    #
    #.vscode/settings.json
    #
    generate_vscode_file_one \
	"${MKCROSS_VSCODE_TEMPL_DIR}/_vscode/settings.json" \
	"${vscode_vscode_dir}/settings.json" \
	"${cpu}" \
	"${target}" \
	"${prefix}" \
	"${qemu_cpu}" \
	"${qemu_opt}" \
	"${prog_dir}" \
	"${prog_file}"

    #
    #.devcontainer/devcontainer.json
    #
    generate_vscode_file_one \
	"${MKCROSS_VSCODE_TEMPL_DIR}/_devcontainer/devcontainer.json" \
	"${vscode_devcontainer_dir}/devcontainer.json" \
	"${cpu}" \
	"${target}" \
	"${prefix}" \
	"${qemu_cpu}" \
	"${qemu_opt}" \
	"${prog_dir}" \
	"${prog_file}"

    #
    #.devcontainer/Dockerfile
    #
    generate_vscode_file_one \
	"${MKCROSS_VSCODE_TEMPL_DIR}/_devcontainer/Dockerfile" \
	"${vscode_devcontainer_dir}/Dockerfile" \
	"${cpu}" \
	"${target}" \
	"${prefix}" \
	"${qemu_cpu}" \
	"${qemu_opt}" \
	"${prog_dir}" \
	"${prog_file}"
}

#
# generate_vscode_file ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ ツールチェイン種別
#
generate_vscode_file(){
    local cpu="$1"
    local target="$2"
    local prefix="$3"
    local target_var
    local qemu_cpu
    local qemu_opt
    local vscode_workspace_dir
    local vscode_devcontainer_dir
    local vscode_vscode_dir
    local inf
    local inf_array
    local inf_cpu
    local inf_board
    local inf_dir
    local inf_prog_file

    target_var=`echo ${target}|sed -e 's|-|_|g'`

    qemu_cpu="${qemu_cpus[${cpu}]}"
    qemu_opt="${qemu_opts[${cpu}]}"

    echo "@@@ Visual Studio Code Dev Container Settings @@@"
    echo "target:${target}"
    echo "Sysroot:${sys_root}"
    echo "BuildDir:${build_dir}"
    echo "SourceDir:${src_dir}"
    echo "ImageName:${THIS_IMAGE_NAME}"
    if [ "x${qemu_cpu}" != "x" ]; then
	    echo "QEmuCPUName:${qemu_cpu}"
    fi

    if [ "x${qemu_opt}" != "x" ]; then
	    echo "QEmuCPUName:${qemu_opt}"
    fi
    echo "var: ${target_var}"

    #
    # 共通テンプレート
    #
    generate_vscode_file_for_board "common" \
    	"${cpu}" \
	"${target}" \
	"${prefix}" \
	"${qemu_cpu}" \
	"${qemu_opt}" \
	"__HOS_USER_PROGRAM_DIR__" \
	"__HOS_USER_PROGRAM_FILE__"

    for inf in ${board_list[@]}
    do
    	inf_array=($(echo "${inf}" | tr ":" " "))
    	inf_cpu=${inf_array[0]}
    	inf_board=${inf_array[1]}
    	inf_dir=${inf_array[2]}
    	inf_prog_file=${inf_array[3]}
	if [ "${inf_cpu}" = "${cpu}" ]; then
	        echo "@@@ board:${inf_board} dir:${inf_dir} @@@"
	        generate_vscode_file_for_board "${inf_board}" \
    					       "${cpu}" \
					       "${target}" \
					       "${prefix}" \
					       "${qemu_cpu}" \
					       "${qemu_opt}" \
					       "${MKCROSS_HOS_SRCDIR}/${inf_dir}" \
					       "${inf_prog_file}"
    	fi
    done


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


    # 各CPU向けのコンパイラを生成
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

	    generate_vscode_file \
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
