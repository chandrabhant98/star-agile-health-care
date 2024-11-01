pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub_credentials'  // Replace with your Docker Hub credentials ID
        AWS_CREDENTIALS_ID = 'aws_credentials'           // Replace with your AWS credentials ID
        DOCKER_IMAGE = "your-dockerhub-username/healthcareapp:1.0" // Replace with your Docker Hub username
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
                sh 'docker build -t chandrabhant98/healthcareapp:1.0 .'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernameColonPassword(credentialsId: 'Dockerlogin-user', variable: 'DOCKER_CREDENTIALS')]) {
                        // Log in to Docker Hub using --password-stdin
                        sh '''
                            echo ${DOCKER_CREDENTIALS.split(':')[1]} | docker login -u ${DOCKER_CREDENTIALS.split(':')[0]} --password-stdin
                        '''
                        
                        // Push the Docker image
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Provision Infrastructure') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                    sh '''
                        terraform init
                        terraform validate
                        terraform apply -auto-approve
                    '''
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
