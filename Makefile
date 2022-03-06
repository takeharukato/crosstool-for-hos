#
# 開発環境コンテナイメージの作成と登録
# -*- coding:utf-8 mode: gmake-mode -*-
# Copyright (C) 1998-2022 by Project HOS
# http://sourceforge.jp/projects/hos/
#

.PHONY: release build build-each run clean clean-images dist-clean prepare \
	clean-workdir build-and-push-each

#ターゲットCPU
# TARGET_CPUS=sh2 h8300 i386 riscv32 riscv64 mips mipsel microblaze arm armhw
TARGET_CPUS=h8300

IMAGE_NAME=crosstool-for-hos

all: release

define CLEAN_WORKDIR
	if [ -d workdir ]; then \
		rm -fr workdir; \
	fi
endef

define BUILD_IMAGE_ONE
	echo "cpu:$1"
	cat docker/Dockerfile | \
	sed -e \
	"s|# __TARGET_CPU_ENV_LINE__|ENV TARGET_CPUS=\"$1\"|g" | \
	tee workdir/Dockerfile;
	docker build -t "ghcr.io/${GITHUB_USER}/${IMAGE_NAME}-$1:latest" workdir 2>&1 |\
	tee build-$1.log;
endef

define BUILD_AND_PUSH_IMAGE_ONE
	$(call BUILD_IMAGE_ONE,$1)
	if [ -f registry/ghcr.txt ]; then \
		cat registry/ghcr.txt | docker login ghcr.io -u ${GITHUB_USER} --password-stdin; \
		docker push ghcr.io/${GITHUB_USER}/${IMAGE_NAME}-$1:latest; \
		docker logout; \
	fi;
endef



clean-workdir:
	$(call CLEAN_WORKDIR)

prepare: clean-workdir
	mkdir -p workdir/scripts
	cp -a docker/patches workdir
	cp docker/scripts/*.sh workdir/scripts

release:
	cat docker/Dockerfile | \
	sed -e \
	's|# __TARGET_CPU_ENV_LINE__|ENV TARGET_CPUS="__REPLACE_TARGET_CPUS__"|g' | \
	tee templates/Dockerfiles/Dockerfile.tmpl

build: release prepare
	cat docker/Dockerfile | \
	sed -e \
	's|# __TARGET_CPU_ENV_LINE__|ENV TARGET_CPUS="${TARGET_CPUS}"|g' | \
	tee workdir/Dockerfile;\
	docker build -t ${IMAGE_NAME} workdir 2>&1 |tee build.log
	$(call CLEAN_WORKDIR)

build-each: prepare
	$(foreach cpu, ${TARGET_CPUS},$(call BUILD_IMAGE_ONE,${cpu}))
	$(call CLEAN_WORKDIR)


build-and-push-each: prepare
	$(foreach cpu, ${TARGET_CPUS},$(call BUILD_AND_PUSH_IMAGE_ONE,${cpu}))
	$(call CLEAN_WORKDIR)

run:
	docker run -it ${IMAGE_NAME}

clean-images:
	@docker rm -f `docker ps -a -q` || :
	@docker system prune -a -f

clean:
	${RM} *~

dist-clean: clean
	${RM} -f build.log
