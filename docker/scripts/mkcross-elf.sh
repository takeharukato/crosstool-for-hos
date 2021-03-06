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
	#TARGET_CPUS="h8300"
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
#パッチ配置先ディレクトリ
#
MKCROSS_PATCHES_DIR=${MKCROSS_SCRIPTS_DIR}/patches
#
#vscodeのテンプレート
#
MKCROSS_VSCODE_TEMPL_DIR=${MKCROSS_SCRIPTS_DIR}/vscode

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
# cross_binutils ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ ツールチェイン種別
#
cross_binutils(){
	local cpu="$1"
	local target="$2"
	local prefix="$3"
	local src_dir="$4/binutils"
	local build_dir="$5/binutils"
	local toolchain_type="$6"
	local sys_root="${prefix}/rfs"
	local key="binutils"
	local sim_arg
	local archive
	local tool
	local rmfile

	echo "@@@ binutils @@@"
	echo "Prefix:${prefix}"
	echo "target:${target}"
	echo "Sysroot:${sys_root}"
	echo "BuildDir:${build_dir}"
	echo "SourceDir:${src_dir}"

	tool=`get_tool_name ${cpu} ${key}`
	archive=`get_archive_name ${cpu} ${key}`

	if [ "x${archive}" = "x" ]; then
		echo "No ${key} for ${cpu}"
		return 1
	fi

	mkdir -p "${sys_root}"
	if [ -d "${src_dir}" ]; then
		rm -fr "${src_dir}"
	fi
	mkdir -p "${src_dir}"

	if [ -d "${build_dir}" ]; then
		rm -fr "${build_dir}"
	fi
	mkdir -p "${build_dir}"

	#
	# Simulator
	#
	sim_arg=""
	case "${cpu}" in
		microblaze | microblazeel)
			sim_arg="--disable-sim"
			;;
	esac

	pushd "${src_dir}"
	tar xf ${DOWNLOADS_DIR}/${archive}
	popd

	pushd "${build_dir}"
	${src_dir}/${tool}/configure                              \
		--prefix="${prefix}"                            \
		--target="${target}"                            \
		--with-local-prefix="${prefix}/${target}"       \
		--disable-shared                                \
		--disable-werror                                \
		--disable-nls                                   \
		${sim_arg}                                      \
		--with-sysroot="${sys_root}"
	make -j`nproc`
	make install
	popd

	#
	#.laファイルを削除する
	#
	echo "Remove .la files"

	find ${prefix} -name '*.la'|while read rmfile
	do
		echo "Remove ${rmfile}"
		rm -f ${rmfile}
	done

	#
	#ビルド環境のツールと混在しないようにする
	#
	echo "Remove addr2line ar as c++filt elfedit gprof ld ld.bfd nm objcopy objdump ranlib readelf size strings strip on ${prefix}/bin"

	for rmfile in addr2line ar as c++filt elfedit gprof ld ld.bfd nm objcopy objdump ranlib readelf size strings strip
	do
		if [ -f "${prefix}/bin/${rmfile}" ]; then
			rm -f "${prefix}/bin/${rmfile}"
		fi
	done
}

