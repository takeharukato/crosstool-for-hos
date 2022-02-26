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
