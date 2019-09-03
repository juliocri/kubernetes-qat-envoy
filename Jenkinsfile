def qat_nodes = ["dh895xcc", "c6xx"]

def parallelE2EStagesMap = qat_nodes.collectEntries {
  ["${it}" : generateE2EStage(it)]
}

def parallelPerfStagesMap = qat_nodes.collectEntries {
  ["${it}" : generatePerfStage(it)]
}

def generateE2EStage(job) {
  return {
    node("${job}") {
     stage("${job}") {
        checkout scm
        sh './e2e/tests/cp1/run.sh'
        sh './e2e/tests/cp2/run.sh'
        withDockerRegistry([ credentialsId: "57e4a8b2-ccf9-4da1-a787-76dd1aac8fd1", url: "https://${DOCKER_QAT_REGISTRY}" ]) {
          sh './e2e/docker/pull-internal-images.sh'
        }
        sh './e2e/tests/cp3/run.sh'
        sh './e2e/tests/cp5/run.sh'
        sh './e2e/tests/lbd1/run.sh'
        sh './e2e/tests/lbd2/run.sh'
        sh './e2e/tests/lbd3/run.sh'
        sh './e2e/tests/lbd4/run.sh'
      }
    }
  }
}

def generatePerfStage(job) {
  return {
    node("${job}") {
     stage("${job}") {
        sh './e2e/tests/handshake1/run.sh'
        sh './e2e/tests/loopback1/run.sh'
        sh './e2e/tests/k8s1/run.sh'
      }
    }
  }
}

pipeline {
  agent {
    label "master"
  }
  options {
    skipDefaultCheckout()
  }
  environment {
    DOCKER_QAT_REGISTRY="cloud-native-image-registry.westus.cloudapp.azure.com"
    TESTING_IMAGE_TAG="${env.BUILD_TAG}-rejected"
  }
  stages {
    stage("Builds") {
      agent {
        label "kubernetes-qat-envoy"
      }
      stages {
        stage("Make images") {
          steps {
            checkout scm
            sh 'make -f ./e2e/Makefile images'
          }
        }
      }
      post {
        success {
          withDockerRegistry([ credentialsId: "57e4a8b2-ccf9-4da1-a787-76dd1aac8fd1", url: "https://${DOCKER_QAT_REGISTRY}" ]) {
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
          if (env.CHANGE_ID == null) {
            parallel parallelPerfStagesMap
          }
        }
      }
    }
  }
}
