# crosstool-for-hos

- [crosstool-for-hos](#crosstool-for-hos)
  - [はじめに](#はじめに)
    - [対応CPU](#対応cpu)
    - [コンテナイメージ取得方法](#コンテナイメージ取得方法)
    - [コンテナイメージの確認方法](#コンテナイメージの確認方法)
  - [コンテナ内のコンパイル環境の利用法](#コンテナ内のコンパイル環境の利用法)
    - [コンテナ環境への入り方](#コンテナ環境への入り方)
    - [ホスト環境のディレクトリへのアクセス方法](#ホスト環境のディレクトリへのアクセス方法)
    - [シェル用初期化処理スクリプト](#シェル用初期化処理スクリプト)
    - [HOS開発者ユーザについて](#hos開発者ユーザについて)
      - [HOS開発者ユーザ`hos`を使用した開発](#hos開発者ユーザhosを使用した開発)
      - [`hos`ユーザの.bashrcについて](#hosユーザのbashrcについて)
      - [Lmodを用いたコンパイル環境の切り替え](#lmodを用いたコンパイル環境の切り替え)
        - [モジュールによって設定される環境変数](#モジュールによって設定される環境変数)
  - [Visual Studio Codeを用いた開発環境の構築・利用方法](#visual-studio-codeを用いた開発環境の構築利用方法)
    - [Gitの設定](#gitの設定)
    - [Visual Studio Code環境のセットアップ](#visual-studio-code環境のセットアップ)
    - [コンテナイメージを取得](#コンテナイメージを取得)
    - [コンテナの起動](#コンテナの起動)
    - [コンテナの停止](#コンテナの停止)
    - [コンテナ内の設定ファイルをホストにコピー](#コンテナ内の設定ファイルをホストにコピー)
    - [コンテナの削除](#コンテナの削除)
    - [ワークスペースファイルのオープン](#ワークスペースファイルのオープン)
    - [`_vscode/launch.json`, `_vscode/tasks.json`の修正](#_vscodelaunchjson-_vscodetasksjsonの修正)
    - [ディレクトリ名の変更](#ディレクトリ名の変更)
    - [ワークスペースファイルの再オープン](#ワークスペースファイルの再オープン)
    - [HOSソースリポジトリの追加](#hosソースリポジトリの追加)
    - [Visual Studio Code環境のセットアップ作業例](#visual-studio-code環境のセットアップ作業例)
    - [launch.json/tasks.jsonの修正例](#launchjsontasksjsonの修正例)
      - [.vscode/launch.jsonの修正点](#vscodelaunchjsonの修正点)
      - [.vscode/tasks.jsonの修正点](#vscodetasksjsonの修正点)
    - [VSCodeのターミナル使用時の留意事項](#vscodeのターミナル使用時の留意事項)
    - [VSCodeを用いたコンパイル・デバッグ](#vscodeを用いたコンパイルデバッグ)
  - [開発者向け情報](#開発者向け情報)
    - [コンテナイメージの自動登録について](#コンテナイメージの自動登録について)
    - [コンテナイメージの公開](#コンテナイメージの公開)
    - [ファイル構成](#ファイル構成)
    - [Makefileについて](#makefileについて)
    - [スクリプトの修正](#スクリプトの修正)
      - [コンパイラ作成対象のCPUを絞る場合](#コンパイラ作成対象のcpuを絞る場合)
      - [ツールチェインの定義](#ツールチェインの定義)
      - [tool_names](#tool_names)
      - [tool_archives](#tool_archives)
      - [tool_urls](#tool_urls)
      - [qemu_targets](#qemu_targets)
      - [qemu_cpus](#qemu_cpus)
      - [qemu_opts](#qemu_opts)
      - [cpu_target_names](#cpu_target_names)
      - [cpu_target_cflags](#cpu_target_cflags)
  - [付録: EmacsのGrand Unified Debugger modeでデバッグするための設定](#付録-emacsのgrand-unified-debugger-modeでデバッグするための設定)

## はじめに

gcc ELFバイナリ向けクロスコンパイラをインストールしたLinux環境(Ubuntu)のコンテナイメージです。

Hyper Operating System の開発・試験に使用することを想定しています。

- リポジトリ: <https://github.com/takeharukato/crosstool-for-hos>
- コンテナイメージパッケージ: <https://github.com/takeharukato?tab=packages>
- Hyper Operating System : <https://ja.osdn.net/projects/hos/>
- HOS-V4 Advance -μITRON4.0仕様 RealTime-OS (作者local版): <https://github.com/ryuz/hos-v4a>

### 対応CPU

対応CPUは以下の通りです。

|  CPU名  |  ターゲット  | クロスコンパイラのインストール先 | Lmodのモジュール名 |
| ---- | ---- | ---- | ---- |
|  h8300  |  H8 300H用 | /opt/hos/cross/h8300 | H8300-ELF-GCC |
|  sh2  |  SH2用  | /opt/hos/cross/sh2 | SH-ELF_GCC |
|  i386  |  IA32用  | /opt/hos/cross/i386 | I386-UNKNOWN-ELF-GCC |
|  arm  |  32bit Arm soft float 用  |  /opt/hos/cross/arm | ARM-NONE-EABI-GCC |
|  arm  |  32bit Arm hard float 用  |  /opt/hos/cross/armhw | ARM-EABIHF-GCC |
|  microblaze  |  MicroBlaze big-endian 用  |  /opt/hos/cross/microblaze | MICROBLAZE-UNKNOWN-ELF-GCC |
|  microblaze  |  MicroBlaze little-endian 用  |  /opt/hos/cross/microblazeel | MICROBLAZEEL-UNKNOWN-ELF-GCC |
| mips | 32bit MIPS big-endian 用 | /opt/hos/cross/mips | MIPS-UNKNOWN-ELF-GCC |
| mips | 32bit MIPS little-endian 用 | /opt/hos/cross/mipsel | MIPSEL-UNKNOWN-ELF-GCC |
| riscv | 32bit RISC-V 用 | /opt/hos/cross/riscv32 | RISCV32-UNKNOWN-ELF-GCC |
| riscv | 64bit RISC-V 用 | /opt/hos/cross/riscv64 | RISCV64-UNKNOWN-ELF-GCC |

arm, microblaze, mips, riscvのイメージには, 浮動小数点演算方式, エンディアン, ビット
数などの違いにより, 複数のコンパイラが含まれています。

### コンテナイメージ取得方法

イメージファイル名は, crosstool-for-hos-CPU名:latest となっています。
CPU名は, `対応CPU`の節に記載したCPU名を指定してください。

例えば, riscv環境のコンテナイメージの場合は, `crosstool-for-hos-riscv:latest`
になります。

以下のコマンドを実行して, コンパイル環境のコンテナイメージを取得します。

```shell
docker pull ghcr.io/takeharukato/crosstool-for-hos-CPU名:latest
```

実行例: RISC-V開発環境のコンテナイメージを取得する

```shell
$ docker pull ghcr.io/takeharukato/crosstool-for-hos-riscv:latest
$
```

以降の節では, RISC-V開発環境のコンテナイメージを使用する場合の例を元に
説明します。

### コンテナイメージの確認方法

ダウンロードしたコンテナイメージを確認する場合は,

```shell
docker images
```

を実行します。

実行例は以下の通りです。

```shell
$ docker images
REPOSITORY                                     TAG       IMAGE ID       CREATED          SIZE
ghcr.io/takeharukato/crosstool-for-hos-riscv   latest    831484ca8065   40 minutes ago   4.42GB
```

## コンテナ内のコンパイル環境の利用法

本節では, コンテナ内のシェル環境を使用してコンパイル環境を使用する方法について説明します。

### コンテナ環境への入り方

コンテナ環境に入る際は, `docker`コマンドに`-it`オプションをつけてコンテナを起動(`run`コマンドを実行)します。例えば, 64bit RISC-V環境の場合, 以下のコマンドを実行することでコンテナに入ることができます。

```shell
docker run -it ghcr.io/takeharukato/crosstool-for-hos-riscv:latest
```

### ホスト環境のディレクトリへのアクセス方法

ホストの作業ディレクトリをマウントし, ホストとファイルを共有する場合は, 以下を実行します。

以下のコマンド例では, `-v
/etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro`を指定することで, ホストLinuxのアカウントとユーザID, グループIDを一致させるようにしてい
ます。コンテナ内でのアクセス権の設定方法は, ホスト環境によって異なりますので, 使用するホストに合わせて適切に設定してください。

参考:

- [dockerでvolumeをマウントしたときのファイルのowner問題](https://qiita.com/yohm/items/047b2e68d008ebb0f001)
- [Docker for Windowsでマウントする](https://qiita.com/kikako/items/7b6301a140cf37a5b7ac)

```shell
docker run -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -v ホストのディレクトリ:コンテナ内からアクセスする際のディレクトリ -it ghcr.io/takeharukato/crosstool-for-hos-riscv:latest
```

以下の例では, ホストのホームディレクトリ直下の`hos/share` (`${HOME}/hos/share`)ディレクトリをコンテナから使用できるようにマウントします。

ホストの`${HOME}/hos/share`ディレクトリにHOSのソースコードを配置して置くことで, コンテナ内のクロスコンパイル環境を利用して, `/home/hos/share`配下のソースコードを編集することで, ホスト上の他のディレクトリに影響を与えること無くクロス開発を行うことができます。

実行例:

```:shell
$ docker run -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro
-v ${HOME}/hos/share:/home/hos/share -it ghcr.io/takeharukato/crosstool-for-hos-riscv:latest
```

### シェル用初期化処理スクリプト

コンテナ内クロスコンパイラを用いた作業を行うための初期化スクリプトを`/opt/hos/cross/etc/shell/init`に導入しています。

作業開始時に以下のコマンドにより環境設定を読み込むことで, [Lmod](https://lmod.readthedocs.io/en/latest/)による環境変数定義を行うことができます。Lmodの使用法については, [Lmodを用いたコンパイル環境の切り替え](#lmodを用いたコンパイル環境の切り替え)を参照ください。

|  シェル |  初期化スクリプト | コマンド |
| ---- | ---- | ---- |
| bash | /opt/hos/cross/etc/shell/init/bash | source /opt/hos/cross/etc/shell/init/bash |
| zsh | /opt/hos/cross/etc/shell/init/zsh | source /opt/hos/cross/etc/shell/init/zsh |

### HOS開発者ユーザについて

#### HOS開発者ユーザ`hos`を使用した開発

Hyper Operating System の開発作業に使うように開発者ユーザ`hos`を作ってあります。

コンテナ内に(docker run などで)入った後, `su - hos`を実行することで, `hos`ユーザ権限での作業が可能になります。

ユーザ`hos`のホームディレクトリは, `/home/hos`になっています。
ホスト環境のディレクトリを`/home/hos`配下にマウントすることで, ホスト環境とファイルを共有しながら作業を行うことが可能です(`ホスト環境
のディレクトリへのアクセス方法`参照)。

ユーザ`hos`は, パスワード入力なしに`sudo`コマンドを実行可能なように設定されています。特権ユーザでの作業が必要な場合は, `sudo`コマンドを用いてコマンドを実行してください。

#### `hos`ユーザの.bashrcについて

hosユーザの`.bashrc`に開発用のシェル初期化スクリプトの読み込み処理を追加しています。

`/home/hos/.bashrc`をsourceコマンドで読込むことで, クロスコンパイラを使用するためのEnvironment Modulesファイルが利用できるようになります。

なお, 前述の手順で, `su - hos`を実行すると, `/home/hos/.bashrc`が自動的に読み込まれます。

#### Lmodを用いたコンパイル環境の切り替え

hosユーザの`.bashrc`から読み込まれる開発用のシェル初期化スクリプト中で, Lmodの初期化処理が行われます。

`/opt/hos/cross/lmod/modules`配下にクロスコンパイラを利用するためのLmodのモジュールが格納されており, これらのモジュールを`module load`コマンドによりロードすることでクロスコンパイル用の環境変数が設定されます。

環境変数の設定を解除する場合は, `module unload`コマンドを実行します。

##### モジュールによって設定される環境変数

`/opt/hos/cross/lmod/modules`配下のモジュールによって, 以下の環境変数が設定されます。

- `PATH` クロスコンパイラへのパスが追加されます

- `QEMU` QEmuのシステムシミュレータへのコマンド名が設定されます。

- `CROSS_COMPILE` クロスコンパイラのプレフィクス名が設定されます。 Linuxでのクロスコンパイラのプレフィクス名指定法に合わせた環境変数です。
- `GCC_ARCH`      クロスコンパイラのプレフィクス名が設定されます。 HOSのMakefile中での設定値をオーバライドするための設定です。設定値は, `CROSS_COMPILE`と同じです。
- `GDB_COMMAND` クロスgdbのコマンド名が設定されます。

実行例:
コンテナ上で 以下の作業を行い, クロスコンパイル用の環境変数が設定されることを確認する例です。

1. ホスト上で`docker run`コマンドを実行し, コンテナに入ります。
   実行コマンド: `docker run -it ghcr.io/takeharukato/crosstool-for-hos-riscv`
2. シェルの初期化スクリプトをロードし, Lmodを使用可能にします。
   ユーザ`hos`の場合は, 以下でユーザ`hos`に実行ユーザ切り替え時に自動的に初期化スクリプトが読み込まれますが, より汎用的な手順として, 初期化スクリプトを明示的に読み込むようにしています。
   実行コマンド: `source /opt/hos/cross/etc/shell/init/bash`
3. 特権ユーザでの作業をさけるため, ユーザ`hos`に切り替えます。
   実行コマンド: `su - hos`
4. 利用可能なモジュールの一覧を表示します。
   実行コマンド: `module avail`
5. 32bit RISC-V用のモジュールを読み込みます。
   実行コマンド: `module load RISCV32-UNKNOWN-ELF-GCC`
6. モジュールによって設定される環境変数を確認します。
   実行コマンド: `printenv PATH`, `printenv QEMU`, `printenv
   CROSS_COMPILE`, `printenv GCC_ARCH`, `printenv GDB_COMMAND`
7. 32bit RISC-V用のモジュールの読込みを解除します。
   実行コマンド: `module unload RISCV32-UNKNOWN-ELF-GCC`
8. 64bit RISC-V用のモジュールを読み込みます。
   実行コマンド: `module load RISCV64-UNKNOWN-ELF-GCC`
9. モジュールによって設定される環境変数を確認します。
   実行コマンド: `printenv PATH`, `printenv QEMU`, `printenv
   CROSS_COMPILE`, `printenv GCC_ARCH`, `printenv GDB_COMMAND`
10. 64bit RISC-V用のモジュールの読込みを解除します。
   実行コマンド: `module unload RISCV64-UNKNOWN-ELF-GCC`

```shell
$ docker run -it ghcr.io/takeharukato/crosstool-for-hos-riscv
root@b728864e1500:/# source /opt/hos/cross/etc/shell/init/bash
root@b728864e1500:/# su - hos
hos@c379e39513d0:~$ module avail

---------------------------- /usr/share/lmod/lmod/modulefiles
----------------------------
Core/lmod/6.6    Core/settarg/6.6

------------------------------ /opt/hos/cross/lmod/modules
-------------------------------
RISCV32-UNKNOWN-ELF-GCC    RISCV64-UNKNOWN-ELF-GCC

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules
matching any of the
"keys".

hos@c379e39513d0:~$ module load RISCV32-UNKNOWN-ELF-GCC
hos@c379e39513d0:~$ printenv PATH
/opt/hos/cross/riscv32/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/hos@c379e39513d0:~$ printenv QEMU
qemu-system-riscv32
hos@c379e39513d0:~$ printenv CROSS_COMPILE
riscv32-unknown-elf-
hos@c379e39513d0:~$ printenv GCC_ARCH
riscv32-unknown-elf-
hos@c379e39513d0:~$ printenv GDB_COMMAND
riscv32-unknown-elf-gdb
usr/games:/usr/local/games:/snap/bin
hos@c379e39513d0:~$ module unload RISCV32-UNKNOWN-ELF-GCC
hos@c379e39513d0:~$ module load RISCV64-UNKNOWN-ELF-GCC
hos@c379e39513d0:~$ printenv PATH
/opt/hos/cross/riscv64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
hos@c379e39513d0:~$ printenv QEMU
qemu-system-riscv64
hos@c379e39513d0:~$ printenv CROSS_COMPILE
riscv64-unknown-elf-
hos@c379e39513d0:~$ printenv GCC_ARCH
riscv64-unknown-elf-
hos@c379e39513d0:~$ printenv GDB_COMMAND
riscv64-unknown-elf-gdb
hos@c379e39513d0:~$ module unload RISCV64-UNKNOWN-ELF-GCC
hos@c379e39513d0:~$
```

## Visual Studio Codeを用いた開発環境の構築・利用方法

Visual Studio Codeを用いたコンテナ開発(`devcontainer`開発)のための各種設定ファイルを, コンテナ内の各CPUのクロスコンパイラのインストールディレクトリ中の`vscode`ディレクトリ内に格納しています。

クロスコンパイラのインストールディレクトリ中の`vscode` ディレクトリ内
には, 対象CPUの各ボード用の設定ファイルを格納したサブディレクトリが格
納されています。
サブディレクトリ`common`は, ボードに非依存な設定ファイルです。

ホスト上で, 以下の手順を実施することで, Hyper Operating System用の開発環境をセットアップすることができます。
`
また, 本リポジトリの`vscode/settings/`ディレクトリ内に`hos-v4a`のサンプルプログラムをコンパイルするための設定ファイルが格納されています。
本リポジトリをクローンし, 対象ボード用のワークスペースファイルを`VSCode`から開くことでコンパイル環境を用意することができます。

### Gitの設定

HOSのソースコードの改行コードとWindowsの標準改行コード間での改行コード変換を抑止するために以下のコマンドをPower Shellから入力します。

```Powershell
 git config --global core.autoCRLF false
```

### Visual Studio Code環境のセットアップ

Docker環境, Visual Studio Code環境をセットアップし, Visual Studio Codeのコンテナ開発環境を構築します。

- __Docker環境の導入__[Docker Desktop](https://www.docker.com/products/docker-desktop/), または, [Rancher Desktop](https://rancherdesktop.io/)などを導入します。`Rancher Desktop`を導入する場合, コンテナランタイムは`dockerd`を選択します。

- __Visual Studio Codeの導入__

  - [Visual Studio Codeの公式サイト](https://code.visualstudio.com/)からVisual Studio Codeを導入します。

  - `VSCode`の拡張機能メニューから[Visual Studio Code Remote Development Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)を導入します。

- __OpenSSH for Windowsの導入__
  以下のサイトなどを参考に, `OpenSSH for Windows`を用いて, ssh-agentによる公開鍵認証を行える環境を構築し, `VSCode`から`GitHub`へのSSH接続を行えるようにします。

  - [OpenSSH for Windows の使用方法](https://qiita.com/akiakishitai/items/9e661a126b9c6ae24a56)
  - [Windows 10 で SSH Agent を使用する](https://scientre.hateblo.jp/entry/2021/06/17/windows-ssh-add)

- __`GitHub Repositories`拡張機能の導入__
    `VSCode`の`拡張機能`ボタンから[GitHub Repositories](https://marketplace.visualstudio.com/items?itemName=GitHub.remotehub)を導入します。

### コンテナイメージを取得

  コンテナイメージをホストにダウンロードします。例えば, 64bit RISC-V用のコンテナイメージを取得する場合は, 以下のコマンドを入力します。

  ```shell
  docker pull ghcr.io/takeharukato/crosstool-for-hos-riscv64:latest
  ```

### コンテナの起動

 ホスト上にダウンロードしたコンテナイメージを元にコンテナを起動します。コンテナからのファイルコピー時にコンテナの名前が必要となるため, コンテナ名をつけて, コンテナを起動します。

 例えば, 64bit RISC-V用のコンテナを`hos`という名前で, 対話型で起動する場合は, 以下のコマンドを入力します。

```shell
docker run --name hos -it ghcr.io/takeharukato/crosstool-for-hos-riscv64:latest
```

### コンテナの停止

[コンテナの起動](#コンテナの起動)の節で, 起動したコンテナを一時停止し, コンテナからのファイルのコピー中にファイルが更新されないようにします。
例えば, `hos`という名前のコンテナを停止する場合は, 以下のコマンドを入力します。

```shell
docker stop hos
```

### コンテナ内の設定ファイルをホストにコピー

コンテナ内の設定ファイルをホストにコピーします。
コピー先のディレクトリがVScodeのワークスペースディレクトリになります。

例えば, 64bit RISC-V用のボード非依存の設定ファイルを使用する場合は,
以下のコマンドをホストから実行し, コンテナ内の設定ファイルをホスト上のカレントディレクトリ(ワークスペースディレクトリ)にコピーします。

```shell
docker cp hos:/opt/hos/cross/riscv64/vscode/common .
```

### コンテナの削除

[コンテナの起動](#コンテナの起動)の節で起動したコンテナを削除します。例えば, `hos`という名前のコンテナを削除する場合は, 以下のコマンドを実行します。

```shell
docker rm hos
```

### ワークスペースファイルのオープン

ホスト上のワークスペースファイル(hos-riscv64.code-workspace)を`VScode`でローカルファイルとして開きます。

### `_vscode/launch.json`, `_vscode/tasks.json`の修正

`launch.json`, `tasks.json`の以下の部分を環境に合わせて修正します。

- `__HOS_USER_PROGRAM_FILE__`をデバッグ情報を含んだELFファイルのファイル名を指定します(例:sampledbg.elf)。

- `__HOS_USER_PROGRAM_DIR__` ユーザプログラムを構築する際のカレントディレクトリを`ワークスペースからの相対パス`で指定します。例えば, ワークスペースディレクトリの直下に`hos-v4a`という名前で, HOSのリポジトリをクローンしており, リポジトリ内の`sample/riscv/virt/gcc`ディレクトリ内で`make`コマンドを実行することでバイナリを生成する場合は,`__HOS_USER_PROGRAM_DIR__`を`hos-v4a/sample/riscv/virt/gcc`に書き換えます。

### ディレクトリ名の変更

`_devcontainer`ディレクトリを`.devcontainer`にリネームします

`_vscode`ディレクトリを`.vscode`にリネームします。

### ワークスペースファイルの再オープン

`表示`メニューの`コマンドパレット`から`Remote-Container:
Rebuild and Reopen in Container`を選択し, ワークスペースファイル(hos-riscv64.code-workspace)をコンテナ内で開きます。

### HOSソースリポジトリの追加

HOSのソースリポジトリをコンテナ内のユーザ`hos`のホームディレクトリにクローンします。 `VScode`から`Git クローン`コマンドを実行し, `Git Hub`からソースリポジトリをクローンします。`表示`メニューのコマンドパレットから`Git クローン(Git: Clone)`を選択し, リポジトリをクローンします。

### Visual Studio Code環境のセットアップ作業例

64bit RISC-V用のクロス開発をVisual Studio Codeで実施するための設定作業例を以下に示します。

```:Powershell
PS c:\Users\hosWindows\vscodeEnv\riscv> docker pull ghcr.io/takeharukato/crosstool-for-hos-riscv:latest
latest: Pulling from takeharukato/crosstool-for-hos-riscv
4d32b49e2995: Already exists
0420764cdf09: Pull complete
5aea9de6d6e4: Pull complete
f9dd3f0b41c3: Pull complete
815fd42d14b4: Pull complete
e2b052590867: Pull complete
1cfdd8e289b4: Pull complete
eafc677175fa: Pull complete
005ccbbf12ff: Pull complete
bc9e8f75ec27: Pull complete
4c2f34a83667: Pull complete
Digest: sha256:ddaf68e6b7074076757b4683bdfdb5b2e9a277c1623b3f94ce8f41fe007c4985
Status: Downloaded newer image for ghcr.io/takeharukato/crosstool-for-hos-riscv:latest
ghcr.io/takeharukato/crosstool-for-hos-riscv:latest
PS c:\Users\hosWindows\vscodeEnv\riscv> docker run  --name hos ghcr.io/takeharukato/crosstool-for-hos-riscv:latest
PS c:\Users\hosWindows\vscodeEnv\riscv> docker stop hos
hos
PS c:\Users\hosWindows\vscodeEnv\riscv> docker cp hos:/opt/hos/cross/riscv64/vscode workspace
PS c:\Users\hosWindows\vscodeEnv\riscv> docker rm hos
hos
PS c:\Users\hosWindows\vscodeEnv\riscv> dir


    ディレクトリ: c:\Users\hosWindows\vscodeEnv\riscv


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        2022/03/20     16:25                workspace
c:\Users\hosWindows\vscodeEnv\riscv>
```

### launch.json/tasks.jsonの修正例

例として, 64bit RISC-V用のHOSのサンプルプログラムを構築するように`launch.json`, `tasks.json`を設定する場合の変更点を示します。

#### .vscode/launch.jsonの修正点

- キー`"program"` の値をデバッグ情報付きのELFファイルである`sampledbg.elf`に設定
- キー`"cwd"` の値を上記`"program"`に設定したファイルのディレクトリ(デバッガ起動時のディレクトリ)である`/home/hos/hos-v4a/sample/riscv/virt/gcc`に設定

修正内容のdiffは以下のようになります。

 ```launch.json修正差分
--- launch.json.orig    2022-03-20 16:25:35.000000000 +0900
+++ launch.json 2022-03-20 17:14:09.302507600 +0900
@@ -9,11 +9,11 @@
             "name": "(gdb) 起動",
             "type": "cppdbg",
             "request": "launch",
-            "program": "__HOS_USER_PROGRAM_FILE__",
+            "program": "sampledbg.elf",
             "args": [],
             "stopAtEntry": false,
             "stopAtConnect": false,
-            "cwd": "/home/hos/__HOS_USER_PROGRAM_DIR__",
+            "cwd": "/home/hos/hos-v4a/sample/riscv/virt/gcc",
             "env": [{"PATH":"/opt/hos/cross/riscv64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                 "CROSS_COMPILE":"riscv64-unknown-elf-",
                 "GCC_ARCH":"riscv64-unknown-elf-",
```

#### .vscode/tasks.jsonの修正点

- キー`"cwd"` の値をデバッガ起動時のディレクトリである`/home/hos/hos-v4a/sample/riscv/virt/gcc`に設定

修正内容のdiffは以下のようになります。

```tasks.jsonの修正差分
--- tasks.json.orig     2022-03-20 16:25:35.000000000 +0900
+++ tasks.json  2022-03-20 17:22:33.374326800 +0900
@@ -9,8 +9,8 @@
               "GDB_COMMAND":"riscv64-unknown-elf-gdb",
               "QEMU":"qemu-system-riscv64",
               "QEMU_OPTS":"-bios none -machine virt -m 32M -serial mon:stdio -nographic -kernel sampledbg.elf",
-       "cwd": "/home/hos/__HOS_USER_PROGRAM_DIR__"
+       "cwd": "/home/hos/hos-v4a/sample/riscv/virt/gcc"
     },
     "tasks": [
         {
```

### VSCodeのターミナル使用時の留意事項

VSCodeのターミナルを起動すると, 開発ユーザ`hos`としてシェルが起動されます。
開発ユーザ`hos`での各種操作については, [HOS開発者ユーザ`hos`を使用した開発](#hos開発者ユーザhosを使用した開発)を参照ください。

### VSCodeを用いたコンパイル・デバッグ

プログラム構築用に以下のタスクを定義しています。
`コマンドパレット`から`タスク: タスクの実行`(`Tasks: Run Task`)を選択
することでコンパイル作業を行うことができます。

- `Build` デバッグオプションなしでバイナリを生成します
- `DebugBuild` デバッグオプション付きでバイナリを生成します
- `Clean`  ユーザプログラムのオブジェクトファイルを削除します。
- `MostlyClean` カーネルを含めてオブジェクトファイルを削除します。
- `CleanBuild` カーネルを含めてオブジェクトファイルを削除してから, デバッグオプションなしでバイナリを生成します
- `CleanDebugBuild` カーネルを含めてオブジェクトファイルを削除してから, デバッグオプション付きでバイナリを生成します
- `LaunchQEmu` QEmuのシステムシミュレータを使用してHOSを起動します(一部ターゲットのみ)。

QEmuのシステムシミュレータとクロスのgdbを用いたデバッグを行うための設定ファイル(launch.json)を用意しています。上記の`LaunchQEmu`タスクを実行してしばらく待つと, `ポート1234番のサービスが利用可能`になった旨のダイアログがでます。その後, `実行`メニューから`デバッグの開始`を選ぶことで`VSCode`を用いたプログラムのデバッグを行うことが可能です。

## 開発者向け情報

### コンテナイメージの自動登録について

GitHub Actionsを使用してコンテナイメージの生成とGitHub Container Registryへの登録を行っています。

forkしたリポジトリで実行する場合, 以下の事前準備が必要です。

1. GitHubの右上のメニューからSettingsを選択します
2. 左側のメニュー内のDeveloper settingsを選択します
3. Personal Access Tokensの項目をクリックします
4. 右上のGenerate new tokenボタンを押します
5. チェックボックスでwrite packages/read packagesだけを選択します
6. Generate tokenボタンを押します
7. 発行されたPATをテキストファイルに保存します
8. 本リポジトリのSettingsを開きます
9. 左側のSecretsメニューにあるActionsをクリックします
10. 右上のNew repository secretをクリックします
11. Secretの作成画面で, NameをCR_PAT(本ファイル内で参照している名前)に設定し,Valueに, 上記で獲得したPATを貼り付けてAdd secretをクリックします.

参考サイト: [Github Actionsを使ってDocker ImageをGitHub Container RegistryにPushする](https://uzimihsr.github.io/post/2020-10-11-github-action-publish-docker-image-ghcr/)

### コンテナイメージの公開

登録されたコンテナイメージはprivateに設定されます。
以下の手順を実施してコンテナイメージをpublicに設定します。

1. GitHubホーム画面上部の`Packages`ボタンを押します。
2. イメージファイル名の一覧内から公開するイメージをクリックします。
3. コンテナイメージ情報画面右の`Package Setting`ボタンを押します。
4. コンテナイメージの`Package Setting`画面下部の`Danger zone`中にある`Change visibility`ボタンを押します。
5. `Public`を選択し, Confirmテキストボックス内にコンテナ名を入力後, `I
   understand the consequences, change package visibility.`ボタンを押します。

### ファイル構成

- README.md 本ファイルです
- Makefile コンテナイメージを作成するためのDockerfileからGitHub Actionsでコンテナイメージを作成する際に使用するDockerfileのテンプレートを生成するMakefileです。
- docker/Dockerfile コンテナイメージを作成するためのDockerfileです。
- docker/scripts/mkcross-elf.sh クロスコンパイル環境を構築するためのスクリプトです。
- docker/vscode Visual Studio Code用の設定ファイルのテンプレートを格納したディレクトリです。
- .github/workflows/push_container_image.yml コンテナイメージの作成とGitHub Container Registryへのイメージ登録までを行うGitHub Actions定義です。

### Makefileについて

以下のMakefile ターゲットが定義されています:

- `build`  ローカル環境のDockerを使用して, コンテナイメージを作成します。
- `run`    ローカル環境で作成したコンテナイメージに入ります。
- `clean-images` ローカル環境のコンテナイメージを削除します。
- `build-each` 各CPU向けのコンテナイメージを作成します。
- `build-and-push-each` 各CPU向けのコンテナイメージを作成し, GitHub Container Registryに登録します(パーソナルトークンを記載したregistry/ghcr.txtと環境変数`GITHUB_USER`にパーソナルトークンに対応したGitHubアカウント名を設定する必要があります)
- `release`  コンテナ内でコンパイラを作成するためのDockerfileと`VSCode`の設定ファイルを生成します。

### スクリプトの修正

#### コンパイラ作成対象のCPUを絞る場合

mkcross-elf.shの`TARGET_CPUS`変数に対象CPUを空白で区切って記述します。

記述例: i386とriscv32だけを構築する場合

```shell
TARGET_CPUS="i386 riscv32"
```

#### ツールチェインの定義

bash連想配列によってツールチェインの各アーカイブの展開時にできる
ディレクトリ名, アーカイブファイル名などを定義します。

#### tool_names

ツールチェインの種別からツールチェインの版数を取り出すための連想配列で
す。 アーカイブの展開時にできるディレクトリ名を指定します

キーとして,  `binutils`, `gcc`, `newlib`, `gdb`, `qemu`を指定すると
CPU間で共通で使用するツールチェインの版数情報を設定できます。

`TARGET_CPUSに記述したCPU名-ツールチェイン種別`をキーに設定すると
特定のCPUについて使用するツールチェインの版数を変更することができます。

記述例: CPU間で共通で使用するbinutilsの版数をbinutils-2.37に設定する

```shell
    ["binutils"]="binutils-2.37"
```

記述例: h8300で使用するbinutilsの版数をbinutils-2.24に設定する

```shell
    ["h8300-binutils"]="binutils-2.24"
```

#### tool_archives

tool_namesで指定したツールチェインの版数をキーとして,
対象のツールチェインのアーカイブのファイル名を取り出す
為の連想配列です。

リダイレクトなどにより, URLからアーカイブ名を取り出せないケースを想定
して本変数を導入しています。

記述例: binutils-2.37のアーカイブ名をbinutils-2.37.tar.gzに設定する

```shell
    ["binutils-2.37"]="binutils-2.37.tar.gz"
```

#### tool_urls

tool_namesで指定したツールチェインの版数をキーとして,
対象のツールチェインのアーカイブをダウンロードするURLを取り出す
為の連想配列です。

記述例: binutils-2.37のダウンロードURLを
<https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz>
に設定する

```shell
    ["binutils-2.37"]="https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz"
```

#### qemu_targets

TARGET_CPUSに記述したCPU名をキーに, QEmuのターゲットリストに指定する値
を取り出すための連想配列です。
ハードウエアFPUを使用するArmのコンパイラなどクロスコンパイラの種別を表
すCPU名とQEmuのCPU名とを対応づけるために導入しています。

記述例: ハードウエアFPUを使用するArm(armhw)向けに
arm-softmmu,arm-linux-user
ターゲットを構築する場合

```shell
["armhw"]="arm-softmmu,arm-linux-user"
```

#### qemu_cpus

TARGET\_CPUSに記述したCPU名をキーに, QEmuのcpu名を取り出すための連想配列です。
QEmuのシステムシミュレータのコマンド名をEnvironment Modules/Lmodの環境変数に設定するために使用しています。
テストの自動化を行うために本変数を導入しています。
将来的には, qemu\_targetsを廃止し, qemu_cpusから得たCPU名からQEmuターゲットを指定するようにする予定です。

記述例: ハードウエアFPUを使用するArm(armhw)のQEmuのCPU名をarmに設定する場合は以下のように記載します。

```shell
["armhw"]="arm"
```

#### qemu_opts

TARGET\_CPUSに記述したCPU名をキーに, QEmuの起動オプションを取り出すための連想配列です。

記述例: riscv64用のQEmu起動オプションを`-bios none -machine virt -m 32M -serial mon:stdio -nographic -kernel sampledbg.elf`に設定する場合は以下のように記載します。

```shell
["riscv64"]="-bios none -machine virt -m 32M -serial mon:stdio -nographic -kernel sampledbg.elf"
```

#### cpu_target_names

gccクロスコンパイラ作成時に指定するターゲット指定用tripletを定義するた
めの連想配列です。

TARGET_CPUSに記述した`CPU名-elf`をキーに, ターゲット指定用tripletを取
り出します。

ハードウエアFPU版Armコンパイラなどの`CPU名-unknown-elf`形式以外の
tripletを指定するために導入しています。

記述例: ハードウエアFPUを使用するArm(armhw)のターゲット指定用tripletを
arm-eabihfに設定します。

```shell
    ["armhw-elf"]="arm-eabihf"
```

#### cpu_target_cflags

gccのランタイムやlibcを構築する際のCコンパイラフラグ(cflags)を指定するための連想配列です。

TARGET_CPUSに記述した`CPU名-elf`をキーに, cflagsの設定値を取り出します。

H8/300Hなどランタイムライブラリコンパイル時にオプションとHOSのコンパイルオプションとの不一致によるバイナリ生成失敗を回避するために導入しています。

記述例: H8/300用のコードを生成するようにclagsに`-mh`を設定します。

```shell
    ["h8300-elf"]="-mh"
```

## 付録: EmacsのGrand Unified Debugger modeでデバッグするための設定

環境変数`GDB_COMMAND`に設定されているクロスのgdbを用いて, Emacsの
Grand Unified Debugger modeでデバッグする際のデバッガ名を設定するため
の`.emacs`を以下に記載します。

```emacs-lisp
;;
;; Grand Unified Debugger mode
;;
(load-library "gud") ;;
(setq cross-gdb-command-name (if (not (setq cross-gdb-env (getenv "GDB_COMMAND"))) "gdb" cross-gdb-env)) ;;コマンド
(setq gdb-args-list (cdr (if (boundp 'gud-gdb-command-name) (split-string gud-gdb-command-name)
                           (if (boundp 'gud-gud-gdb-command-name)
                               (split-string gud-gud-gdb-command-name))))) ;; 引数のリスト
(if (boundp 'gud-gdb-command-name)
    (custom-set-variables '(gud-gdb-command-name (concat cross-gdb-command-name " --fullname")))
  (custom-set-variables '(gud-gud-gdb-command-name
                          (concat cross-gdb-command-name " --fullname"))) )
```
