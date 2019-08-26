#!/usr/bin/groovy
/* Copyright (C) 2019 Intel Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted for any purpose (including commercial purposes)
 * provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions, and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions, and the following disclaimer in the
 *    documentation and/or materials provided with the distribution.
 *
 * 3. In addition, redistributions of modified forms of the source or binary
 *    code must carry prominent notices stating that the original code was
 *    changed and the date of the change.
 *
 *  4. All publications or advertising materials mentioning features or use of
 *     this software are asked, but not required, to acknowledge that it was
 *     developed by Intel Corporation and credit the contributors.
 *
 * 5. Neither the name of Intel Corporation, nor the name of any Contributor
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
// To use a test branch (i.e. PR) until it lands to master
// I.e. for testing library changes
//@Library(value="pipeline-lib@your_branch") _

pipeline {
    agent none

    stages {
        stage('Cancel Previous Builds') {
            when { changeRequest() }
            steps {
                cancelPreviousBuilds()
            }
        }
        stage('Lint') {
            stages {
                stage('RPM Lint') {
                    agent {
                        dockerfile {
                            filename 'Dockerfile.centos.7'
                            label 'docker_runner'
                            additionalBuildArgs  '--build-arg UID=$(id -u)'
                            args  '--group-add mock --cap-add=SYS_ADMIN --privileged=true'
                        }
                    }
                    steps {
                        // slurm.spec fails lint.
                        sh script: '''cp -f slurm.spec_centos slurm.spec
                                      make rpmlint''',
                           returnStatus: true
                    }
                }
            }
        }
        stage('Build') {
            parallel {
                stage('Build on CentOS 7') {
                    agent {
                        dockerfile {
                            filename 'Dockerfile.centos.7'
                            label 'docker_runner'
                            args '--group-add mock' +
                                 ' --cap-add=SYS_ADMIN' +
                                 ' --privileged=true'
                            additionalBuildArgs '--build-arg UID=$(id -u)'
                        }
                    }
                    steps {
                        sh '''rm -rf artifacts/centos7/
                              mkdir -p artifacts/centos7/
                              cp -f slurm.spec_centos slurm.spec
                              make chrootbuild'''
                    }
                    post {
                        success {
                            sh '''(cd /var/lib/mock/epel-7-x86_64/result/ &&
                                   cp -r . $OLDPWD/artifacts/centos7/)
                                  createrepo artifacts/centos7/'''
                            publishToRepository product: 'slurm',
                                                format: 'yum',
                                                maturity: 'stable',
                                                tech: 'el7',
                                                repo_dir: 'artifacts/centos7/'
                        }
                        unsuccessful {
                            sh '''cp -af _topdir/SRPMS artifacts/centos7/
                                  (cd /var/lib/mock/epel-7-x86_64/result/ &&
                                   cp -r . $OLDPWD/artifacts/centos7/)
                                  (cd /var/lib/mock/epel-7-x86_64/root/builddir/build/BUILD/*/
                                   find . -name configure -printf %h\\\\n | \
                                   while read dir; do
                                       if [ ! -f $dir/config.log ]; then
                                           continue
                                       fi
                                       tdir="$OLDPWD/artifacts/centos7/autoconf-logs/$dir"
                                       mkdir -p $tdir
                                       cp -a $dir/config.log $tdir/
                                   done)'''
                        }
                        cleanup {
                            archiveArtifacts artifacts: 'artifacts/centos7/**'
                        }
                    }
                }
                stage('Build on SLES 12.3') {
                    when { beforeAgent true
                           environment name: 'SLES12_3_DOCKER', value: 'true' }
                    agent {
                        dockerfile {
                            filename 'Dockerfile.sles.12.3'
                            label 'docker_runner'
                            args '--privileged=true'
                            additionalBuildArgs '--build-arg UID=$(id -u)' +
                                ' --build-arg REPOSITORY_URL=' +
                                    env.REPOSITORY_URL + '/' +
                                ' --build-arg GROUP_REPO=/' +
                                    env.DAOS_STACK_SLES_12_3_GROUP_REPO

                        }
                    }
                    steps {
                        sh '''rm -rf artifacts/sles12.3/
                              mkdir -p artifacts/sles12.3/
                              cp -f slurm.spec_sles12 slurm.spec
                              make chrootbuild'''
                    }
                    post {
                        success {
                            sh '''(cd /var/tmp/build-root/home/abuild/rpmbuild/ &&
                                   cp {RPMS/*,SRPMS}/* $OLDPWD/artifacts/sles12.3/)
                                  createrepo artifacts/sles12.3/'''
                            publishToRepository product: 'slurm',
                                                format: 'yum',
                                                maturity: 'stable',
                                                tech: 'sles12.3',
                                                repo_dir: 'artifacts/sles2.3/'
                        }
                        unsuccessful {
                            sh '''(cd /var/tmp/build-root/home/abuild/rpmbuild/BUILD &&
                                   find . -name configure -printf %h\\\\n | \
                                   while read dir; do
                                       if [ ! -f $dir/config.log ]; then
                                           continue
                                       fi
                                       tdir="$OLDPWD/artifacts/sles12.3/autoconf-logs/$dir"
                                       mkdir -p $tdir
                                       cp -a $dir/config.log $tdir/
                                   done)'''
                        }
                        cleanup {
                            archiveArtifacts artifacts: 'artifacts/sles12.3/**'
                        }
                    }
                }
                stage('Build on Leap 42.3') {
                    agent {
                        dockerfile {
                            filename 'Dockerfile.leap.42.3'
                            label 'docker_runner'
                            args '--privileged=true'
                            additionalBuildArgs '--build-arg UID=$(id -u)' +
                                ' --build-arg REPOSITORY_URL=' +
                                    env.REPOSITORY_URL + '/' +
                                ' --build-arg GROUP_REPO=/' +
                                    env.DAOS_STACK_LEAP_42_3_GROUP_REPO
                        }
                    }
                    steps {
                        sh '''rm -rf artifacts/leap42.3/
                              mkdir -p artifacts/leap42.3/
                              cp -f slurm.spec_sles12 slurm.spec
                              make chrootbuild'''
                    }
                    post {
                        success {
                            sh '''(cd /var/tmp/build-root/home/abuild/rpmbuild/ &&
                                   cp {RPMS/*,SRPMS}/* $OLDPWD/artifacts/leap42.3/)
                                  createrepo artifacts/leap42.3/'''
                            publishToRepository product: 'slurm',
                                                format: 'yum',
                                                maturity: 'stable',
                                                tech: 'leap42.3',
                                                repo_dir: 'artifacts/leap42.3/'
                        }
                        unsuccessful {
                            sh '''(cd /var/tmp/build-root/home/abuild/rpmbuild/BUILD &&
                                   find . -name configure -printf %h\\\\n | \
                                   while read dir; do
                                       if [ ! -f $dir/config.log ]; then
                                           continue
                                       fi
                                       tdir="$OLDPWD/artifacts/leap42.3/autoconf-logs/$dir"
                                       mkdir -p $tdir
                                       cp -a $dir/config.log $tdir/
                                   done)'''
                        }
                        cleanup {
                            archiveArtifacts artifacts: 'artifacts/leap42.3/**'
                        }
                    }
                }
            }
        }
    }
}