#
# cross_gcc_stage1 ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ ツールチェイン種別
#
cross_gcc_stage1(){
	local cpu="$1"
	local target="$2"
	local prefix="$3"
	local src_dir="$4/gcc_stage1"
	local build_dir="$5/gcc_stage1"
	local toolchain_type="$6"
	local sys_root="${prefix}/rfs"
	local key="gcc"
	local rmfile
	local tool
	local archive
	local target_cflags

	target_cflags="${cpu_target_cflags[${cpu}-${toolchain_type}]}"

	echo "@@@ gcc_stage1 @@@"
	echo "Prefix:${prefix}"
	echo "target:${target}"
	echo "Sysroot:${sys_root}"
	echo "BuildDir:${build_dir}"
	echo "SourceDir:${src_dir}"
	echo "Target Cflags:${target_cflags}"

	tool=`get_tool_name ${cpu} ${key}`
	archive=`get_archive_name ${cpu} ${key}`

	if [ "x${archive}" = "x" ]; then
		echo "No ${key} for ${cpu}"
		return 1
	fi

	mkdir -p "${sys_root}"
	if [ -d "${src_dir}" ]; then
		rm -fr "${src_dir}"
	fi
	mkdir -p "${src_dir}"

	if [ -d "${build_dir}" ]; then
		rm -fr "${build_dir}"
	fi
	mkdir -p "${build_dir}"

	pushd "${src_dir}"
	tar xf ${DOWNLOADS_DIR}/${archive}
	popd

	pushd "${build_dir}"
	env CFLAGS_FOR_TARGET="${MKCROSS_OPT_FLAGS_FOR_TARGET} ${target_cflags}" \
	${src_dir}/${tool}/configure                              \
		--prefix="${prefix}"                            \
		--target="${target}"                            \
		--with-local-prefix="${prefix}/${target}"       \
		--disable-shared                                \
		--disable-werror                                \
		--disable-nls                                   \
		--enable-languages=c                                 \
		--disable-bootstrap                                  \
		--disable-werror                                     \
		--disable-shared                                     \
		--disable-multilib                                   \
		--with-newlib                                        \
		--without-headers                                    \
		--disable-lto                                        \
		--disable-threads                                    \
		--disable-decimal-float                              \
		--disable-libatomic                                  \
		--disable-libitm                                     \
		--disable-libquadmath                                \
		--disable-libvtv                                     \
		--disable-libcilkrts                                 \
		--disable-libmudflap                                 \
		--disable-libssp                                     \
		--disable-libmpx                                     \
		--disable-libgomp                                    \
		--disable-libsanitizer                               \
		--with-sysroot="${sys_root}"

	#
	#make allを実行できるだけのヘッダやC標準ライブラリがないため部分的に
	#コンパイラの構築を行う
	#
	#crosstool-ng-1.19.0のscripts/build/cc/gcc.shを参考にした
	#

	#
	#cpp/libiberty(GNU共通基盤ライブラリ)の構築
	#
	make configure-gcc configure-libcpp configure-build-libiberty
	make -j`nproc` all-libcpp all-build-libiberty

	#
	#libdecnumber/libbacktrace(gccの動作に必須なライブラリ)の構築
	#
	make configure-libdecnumber
	make -j`nproc` -C libdecnumber libdecnumber.a
	make configure-libbacktrace
	make -j`nproc` -C libbacktrace

	#
	#gcc(Cコンパイラ)とアーキ共通基盤ライブラリ(libgcc)の構築
	#
	make -C gcc libgcc.mvars
	make -j`nproc` all-gcc all-target-libgcc
	make install-gcc install-target-libgcc

	popd


	#
	#.laファイルを削除する
	#
	echo "Remove .la files"

	find ${prefix} -name '*.la'|while read rmfile
	do
		echo "Remove ${rmfile}"
		rm -f ${rmfile}
	done

	#
	#ホストのgccとの混乱を避けるため以下を削除
	#
	echo "Remove cpp gcc gcc-ar gcc-nm gcc-ranlib gcov ${target}-cc on ${prefix}/bin"
	for rmfile in cpp gcc gcc-ar gcc-nm gcc-ranlib gcov ${target}-cc
	do
		if [ -f "${prefix}/bin/${rmfile}" ]; then
			rm -f "${prefix}/bin/${rmfile}"
		fi
	done
}

