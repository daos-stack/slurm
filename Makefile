NAME      := slurm
SRC_EXT   := gz
TEST_PACKAGES := $(NAME)
# release package tarballs are of the format: slurm-21-08-1-1.tar.gz
# so convert . to - and ~ to - from $(VERSION)
DL_VERSION     = $(subst ~,-,$(subst .,-,$(VERSION)))
include packaging/Makefile_packaging.mk
