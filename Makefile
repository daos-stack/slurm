NAME    := slurm
SRC_EXT := bz2
VERSION := 18.08.8
URL_BASE :=  https://download.schedmd.com/$(NAME)
SOURCE   = $(URL_BASE)/$(NAME)-$(VERSION).tar.$(SRC_EXT)

MOCK_OPTIONS := --with=mysql

spec: $(NAME).spec Makefile
	rm -rf _topdir
	rm -f  $(NAME)-$(VERSION).tar.$(SRC_EXT)

.PHONY: spec

include Makefile_packaging.mk