#
# cross_newlib ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ ツールチェイン種別
#
cross_newlib(){
	local cpu="$1"
	local target="$2"
	local prefix="$3"
	local src_dir="$4/newlib"
	local build_dir="$5/newlib"
	local toolchain_type="$6"
	local sys_root="${prefix}/rfs"
	local key="newlib"
	local tool
	local archive
	local basename
	local mvfile
	local dir
	local target_cflags

	target_cflags="${cpu_target_cflags[${cpu}-${toolchain_type}]}"

	echo "@@@ newlib @@@"
	echo "Prefix:${prefix}"
	echo "target:${target}"
	echo "Sysroot:${sys_root}"
	echo "BuildDir:${build_dir}"
	echo "SourceDir:${src_dir}"
	echo "Target Cflags:${target_cflags}"

	tool=`get_tool_name ${cpu} ${key}`
	archive=`get_archive_name ${cpu} ${key}`

	if [ "x${archive}" = "x" ]; then
		echo "No ${key} for ${cpu}"
		return 1
	fi


	mkdir -p "${sys_root}"
	if [ -d "${src_dir}" ]; then
		rm -fr "${src_dir}"
	fi
	mkdir -p "${src_dir}"

	if [ -d "${build_dir}" ]; then
		rm -fr "${build_dir}"
	fi
	mkdir -p "${build_dir}"

	pushd "${src_dir}"
	tar xf ${DOWNLOADS_DIR}/${archive}
	popd

	pushd "${build_dir}"
	env CFLAGS_FOR_TARGET="${MKCROSS_OPT_FLAGS_FOR_TARGET} ${target_cflags}"   \
	${src_dir}/${tool}/configure                   \
		--prefix="${prefix}"                       \
		--target="${target}"

	make -j`nproc`
	make DESTDIR=${sys_root} prefix=/usr install
	popd

	#
	#includeとlibの位置を補正する
	#
	rm -fr ${sys_root}/usr/include ${sys_root}/usr/lib ${sys_root}/usr/lib64
	mkdir -p ${sys_root}/usr
	find ${sys_root}/usr/${target} | while read mvfile
	do
		if [ -e "${mvfile}" ]; then
			echo "Move ${mvfile} to ${sys_root}/usr"
			mv "${mvfile}" "${sys_root}/usr"
		fi
	done
	if [ -d "${sys_root}/usr/${target}" ]; then
		rm -fr "${sys_root}/usr/${target}"
	fi

	#
	# sh2などsysrootに対応していないコンパイラのために
	# includeとlibをローカルプレフィクスから参照可能にする
	#

	mkdir -p ${prefix}/${target}/include
	mkdir -p ${prefix}/${target}/lib
	for dir in include lib
	do
		find "${sys_root}/usr/${dir}" | while read mvfile
		do
			basename=`basename ${mvfile}`
			echo "link ../../rfs/usr/${dir}/${basename} from ${prefix}/${target}/${dir}"
			ln -sf "../../rfs/usr/${dir}/${basename}" "${prefix}/${target}/${dir}"
		done
	done
}

