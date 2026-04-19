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
                echo "Checked out branch: ${env.BRANCH_NAME ?: 'unknown'}"
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
        stage('Build Docker Image') {
            steps {
                // Diagnose Docker PATH before attempting build
                sh 'which docker && docker --version'
                sh 'docker build -t ${IMAGE} .'
            }
        }
        stage('Sign Image (Cosign)') {
            steps {
                sh '''
                    cosign version

                    # Get the image digest (Cosign requires digest, not just tag)
                    IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' ${IMAGE} 2>/dev/null || echo "")

                    # Sign using key file stored as a Jenkins secret
                    # Requires COSIGN_PASSWORD env var and cosign.key credential configured in Jenkins
                    cosign sign --key cosign.key ${IMAGE}
                '''
            }
        }
        stage('Verify Image (Cosign)') {
            steps {
                sh '''
                    cosign verify --key cosign.pub ${IMAGE}
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
