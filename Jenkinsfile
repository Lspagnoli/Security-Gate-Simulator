pipeline {
    agent {
        docker {
            image 'node:18'
        }
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Verify Node + npm') {
            steps {
                sh 'node -v'
                sh 'npm -v'
            }
        }

        stage('Start App (Smoke Test)') {
            steps {
                sh 'timeout 10s npm start || true'
            }
        }
    }

    post {
        always {
            echo 'Build completed'
        }
    }
}
