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
                        python3 -c "
        import json
        config = {
            'mediaType': 'application/vnd.dev.sigstore.signingconfig.v0.2+json',
            'caUrls': ['https://fulcio.sigstore.dev'],
            'oidcUrl': 'https://oauth2.sigstore.dev/auth',
            'rekorTlogUrls': [],
            'tsaUrls': []
        }
        with open('/tmp/signing-config.json', 'w') as f:
            json.dump(config, f)
        "
                        IMAGE_DIGEST=$(docker inspect --format="{{index .RepoDigests 0}}" security-gate-simulator)
                        echo "Signing: ${IMAGE_DIGEST}"
                        cosign sign --key ${COSIGN_KEY} --yes \
                            --signing-config /tmp/signing-config.json \
                            --new-bundle-format \
                            ${IMAGE_DIGEST}
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
