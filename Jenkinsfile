pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub_credentials'  // Replace with your Docker Hub credentials ID
        AWS_CREDENTIALS_ID = 'JenkinsIAMuser'             // Replace with your AWS credentials ID
        DOCKER_IMAGE = "chandrabhant98/healthcareapp:1.0" // Update to match the build stage
        WORKING_DIR = "${WORKSPACE}/path/to/terraform"     // Update this to point to the directory with your main.tf
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/chandrabhant98/star-agile-health-care.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building the docker image...'
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernameColonPassword(credentialsId: 'Dockerlogin-user', variable: 'DOCKER_CREDENTIALS')]) {
                        sh '''
                            USERNAME=$(echo $DOCKER_CREDENTIALS | cut -d':' -f1)
                            PASSWORD=$(echo $DOCKER_CREDENTIALS | cut -d':' -f2)
                            echo $PASSWORD | docker login -u $USERNAME --password-stdin
                        '''
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Provision Infrastructure') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: AWS_CREDENTIALS_ID, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${WORKING_DIR}") { // Ensure this points to the directory with your .tf files
                        sh '''
                            terraform init
                            terraform validate
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Destroy Infrastructure') {
            steps {
                script {
                    input message: 'Do you want to destroy the infrastructure?', ok: 'Yes, Destroy'
                }
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: AWS_CREDENTIALS_ID, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${WORKING_DIR}") {
                        sh '''
                            terraform init
                            terraform destroy -auto-approve
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