#
# cross_gcc_elf_final ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ ツールチェイン種別
#
cross_gcc_elf_final(){
	local cpu="$1"
	local target="$2"
	local prefix="$3"
	local src_dir="$4/gcc_elf_final"
	local build_dir="$5/gcc_elf_final"
	local toolchain_type="$6"
	local sys_root="${prefix}/rfs"
	local key="gcc"
	local rmfile
	local tool
	local archive
	local target_cflags

	target_cflags="${cpu_target_cflags[${cpu}-${toolchain_type}]}"

	echo "@@@ gcc_elf @@@"
	echo "Prefix:${prefix}"
	echo "target:${target}"
	echo "Sysroot:${sys_root}"
	echo "BuildDir:${build_dir}"
	echo "SourceDir:${src_dir}"
	echo "Target Cflags:${target_cflags}"

	tool=`get_tool_name ${cpu} ${key}`
	archive=`get_archive_name ${cpu} ${key}`

	if [ "x${archive}" = "x" ]; then
	echo "No ${key} for ${cpu}"
	return 1
	fi

	mkdir -p "${sys_root}"
	if [ -d "${src_dir}" ]; then
		rm -fr "${src_dir}"
	fi
	mkdir -p "${src_dir}"

	if [ -d "${build_dir}" ]; then
		rm -fr "${build_dir}"
	fi
	mkdir -p "${build_dir}"

	pushd "${src_dir}"
	tar xf ${DOWNLOADS_DIR}/${archive}
	popd

	pushd "${build_dir}"
	#
	# configureの設定
	#
	#--prefix="${prefix}"
	#          ${prefix}配下にインストールする
	#--target="${target}"
	#          ターゲット環境向けのコードを生成するコンパイラを構築する
	#--with-local-prefix="${prefix}/${target}"
	#          gcc内部で使用するファイルを"${prefix}/${target}"に格納する
	#--with-sysroot="${sys_root}"
	#          コンパイラの実行時にターゲットのルートファイルシステムを優先してヘッダや
	#          ライブラリを探査する
	#--enable-languages=c,c++,lto
	#          c/c++/ltoを生成
	#--disable-bootstrap
	#          ビルド環境もgccを使用することから, 時間削減のためビルド環境とホスト環境が
	#          同一CPUの場合でも, 3stageコンパイルを無効にする
	#--disable-werror
	#         警告をエラーと見なさない
	#--disable-shared
	#          gccの共有ランタイムライブラリを生成しない
	#--disable-multilib
	#          バイアーキ(32/64bit両対応)版gccの生成を行わない。
	#--with-newlib
	#          libcを自動リンクしないコンパイラを生成する
	#--enable-tls
	#          Thread Local Storage機能を使用する
	#--disable-threads
	#          ターゲット用のlibpthreadがないためスレッドライブラリに対応しない
	#--disable-libmpx
	#           MPX(Memory Protection Extensions)ライブラリをビルドしない
	#--disable-libgomp
	#           GNU OpenMPライブラリを生成しない
	#--disable-libsanitizer
	#           libsanitizerを生成しない
	#--disable-nls
	#         コンパイル時間を短縮するためNative Language Supportを無効化する
	env CFLAGS_FOR_TARGET="${MKCROSS_OPT_FLAGS_FOR_TARGET} ${target_cflags}"   \
	${src_dir}/${tool}/configure                              \
		--prefix="${prefix}"                            \
		--target="${target}"                            \
		--with-local-prefix="${prefix}/${target}"       \
		--disable-shared                                \
		--disable-werror                                \
		--disable-nls                                   \
		--enable-languages="c,c++,lto"                       \
		--disable-bootstrap                                  \
		--disable-multilib                                   \
		--with-newlib                                        \
		--disable-threads                                    \
		--disable-libatomic                                  \
		--disable-libitm                                     \
		--disable-libvtv                                     \
		--disable-libcilkrts                                 \
		--disable-libmpx                                     \
		--disable-libgomp                                    \
		--disable-libsanitizer                                \
		--enable-decimal-float                               \
		--enable-libquadmath                                 \
		--enable-libmudflap                                  \
		--enable-libssp                                      \
		--enable-tls                                         \
		--with-sysroot="${sys_root}"

	make -j`nproc`
	make install

	popd


	#
	#.laファイルを削除する
	#
	echo "Remove .la files"

	find ${prefix} -name '*.la'|while read rmfile
	do
		echo "Remove ${rmfile}"
		rm -f ${rmfile}
	done

	#
	#ホストのgccとの混乱を避けるため以下を削除
	#
	echo "Remove cpp gcc gcc-ar gcc-nm gcc-ranlib gcov ${target}-cc on ${prefix}/bin"
	for rmfile in cpp gcc gcc-ar gcc-nm gcc-ranlib gcov ${target}-cc
	do
		if [ -f "${prefix}/bin/${rmfile}" ]; then
			rm -f "${prefix}/bin/${rmfile}"
		fi
	done

	#
	# クロスコンパイラへのリンクを張る
	#
	rm -f ${prefix}/bin/${target}-cc
	ln -sf ${target}-gcc ${prefix}/bin/${target}-cc
}

