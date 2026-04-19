pipeline {
    agent any

    tools {
        nodejs 'NodeJS'
    }

    environment {
        APP_NAME = 'security-gate-simulator'
        PORT     = '3000'
        IMAGE    = 'security-gate-simulator:latest'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Lint') {
            steps {
                sh 'npm run lint --if-present'
            }
        }

        stage('Test') {
            steps {
                // TODO: add tests
            }
        }

        stage('Build App') {
            steps {
                // optional: app build step if needed
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE} .'
            }
        }

        stage('Push Image') {
            steps {
                // TODO: push to registry (Docker Hub / ECR / etc.)
            }
        }

        stage('Sign Image (Cosign)') {
            steps {
                sh '''
                    cosign version
                    cosign sign ${IMAGE}
                '''
            }
        }

        stage('Verify Image (Cosign)') {
            steps {
                sh '''
                    cosign verify ${IMAGE}
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker stop app || true
                    docker rm app || true
                    docker run -d -p ${PORT}:${PORT} --name app ${IMAGE}
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded for ${APP_NAME}"
        }
        failure {
            echo "Pipeline FAILED for ${APP_NAME}"
        }
        always {
            cleanWs()
        }
    }
}
