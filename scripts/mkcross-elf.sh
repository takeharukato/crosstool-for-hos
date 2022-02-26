#!/bin/bash

#TARGET_CPUS="i386 riscv32 riscv64 mips mipsel arm armhw sh2 h8300 microblaze"
TARGET_CPUS="armhw"
targets=(`echo ${TARGET_CPUS}`)

#
#
#
declare -A tool_names=(
    ["binutils"]="binutils-2.37"
    ["gcc"]="gcc-11.2.0"
    ["newlib"]="newlib-4.1.0"
    ["gdb"]="gdb-11.1"
    ["qemu"]="qemu-6.2.0"
    ["h8300-binutils"]="binutils-2.24"
    ["h8300-gcc"]="gcc-8.4.0"
    ["h8300-newlib"]="newlib-2.5.0"
    ["h8300-gdb"]="gdb-7.12"
    ["sh2-newlib"]="newlib-2.5.0"
    )
#
#アーカイブファイル名
#
declare -A tool_archives=(
    ["binutils-2.37"]="binutils-2.37.tar.gz"
    ["gcc-11.2.0"]="gcc-11.2.0.tar.gz"
    ["newlib-4.1.0"]="newlib-4.1.0.tar.gz"
    ["gdb-11.1"]="gdb-11.1.tar.gz"
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
    ["binutils-2.37"]="https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz"
    ["gcc-11.2.0"]="https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz"
    ["newlib-4.1.0"]="https://sourceware.org/pub/newlib/newlib-4.1.0.tar.gz"
    ["gdb-11.1"]="https://ftp.gnu.org/gnu/gdb/gdb-11.1.tar.gz"
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
    ["microblaze"]="microblaze-softmmu,microblaze-linux-user"
    )

#
# ターゲット名
#
declare -A cpu_target_names=(
    ["armhw-elf"]="arm-eabihf"
    ["h8300-elf"]="h8300-elf"
    ["sh2-elf"]="sh-elf"
    )


#
#インストール先
#
CROSS_PREFIX="/opt/hos/cross"

TOP_DIR=`pwd`
DOWNLOADS_DIR=${TOP_DIR}/downloads

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
	    echo "Check ${tool_key}"
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
# cross_binutils ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ
#
cross_binutils(){
    local cpu="$1"
    local target="$2"
    local prefix="$3"
    local src_dir="$4/binutils"
    local build_dir="$5/binutils"
    local sys_root="${prefix}/rfs"
    local key="binutils"
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

    pushd "${src_dir}"
    tar xf ${DOWNLOADS_DIR}/${archive}
    popd

    pushd "${build_dir}"
    ${src_dir}/${tool}/configure                          \
	      --prefix="${prefix}"                            \
	      --target="${target}"                            \
	      --with-local-prefix="${prefix}/${target}"       \
	      --disable-shared                                \
	      --disable-werror                                \
	      --disable-nls                                   \
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
# cross_gcc_stage1 ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ
#
cross_gcc_stage1(){
    local cpu="$1"
    local target="$2"
    local prefix="$3"
    local src_dir="$4/gcc_stage1"
    local build_dir="$5/gcc_stage1"
    local sys_root="${prefix}/rfs"
    local key="gcc"
    local rmfile
    local tool
    local archive

    echo "@@@ gcc_stage1 @@@"
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

    pushd "${src_dir}"
    tar xf ${DOWNLOADS_DIR}/${archive}
    popd

    pushd "${build_dir}"
    ${src_dir}/${tool}/configure                          \
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
# cross_newlib ターゲットCPU ターゲット名 プレフィクス ソース展開ディレクトリ ビルドディレクトリ
#
cross_newlib(){
    local cpu="$1"
    local target="$2"
    local prefix="$3"
    local src_dir="$4/newlib"
    local build_dir="$5/newlib"
    local sys_root="${prefix}/rfs"
    local key="newlib"
    local tool
    local archive
    local basename
    local mvfile
    local dir

    echo "@@@ newlib @@@"
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

    pushd "${src_dir}"
    tar xf ${DOWNLOADS_DIR}/${archive}
    popd

    pushd "${build_dir}"
    ${src_dir}/${tool}/configure                         \
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

main(){
    local cpu
    local prefix
    local build_dir
    local src_dir
    local orig_path
    local target_name
    local toolchain_type

    orig_path="${PATH}"

    mkdir -p ${DOWNLOADS_DIR}
    download_archives

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

	cross_binutils "${cpu}" "${target_name}" "${prefix}" "${build_dir}" "${src_dir}"
	cross_gcc_stage1 "${cpu}" "${target_name}" "${prefix}" "${build_dir}" "${src_dir}"
	cross_newlib "${cpu}" "${target_name}" "${prefix}" "${build_dir}" "${src_dir}"
	export PATH="${orig_path}"
    done
}

main $@
