pipeline {
    agent any
    tools {
        nodejs 'NodeJS'
    }
    environment {
        APP_NAME = 'security-gate-simulator'
        PORT     = '3000'
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
        stage('Test') {
            steps {
                sh 'npm test --if-present'
            }
        }
        stage('Build Verification') {
            steps {
                sh 'node -e "require(\'./app.js\')" &'
                sh 'sleep 3'
                sh 'curl -f http://localhost:${PORT}/health || (echo "Health check failed" && exit 1)'
                sh 'pkill -f "node app.js" || true'
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: '**/*.js, package.json', fingerprint: true
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker build -t security-gate-simulator .'
                sh 'docker stop app || true'
                sh 'docker rm app || true'
                sh 'docker run -d -p 3000:3000 --name app security-gate-simulator'
            }
        }
        stage('Sign Image') {
            steps {
                withCredentials([file(credentialsId: 'cosign-key', variable: 'COSIGN_KEY')]) {
                    sh '''
                        IMAGE_DIGEST=$(docker inspect --format='{{.Id}}' security-gate-simulator)
                        echo "Signing image digest: ${IMAGE_DIGEST}"
                        cosign sign --key ${COSIGN_KEY} --yes docker-daemon:security-gate-simulator:latest
                    '''
                }
            }
        }
    }
    post {
        success {
            echo "Pipeline succeeded for ${APP_NAME}!"
        }
        failure {
            echo "Pipeline FAILED for ${APP_NAME}. Check logs above."
        }
        always {
            cleanWs()
        }
    }
}
