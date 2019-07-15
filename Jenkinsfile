pipeline {
  agent none
  stages {
    stage('Build') {
      agent {
        label "builder"
      }
      stages {
        stage('Pre-steps') {
          steps {
            script {
              currentBuild.description = "TESTING PR#${QAT_PR_ID}"
            }
            retry(count: 3) {
              sh 'true | git remote add upstream https://github.com/intel/kubernetes-qat-envoy'
              sh 'git fetch upstream pull/${QAT_PR_ID}/head:test_pr -f'
              sh 'git rebase test_pr'
              sh 'git submodule update --init --recursive'
              sh 'docker system prune -a -f'
            }
          }
        }
        stage('Docker builds') {
          parallel {
            stage ('Debian Envoy+OpenSSL+QAT') {
              steps {
                retry(count: 3) {
                  sh 'make -f ./e2e/Makefile envoy-qat'
                }
              }
            }
            stage ('Clearlinux Envoy+OpenSSL+QAT') {
              steps {
                retry(count: 3) {
                  sh 'make -f ./e2e/Makefile envoy-qat-clr'
                }
              }
            }
            stage ('Debian Envoy+BoringSSL+QAT') {
              steps {
                retry(count: 3) {
                  sh 'make -f ./e2e/Makefile envoy-boringssl-qat'
                }
              }
            }
            stage ('Intel-QAT-Plugin') {
              steps {
                retry(count: 3) {
                  sh 'cd ./intel-device-plugins-for-kubernetes && make intel-qat-plugin'
                }
              }
            }
          }
        }
      }
      post {
        success {
          stash name: "intel-device-plugins-for-kubernetes", includes: "intel-device-plugins-for-kubernetes/**/*"
          sh './e2e/docker/push-internal-images.sh'
          deleteDir()
        }
        failure {
          deleteDir()
        }
      }
    }
    stage ("e2e") {
      parallel {
        stage('dh895xcc') {
          agent {
            label "dh895xcc"
          }
          stages {
            stage('Pre-steps') {
              steps {
                unstash 'intel-device-plugins-for-kubernetes'
                withCredentials([sshUserPrivateKey(credentialsId: "K6-Runner", keyFileVariable: 'SSH_KEY')]) {
                  sh './e2e/k6/init-runner.sh'
                }
              }
            }
            stage('CP1') {
              steps {
                sh './e2e/tests/cp1/run.sh'
              }
            }
            stage('CP2') {
              steps {
                sh './e2e/tests/cp2/run.sh'
              }
            }
            stage('CP3') {
              steps {
                sh './e2e/tests/cp3/run.sh'
              }
            }
            stage('CP5') {
              steps {
                sh './e2e/tests/cp5/run.sh'
              }
            }
            stage('LBD1') {
              steps {
                sh './e2e/tests/lbd1/run.sh'
              }
            }
            stage('LBD2') {
              steps {
                sh './e2e/tests/lbd2/run.sh'
              }
            }
            stage('LBD3') {
              steps {
                sh './e2e/tests/lbd3/run.sh'
              }
            }
            stage('LBD4') {
              steps {
                sh './e2e/tests/lbd4/run.sh'
              }
            }
            stage('LBD5') {
              steps {
                withCredentials([sshUserPrivateKey(credentialsId: "K6-Runner", keyFileVariable: 'SSH_KEY')]) {
                  sh './e2e/tests/lbd5/run.sh'
                }
              }
            }
          }
          post {
            always {
              sh './e2e/k8s/clean.sh'
              sh './e2e/docker/clean.sh'
              sh 'sleep 60s'
              deleteDir()
            }
          }
        }
        stage('c6xx') {
          agent {
            label "c6xx"
          }
          stages {
            stage('Pre-steps') {
              steps {
                unstash 'intel-device-plugins-for-kubernetes'
                withCredentials([sshUserPrivateKey(credentialsId: "K6-Runner", keyFileVariable: 'SSH_KEY')]) {
                  sh './e2e/k6/init-runner.sh'
                }
              }
            }
            stage('CP1') {
              steps {
                sh './e2e/tests/cp1/run.sh'
              }
            }
            stage('CP2') {
              steps {
                sh './e2e/tests/cp2/run.sh'
              }
            }
            stage('CP3') {
              steps {
                sh './e2e/tests/cp3/run.sh'
              }
            }
            stage('CP5') {
              steps {
                sh './e2e/tests/cp5/run.sh'
              }
            }
            stage('LBD1') {
              steps {
                sh './e2e/tests/lbd1/run.sh'
              }
            }
            stage('LBD2') {
              steps {
                sh './e2e/tests/lbd2/run.sh'
              }
            }
            stage('LBD3') {
              steps {
                sh './e2e/tests/lbd3/run.sh'
              }
            }
            stage('LBD4') {
              steps {
                sh './e2e/tests/lbd4/run.sh'
              }
            }
            stage('LBD5') {
              steps {
                withCredentials([sshUserPrivateKey(credentialsId: "K6-Runner", keyFileVariable: 'SSH_KEY')]) {
                 sh './e2e/tests/lbd5/run.sh'
                }
              }
            }
          }
          post {
            always {
              sh './e2e/k8s/clean.sh'
              sh './e2e/docker/clean.sh'
              sh 'sleep 60s'
              deleteDir()
            }
          }
        }
      }
    }
  }
  post {
    success {
      emailext body: 'http://k8s-ci.intel.com:9090/blue/organizations/jenkins/kubernetes-qat-envoy/activity', subject: 'SUCCESS: kubernetes-qat-envoy PR#$QAT_PR_ID', to: '$QAT_ENVOY_MAILING_LIST'
    }
    failure {
      emailext body: 'http://k8s-ci.intel.com:9090/blue/organizations/jenkins/kubernetes-qat-envoy/activity', subject: 'FAILURE: kubernetes-qat-envoy PR#$QAT_PR_ID', to: '$QAT_ENVOY_MAILING_LIST'
    }
  }
}