#
# cross_gdb ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ ツールチェイン種別
#
cross_gdb(){
	local cpu="$1"
	local target="$2"
	local prefix="$3"
	local src_dir="$4/gdb"
	local build_dir="$5/gdb"
	local toolchain_type="$6"
	local sys_root="${prefix}/rfs"
	local key="gdb"
	local python_path
	local python_arg
	local rmfile
	local tool
	local archive
	local sim_arg

	echo "@@@ gdb @@@"
	echo "Prefix:${prefix}"
	echo "target:${target}"
	echo "Sysroot:${sys_root}"
	echo "BuildDir:${build_dir}"
	echo "SourceDir:${src_dir}"

	tool=`get_tool_name ${cpu} ${key}`
	archive=`get_archive_name ${cpu} ${key}`

	if [ "x${archive}" = "x" ]; then
		echo "No ${key} for ${cpu}"
		return 1
	fi

	mkdir -p "${sys_root}"
	if [ -d "${src_dir}" ]; then
		rm -fr "${src_dir}"
	fi
	mkdir -p "${src_dir}"

	if [ -d "${build_dir}" ]; then
		rm -fr "${build_dir}"
	fi
	mkdir -p "${build_dir}"

	#
	# python連携
	#
	python_path=`which python`
	if [ "none${python_path}" = "none" ]; then
		python_path=`which python3`
	if [ "none${python_path}" = "none" ]; then
		python_path=`which python2`
	fi
	fi

	if [ "none${python_path}" = "none" ]; then
		python_path='none'
	fi

	if [ "${python_path}" != "none" ]; then
	echo "Python is installed on ${python_path}"
		python_arg="--with-python=${python_path}"
	else
		python_arg=""
	fi

	case "${cpu}" in
		v850)
			python_arg="--with-python=no"
			;;
	esac

	#
	# Simulator
	#
	sim_arg=""
	case "${cpu}" in
		microblaze | microblazeel)
			sim_arg="--disable-sim"
			;;
	esac

	pushd "${src_dir}"
	tar xf ${DOWNLOADS_DIR}/${archive}
	popd

	#
	#gdb用のパッチを適用
	#
	pushd "${src_dir}/${tool}"
	patch -p1 < ${MKCROSS_PATCHES_DIR}/gdb/gdb-8.3-qemu-x86-64.patch
	popd
	#
	# configureの設定
	#
	#--prefix="${prefix}"
	#          ${prefix}配下にインストールする
	#--target="${target}"
	#          ターゲット環境向けのコードを生成するコンパイラを構築する
	#--with-local-prefix="${prefix}/${target}"
	#          gdb内部で使用するファイルを"${prefix}/${target}"に格納する
	#${python_arg}
	#          pythonスクリプトによるデバッグ支援機能を有効にする
	#--disable-werror
	#         警告をエラーと見なさない
	#--disable-nls
	#         コンパイル時間を短縮するためNative Language Supportを無効化する
	#
	pushd "${build_dir}"
	${src_dir}/${tool}/configure                              \
		--prefix="${prefix}"                            \
		--target="${target}"                            \
		--with-local-prefix="${prefix}/${target}"       \
		${python_arg}                                   \
		${sim_arg}                                      \
		--disable-werror                                \
		--disable-nls                                   \

	make -j`nproc`
	make install

	popd


	#
	#.laファイルを削除する
	#
	echo "Remove .la files"

	find ${prefix} -name '*.la'|while read rmfile
	do
		echo "Remove ${rmfile}"
		rm -f ${rmfile}
	done
}

#
# build_qemu ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ ツールチェイン種別
#
build_qemu(){
	local cpu="$1"
	local target="$2"
	local prefix="$3"
	local src_dir="$4/qemu"
	local build_dir="$5/qemu"
	local toolchain_type="$6"
	local sys_root="${prefix}/rfs"
	local qemu_target_list
	local key="qemu"
	local tool
	local archive

	qemu_target_list="${qemu_targets[${cpu}]}"

	if [ "x${qemu_target_list}" = "x" ]; then
		echo "No ${key} for ${cpu}"
		return 1
	fi

	echo "@@@ qemu @@@"
	echo "Prefix:${prefix}"
	echo "target:${target}"
	echo "Sysroot:${sys_root}"
	echo "BuildDir:${build_dir}"
	echo "SourceDir:${src_dir}"
	echo "QEmu targets: ${qemu_target_list}"

	tool=`get_tool_name ${cpu} ${key}`
	archive=`get_archive_name ${cpu} ${key}`

	if [ "x${archive}" = "x" ]; then
		echo "No ${key} for ${cpu}"
		return 1
	fi

	mkdir -p "${sys_root}"
	if [ -d "${src_dir}" ]; then
		rm -fr "${src_dir}"
	fi
	mkdir -p "${src_dir}"

	if [ -d "${build_dir}" ]; then
		rm -fr "${build_dir}"
	fi
	mkdir -p "${build_dir}"

	pushd "${src_dir}"
	tar xf ${DOWNLOADS_DIR}/${archive}
	popd

	pushd "${build_dir}"
	${src_dir}/${tool}/configure                        \
		--prefix="${prefix}"                            \
		--target-list="${qemu_target_list}"             \
		--enable-user                                   \
		--enable-linux-user                             \
		--enable-system                                 \
		--interp-prefix="${sys_root}"                   \
		--enable-tcg-interpreter                        \
		--enable-modules                                \
		--enable-membarrier                             \
		--disable-werror

	make -j`nproc`
	make install

	popd
}

