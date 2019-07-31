NAME    := slurm
SRC_EXT := bz2
VERSION := 18.08.8
URL_BASE :=  https://download.schedmd.com/$(NAME)
SOURCE   = $(URL_BASE)/$(NAME)-$(VERSION).tar.$(SRC_EXT)

RPM_BUILD_OPTIONS := --with=mysql

.PHONY: spec

include Makefile_packaging.mk

