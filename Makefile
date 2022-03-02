#
# 開発環境コンテナイメージの作成と登録
# -*- coding:utf-8 mode: gmake-mode -*-
# Copyright (C) 1998-2022 by Project HOS
# http://sourceforge.jp/projects/hos/
#

.PHONY: release build run clean clean-images dist-clean

IMAGE_NAME=crosstool-for-hos

all: release

release:
	cat docker/Dockerfile | \
	sed -e \
	's|# __TARGET_CPU_ENV_LINE__|ENV TARGET_CPUS="__REPLACE_TARGET_CPUS__"|g' | \
	tee templates/Dockerfiles/Dockerfile.tmpl

build: release
	docker build -t ${IMAGE_NAME} docker|tee build.log 2>&1

run:
	docker run -it ${IMAGE_NAME}

clean-images:
	@docker rm -f `docker ps -a -q` || :
	@docker system prune -a -f

clean:
	${RM} *~

dist-clean: clean
	${RM} -f build.log
