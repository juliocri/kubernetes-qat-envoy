def qat_nodes = ["dh895xcc", "c6xx"]

def parallelE2EStagesMap = qat_nodes.collectEntries {
  ["${it}" : generateE2EStage(it)]
}

def parallelPerfStagesMap = qat_nodes.collectEntries {
  ["${it}" : generatePerfStage(it)]
}

def parallelCleanStagesMap = qat_nodes.collectEntries {
  ["${it}" : generateCleanStage(it)]
}

def generateE2EStage(job) {
  return {
    node("${job}") {
     stage("${job}") {
        sh 'git submodule update --init --recursive'
        sh 'mkdir -p ./${job}/results/tests'
        sh './e2e/tests/cp1/run.sh'
        sh './e2e/tests/cp2/run.sh'
        sh './e2e/tests/cp3/run.sh'
        sh './e2e/tests/cp5/run.sh'
        sh './e2e/tests/lbd1/run.sh'
        sh './e2e/tests/lbd2/run.sh'
        sh './e2e/tests/lbd3/run.sh'
        sh './e2e/tests/lbd4/run.sh'
        withCredentials([sshUserPrivateKey(credentialsId: "K6-Runner", keyFileVariable: 'SSH_KEY')]) {
          sh './e2e/tests/lbd5/run.sh'
        }
      }
    }
  }
}

def generatePerfStage(job) {
  return {
    node("${job}") {
     stage("${job}") {
        withCredentials([sshUserPrivateKey(credentialsId: "K6-Runner", keyFileVariable: 'SSH_KEY')]) {
          sh './e2e/tests/handshake1/run.sh'
          sh './e2e/tests/loopback1/run.sh'
        }
        sh './e2e/tests/k8s1/run.sh'
        stash name: "${job}", includes: "${job}/**/*"
      }
    }
  }
}

def generateCleanStage(job) {
  return {
    node("${job}") {
     stage("${job}") {
        sh './e2e/qat/cluster-clean.sh'
      }
    }
  }
}

pipeline {
  agent {
    label "master"
  }
  triggers {
    cron('0 0 * * *')
  }
  environment {
    DOCKER_QAT_REGISTRY="cloud-native-image-registry.westus.cloudapp.azure.com"
    TESTING_IMAGE_TAG="${env.BUILD_TAG}-rejected"
  }
  stages {
    stage('Build') {
      agent {
        label "xenial-intel-device-plugins"
      }
      stages {
        stage('Make images') {
          steps {
            sh 'git submodule update --init --recursive'
            sh 'make -f ./e2e/Makefile images'
          }
        }
      }
      post {
        success {
          withDockerRegistry([ credentialsId: "57e4a8b2-ccf9-4da1-a787-76dd1aac8fd1", url: "https://${REG}" ]) {
            sh './e2e/docker/push-internal-images.sh'
          }
        }
      }
    }
    stage ("e2e") {
      steps {
        script {
          parallel parallelE2EStagesMap
        }
      }
    }
    stage('Performance test') {
      steps {
        script {
          parallel parallelPerfStagesMap
        }
      }
    }
    stage("Results") {
      agent {
        label "logs"
      }
      stages {
        stage("Publish results") {
          steps {
            sh "mkdir -p $LOG_DIRECTORY"
            script {
              for(item in qat_nodes) {
                unstash "${item}"
                sh "mv ./${item} $LOG_DIRECTORY"
              }
            }
          }
        }
      }
      post {
        always {
          deleteDir()
        }
      }
    }
  }
  post {
    always {
      script {
        parallel parallelCleanStagesMap
      }
    }
    //success {
    //  emailext body: 'Jenkins log: ${JENKINS_BLUE_OCEAN_URL_QAT}, Results: ${LOG_URL}, Dashboard: ${QAT_DASHBOARD}', subject: 'SUCCESS: kubernetes-qat-envoy #${BUILD_NUMBER}', to: '$QAT_ENVOY_MAILING_LIST'
    //}
    //failure {
    //  emailext body: 'Jenkins log: ${JENKINS_BLUE_OCEAN_URL_QAT}', subject: 'FAILURE: kubernetes-qat-envoy #${BUILD_NUMBER}', to: '$QAT_ENVOY_MAILING_LIST'
    //}
  }
}
