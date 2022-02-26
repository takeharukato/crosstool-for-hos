# elf-cross-compilers
Cross compile environment

gccクロスコンパイラをインストールしたLinux環境(Ubuntu)のコンテナイメージです。

# イメージ取得方法

以下のコマンドを実行して, コンパイル環境のコンテナイメージを取得します。

```
docker pull ghcr.io/takeharukato/elf-cross-compilers:latest
```

実行例:
```
$ docker pull ghcr.io/takeharukato/elf-cross-compilers:latest
$
```

# イメージの確認

ダウンロードしたコンテナイメージを確認する場合は,

```
docker images
```

を実行します。

実行例は以下の通りです。
```
$ docker images
```
# コンパイル環境への入り方

以下のコマンドを実行することでコンテナイメージ内に入ることができます。

```
docker run -it ghcr.io/takeharukato/elf-cross-compilers:latest
```

ホストの作業ディレクトリ(以下の例では, カレントディレクトリにあるwork
を/home/workにマウントします) をマウントする場合は, 以下を実行します。

```
docker run -v `pwd`/work:/home/work -it ghcr.io/takeharukato/elf-cross-compilers:latest
```

実行例:

```
$ ls work
localfile.txt
$ docker run -v
`pwd`/work:/home/work -it ghcr.io/takeharukato/elf-cross-compilers:latest
```

# HOS開発者ユーザ

Hyper Operating System の開発作業に使うように開発者ユーザ`hos`を
作ってあります。
hosユーザの`.bashrc`に開発用のシェル初期化スクリプトの読み込み処理を追
加していますので, コンテナ内に(docker run などで)入った後, `su - hos`を実行することで
クロスコンパイラを使用するためのEnvironment Modulesファイルが利用でき
るようになります.

実行例:
```
root@c406e487e677:/# su - hos
hos@c406e487e677:~$ module avail

---------------------------- /usr/share/lmod/lmod/modulefiles
----------------------------
Core/lmod/6.6    Core/settarg/6.6

------------------------------ /opt/hos/cross/lmod/modules
-------------------------------
ARM-EABIHF-GCC

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules
matching any of the
"keys".

hos@c406e487e677:~$ module load ARM-EABIHF-GCC
hos@606576c27de5:~$ printenv PATH
/opt/hos/cross/armhw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
hos@606576c27de5:~$ printenv QEMU
qemu-system-arm
hos@606576c27de5:~$ printenv CROSS_COMPILE
arm-eabihf-
hos@606576c27de5:~$ printenv GDB_COMMAND
arm-eabihf-gdb
```
