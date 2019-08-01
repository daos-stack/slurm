NAME    := slurm
SRC_EXT := bz2

URL_BASE :=  https://download.schedmd.com/$(NAME)
SOURCE   = $(URL_BASE)/$(NAME)-$(VERSION).tar.$(SRC_EXT)
ID := $(shell . /etc/os-release; echo $$ID)
# Suse has to be different, only care about CentOS or SUSE
ifneq ($(ID),centos)
DL_VERSION = $(VERSION)-2
SOURCE   = $(URL_BASE)/$(NAME)-$(DL_VERSION).tar.$(SRC_EXT)
endif

RPM_BUILD_OPTIONS := --with=mysql

include Makefile_packaging.mk

