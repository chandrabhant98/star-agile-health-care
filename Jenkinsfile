pipeline {
  agent any
  tools {
    maven 'MAVEN_HOME'
  }

  stages {
    stage('Checkout Git Repository') {
      steps {
        echo 'Checking out the Git repository...'
        git branch: 'main', url: 'https://github.com/chandrabhant98/star-agile-health-care.git'
      }
    }
  }
}
