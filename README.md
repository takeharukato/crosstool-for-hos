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

モジュールをロードすることで以下の設定が行われます。

* PATH クロスコンパイラへのパスが追加されます
* QEMU QEmuのシステムシミュレータへのコマンド名が設定されます
* CROSS_COMPILE クロスコンパイラのプレフィクス名が設定されます
* GDB_COMMAND クロスgdbのコマンド名が設定されます。


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

# 開発者向け情報

## コンテナイメージの自動登録について

GitHub Actionsを使用してコンテナイメージの生成とGitHub Container
Registryへの登録を行っています。

forkしたリポジトリで実行する場合, 以下の事前準備が必要です。

1. GitHubの右上のメニューからSettingsを選択します
2. 左側のメニュー内のDeveloper settingsを選択します
3. Personal Access Tokensの項目をクリックします
4. 右上のGenerate new tokenボタンを押します
5. チェックボックスでwrite packages/read packagesだけを選択します
6. Generate tokenボタンを押します
7. 発行されたPATをテキストファイルに保存します
8. 本リポジトリのSettingsを開きます
9. 右上のNew secretをクリックします
10. Secretの作成画面で, NameをCR_PAT(本ファイル内で参照している名前)
     に設定し,Valueに, 上記で獲得したPATを貼り付けてAdd secretをクリッ
     クします.

参考サイト: Github Actionsを使ってDocker ImageをGitHub Container RegistryにPushする
https://uzimihsr.github.io/post/2020-10-11-github-action-publish-docker-image-ghcr/

## ファイル構成

* Dockerfile コンテナイメージを作成するためのDockerfileです
* README.md 本ファイルです
* scripts/mkcross-elf.sh クロスコンパイル環境を構築するためのスクリプ
トです。

## スクリプトの修正

### コンパイラ作成対象のCPUを絞る場合

mkcross-elf.shの`TARGET_CPUS`変数に対象CPUを空白で区切って記述します。

記述例: i386とriscv32だけを構築する場合
```
TARGET_CPUS="i386 riscv32"
```

### ツールチェインの定義
bash連想配列によってツールチェインの各アーカイブの展開時にできる
ディレクトリ名, アーカイブファイル名などを定義します。

### tool_names

ツールチェインの種別からツールチェインの版数を取り出すための連想配列で
す。 アーカイブの展開時にできるディレクトリ名を指定します

キーとして,  `binutils`, `gcc`, `newlib`, `gdb`, `qemu`を指定すると
CPU間で共通で使用するツールチェインの版数情報を設定できます。

`TARGET_CPUSに記述したCPU名-ツールチェイン種別`をキーに設定すると
特定のCPUについて使用するツールチェインの版数を変更することができます。

記述例: CPU間で共通で使用するbinutilsの版数をbinutils-2.37に設定する
```
    ["binutils"]="binutils-2.37"
```

記述例: h8300で使用するbinutilsの版数をbinutils-2.24に設定する
```
    ["h8300-binutils"]="binutils-2.24"
```

### tool_archives

tool_namesで指定したツールチェインの版数をキーとして,
対象のツールチェインのアーカイブのファイル名を取り出す
為の連想配列です。

リダイレクトなどにより, URLからアーカイブ名を取り出せないケースを想定
して本変数を導入しています。

記述例: binutils-2.37のアーカイブ名をbinutils-2.37.tar.gzに設定する
```
    ["binutils-2.37"]="binutils-2.37.tar.gz"
```

### tool_urls

tool_namesで指定したツールチェインの版数をキーとして,
対象のツールチェインのアーカイブをダウンロードするURLを取り出す
為の連想配列です。

記述例: binutils-2.37のダウンロードURLを
https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz
に設定する
```
    ["binutils-2.37"]="https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz"
```

## qemu_targets

TARGET_CPUSに記述したCPU名をキーに, QEmuのターゲットリストに指定する値
を取り出すための連想配列です。
ハードウエアFPUを使用するArmのコンパイラなどクロスコンパイラの種別を表
すCPU名とQEmuのCPU名とを対応づけるために導入しています。

記述例: ハードウエアFPUを使用するArm(armhw)向けに
arm-softmmu,arm-linux-user
ターゲットを構築する場合
```
["armhw"]="arm-softmmu,arm-linux-user"
```

## qemu_cpus

TARGET_CPUSに記述したCPU名をキーに, QEmuのcpu名を取り出すための連想配列です。
QEmuのシステムシミュレータのコマンド名をEnvironment Modules/Lmodの環境
変数に設定するために使用しています。
テストの自動化を行うために本変数を導入しています。
将来的には, qemu_targetsを廃止し, qemu_cpusから得たCPU名からQEmuターゲッ
トを指定するようにする予定です。

記述例: ハードウエアFPUを使用するArm(armhw)のQEmuのCPU名をarmに設定す
```
["armhw"]="arm"
```

## cpu_target_names

gccクロスコンパイラ作成時に指定するターゲット指定用tripletを定義するた
めの連想配列です。

TARGET_CPUSに記述した`CPU名-elf`をキーに, ターゲット指定用tripletを取
り出します。

ハードウエアFPU版Armコンパイラなどの`CPU名-unknown-elf`形式以外の
tripletを指定するために導入しています。

記述例: ハードウエアFPUを使用するArm(armhw)のターゲット指定用tripletを
arm-eabihfに設定します。
```
    ["armhw-elf"]="arm-eabihf"
```
