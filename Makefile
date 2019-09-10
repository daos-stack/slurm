NAME    := slurm
SRC_EXT := bz2

URL_BASE :=  https://download.schedmd.com/$(NAME)
SOURCE   = $(URL_BASE)/$(NAME)-$(VERSION).tar.$(SRC_EXT)
ID := $(shell . /etc/os-release; echo $$ID)
# Suse has to be different, only care about CentOS or SUSE
ifneq ($(ID),centos)
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
ifneq ($(REPOSITORY_URL),"")
ifneq ($(DAOS_STACK_SLES_12_GROUP_REPO),"")
sle12_REPOS += --repo $(REPOSITORY_URL)$(DAOS_STACK_SLES_12_GROUP_REPO)
endif
ifneq ($(DAOS_STACK_SLES_12_LOCAL_REPO),"")
sle12_REPOS += --repo $(REPOSITORY_URL)${DAOS_STACK_SLES_12_LOCAL_REPO}
endif
ifneq ($(DAOS_STACK_LEAP_42_GROUP_REPO),"")
sl42_REPOS += --repo $(REPOSITORY_URL)$(DAOS_STACK_LEAP_42_GROUP_REPO)
endif
ifneq ($(DAOS_STACK_LEAP_42_LOCAL_REPO),"")
sl42_REPOS += --repo $(REPOSITORY_URL)$(DAOS_STACK_LEAP_42_LOCAL_REPO)
endif
else
ifneq ($(ID),centos)
ADD_REPOS = "munge"
endif
endif

sle12_REPOS += --repo $(OSUSE_REPOS)/science:/HPC:/SLE12SP3_Missing/SLE_12_SP3

include packaging/Makefile_packaging.mk