#
# generate_module_file ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ ツールチェイン種別
#
generate_module_file(){
	local cpu="$1"
	local target="$2"
	local prefix="$3"
	local key="lmod"
	local mod_file
	local target_var
	local qemu_cpu
	local qemu_line

	target_var=`echo ${target}|sed -e 's|-|_|g'`

	qemu_cpu="${qemu_cpus[${cpu}]}"
	qemu_line="# No QEmu system simulator for ${target}"
	if [ "x${qemu_cpu}" != "x" ]; then
		qemu_line="setenv QEMU	   qemu-system-${qemu_cpu}"
	fi

	echo "@@@ Environment Module File @@@"
	echo "target:${target}"
	echo "Sysroot:${sys_root}"
	echo "BuildDir:${build_dir}"
	echo "SourceDir:${src_dir}"
	if [ "x${qemu_cpu}" != "x" ]; then
		echo "QEmuCPUName:${qemu_cpu}"
	fi
	echo "var: ${target_var}"

	mod_file=`echo "${target}"| tr '[:lower:]' '[:upper:]'`
	mod_file="${mod_file}-GCC"
	echo "Generate ${mod_file} ..."

	mkdir -p ${LMOD_MODULE_DIR}

	#
	# Tcl形式のEnvironment Moduleファイルを生成
	#
	cat <<EOF > "${LMOD_MODULE_DIR}/${mod_file}"
#%Module1.0
##
## gcc toolchain for ${target}
##
## Note: This is generated automatically.
##

proc ModulesHelp { } {
		puts stderr "gcc toolchain for ${target} Setting \n"
}
#
module-whatis   "gcc toolchain for ${target} Setting"

# for Tcl script only
set ${target_var}_gcc_path "${prefix}/bin"

# environmnet variables
setenv CROSS_COMPILE ${target}-
setenv GCC_ARCH      ${target}-
setenv GDB_COMMAND   ${target}-gdb

${qemu_line}

# append pathes
prepend-path    PATH    \${${target_var}_gcc_path}

EOF
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
	vscode_workspace_dir="${prefix}/vscode/${outdir}"
	# vscodeの.devcontainerディレクトリ
	vscode_devcontainer_dir="${vscode_workspace_dir}/_devcontainer"
	# vscodeの.vscodeディレクトリ
	vscode_vscode_dir="${vscode_workspace_dir}/_vscode"

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

#
#generate_shell_init
# 開発環境初期化スクリプトを導入する
#
generate_shell_init(){
	local shell

	mkdir -p ${SHELL_INIT_DIR}

	#
	# bash用初期化スクリプト
	#
	cat <<EOF > "${SHELL_INIT_DIR}/bash"
#
# Cross compiler setup for bash
#
if [ -f /etc/profile.d/lmod.sh ];then
	source /etc/profile.d/lmod.sh
	module use --append ${LMOD_MODULE_DIR}
fi
EOF

	#
	# zsh用初期化スクリプト
	#
	cat <<EOF > "${SHELL_INIT_DIR}/zsh"
#
# Cross compiler setup for zsh
#
if [ -f /etc/profile.d/lmod.sh ]; then
	source /etc/profile.d/lmod.sh
	module use --append ${LMOD_MODULE_DIR}
fi
EOF

	ls -l ${SHELL_INIT_DIR}

}

#
#環境準備
#
prepare(){

	apt update;

	apt install -y sudo

	apt install -y emacs vim nano

	apt install -y device-tree-compiler

	apt install -y language-pack-ja-base language-pack-ja

	apt install -y git ninja-build python3 python3-dev swig

	apt install -y autoconf automake autotools-dev curl python3 libmpc-dev \
	libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
	libtool patchutils bc zlib1g-dev libexpat-dev lmod

	apt install -y giflib-tools libpng-dev libtiff-dev libgtk-3-dev \
	libncursesw6 libncurses5-dev libncursesw5-dev libgnutls30 nettle-dev \
	libgcrypt20-dev libsdl2-dev libguestfs-tools python3-brlapi \
	bluez-tools bluez-hcidump bluez libusb-dev libcap-dev libcap-ng-dev \
	libiscsi-dev  libnfs-dev libguestfs-dev libcacard-dev liblzo2-dev \
	liblzma-dev libseccomp-dev libssh-dev libssh2-1-dev libglu1-mesa-dev \
	mesa-common-dev freeglut3-dev ngspice-dev libattr1-dev libaio-dev \
	libtasn1-dev google-perftools libvirglrenderer-dev multipath-tools \
	libsasl2-dev libpmem-dev libudev-dev libcapstone-dev librdmacm-dev \
	libibverbs-dev libibumad-dev libvirt-dev libffi-dev libbpfcc-dev \
	libdaxctl-dev
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

	mkdir -p ${LMOD_MODULE_DIR}
	mkdir -p ${SHELL_INIT_DIR}
	mkdir -p ${DOWNLOADS_DIR}

	# 開発環境セットアップ
	prepare

	#
	# クロス環境構築
	#

	#アーカイブのダウンロード
	download_archives

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

		export PATH="${prefix}/bin:${orig_path}"

		build_qemu  \
			"${cpu}" "${target_name}" "${prefix}" "${src_dir}" "${build_dir}" "${toolchain_type}"

		cross_binutils \
			"${cpu}" "${target_name}" "${prefix}" "${src_dir}" "${build_dir}" "${toolchain_type}"
		cross_gcc_stage1 \
			"${cpu}" "${target_name}" "${prefix}" "${src_dir}" "${build_dir}" "${toolchain_type}"
		cross_newlib "${cpu}" "${target_name}" "${prefix}" "${src_dir}" "${build_dir}" "${toolchain_type}"
		cross_gcc_elf_final \
			"${cpu}" "${target_name}" "${prefix}" "${src_dir}" "${build_dir}" "${toolchain_type}"
		cross_gdb "${cpu}" "${target_name}" "${prefix}" "${src_dir}" "${build_dir}" "${toolchain_type}"

		generate_module_file \
			"${cpu}" "${target_name}" "${prefix}" "${src_dir}" "${build_dir}" "${toolchain_type}"

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

		export PATH="${orig_path}"
	done

	#
	#シェルの初期化ファイルを作成する
	#
	generate_shell_init

	#
	# 開発者ユーザを作成する
	#
	echo "@@@ Create User @@@"
	groupadd -g "${DEVLOPER_GID}" "${DEVLOPER_NAME}"
	adduser                                             \
	        -q                                          \
		--uid "${DEVLOPER_UID}"                     \
		--gid "${DEVLOPER_GID}"                     \
		--shell "${DEVLOPER_SHELL}"                 \
		--home "${DEVLOPER_HOME}"                   \
		--gecos "Hyper Operating System Developer"  \
		"${DEVLOPER_NAME}"

	# sudoerに追加
	usermod -aG sudo "${DEVLOPER_NAME}"

	# パスワードレスでsudoを実行可能にする
	echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

	#
	# .bashrcを更新する
	#
	if [ -f ${DEVLOPER_HOME}/.bashrc ]; then
	cat <<EOF >> ${DEVLOPER_HOME}/.bashrc
#
# HOS development environment
#
if [ -f ${SHELL_INIT_DIR}/bash ]; then
	source ${SHELL_INIT_DIR}/bash
fi
#
# set prompt
#
export PS1="[\u@\h \W] "
#
# Language Environment
#
export LANG="ja_JP.UTF-8"
EOF
	fi
	#
	# sshディレクトリ
	#
	mkdir -p "${DEVLOPER_HOME}/.ssh"
	chmod 700 "${DEVLOPER_HOME}/.ssh"
	chown "${DEVLOPER_UID}:${DEVLOPER_GID}" "${DEVLOPER_HOME}/.ssh"
	touch "${DEVLOPER_HOME}/.ssh/authorized_keys"
	chmod 600 "${DEVLOPER_HOME}/.ssh/authorized_keys"
	chown "${DEVLOPER_UID}:${DEVLOPER_GID}" "${DEVLOPER_HOME}/.ssh/authorized_keys"
	echo "Complete"
}

main $@
