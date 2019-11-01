NAME    := slurm
SRC_EXT := bz2

URL_BASE :=  https://download.schedmd.com/$(NAME)
SOURCE   = $(URL_BASE)/$(NAME)-$(VERSION).tar.$(SRC_EXT)

ifeq ($(findstring epel,$(CHROOT_NAME)),epel)
$(shell cp slurm.spec_centos slurm.spec)
ifeq ($(CHROOT_NAME),epel-8-x86_64)
PATCHES = slurmconfgen_smw_py.patch
PATCHES += testsuite_expect_driveregress_py.patch
PATCHES += testsuite_expect_regression_py.patch
PATCHES += doc_html_shtml2html_py.patch
PATCHES += doc_man_man2html_py.patch
endif
else
# Suse has to be different, only care about CentOS or SUSE
$(shell cp slurm.spec_sles12 slurm.spec)
# backport from leap15.1
DL_VERSION = $(VERSION)-2
SOURCE   = $(URL_BASE)/$(NAME)-$(DL_VERSION).tar.$(SRC_EXT)
PATCHES = slurm-2.4.4-rpath.patch
PATCHES += slurm-2.4.4-init.patch
PATCHES += pam_slurm-Initialize-arrays-and-pass-sizes.patch
PATCHES += split-xdaemon-in-xdaemon_init-and-xdaemon_finish-for.patch
PATCHES += slurmctld-uses-xdaemon_-for-systemd.patch
PATCHES += slurmd-uses-xdaemon_-for-systemd.patch
PATCHES += slurmdbd-uses-xdaemon_-for-systemd.patch
PATCHES += slurmsmwd-uses-xdaemon_-for-systemd.patch
PATCHES += removed-deprecated-xdaemon.patch
PATCHES += slurmctld-rerun-agent_init-when-backup-controller-takes-over.patch
PATCHES += pam_slurm_adopt-avoid-running-outside-of-the-sshd-PA.patch
PATCHES += pam_slurm_adopt-send_user_msg-don-t-copy-undefined-d.patch
PATCHES += pam_slurm_adopt-use-uid-to-determine-whether-root-is.patch
PATCHES += slurm-rpmlintrc
endif

RPM_BUILD_OPTIONS := --with=mysql

OSUSE_REPOS = https://download.opensuse.org/repositories

ifeq ($(DAOS_STACK_SLES_12_GROUP_REPO),)
SLES_12_REPOS += $(OSUSE_REPOS)/science:/HPC:/SLE12SP3_Missing/SLE_12_SP3
endif

include packaging/Makefile_packaging.mk
