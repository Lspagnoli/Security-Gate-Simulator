pipeline {
    agent any

    tools {
        nodejs 'NodeJS'
    }

    environment {
        APP_NAME     = 'security-gate-simulator'
        AWS_REGION   = 'us-east-1'
        ECR_REGISTRY = '723322847039.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPO     = "${ECR_REGISTRY}/${APP_NAME}"
        IMAGE_TAG    = "build-${BUILD_NUMBER}"
        IMAGE_URI    = "${ECR_REPO}:${IMAGE_TAG}"
        K8S_NAMESPACE = 'securechain-dev'
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

        stage('App Test') {
            steps {
                sh 'npm test --if-present'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${APP_NAME}:latest .'
                sh 'docker tag ${APP_NAME}:latest ${IMAGE_URI}'
            }
        }

        stage('Generate SBOM') {
            steps {
                sh 'syft ${APP_NAME}:latest -o spdx-json=sbom-${BUILD_NUMBER}.spdx.json'
                archiveArtifacts artifacts: 'sbom-*.spdx.json', fingerprint: true
            }
        }

        stage('Vulnerability Scan Gate') {
            steps {
                sh 'grype sbom:sbom-${BUILD_NUMBER}.spdx.json --fail-on critical'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                    docker push ${IMAGE_URI}
                    docker tag ${APP_NAME}:latest ${ECR_REPO}:latest
                    docker push ${ECR_REPO}:latest
                '''
            }
        }

        stage('Sign Image with Cosign') {
            steps {
                withCredentials([
                    file(credentialsId: 'cosign-private-key', variable: 'COSIGN_KEY'),
                    string(credentialsId: 'cosign-password', variable: 'COSIGN_PASSWORD')
                ]) {
                    sh '''
                        COSIGN_PASSWORD=$COSIGN_PASSWORD cosign sign --key $COSIGN_KEY --yes ${IMAGE_URI}
                    '''
                }
            }
        }

        stage('Verify Image Signature Gate') {
            steps {
                sh 'cosign verify --key cosign.pub ${IMAGE_URI}'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f k8s/namespace.yaml
                    kubectl apply -f k8s/service.yaml

                    kubectl set image deployment/securechain-app \
                        securechain-app=${IMAGE_URI} \
                        -n ${K8S_NAMESPACE} || kubectl apply -f k8s/deployment.yaml

                    kubectl rollout status deployment/securechain-app -n ${K8S_NAMESPACE} --timeout=120s
                    kubectl get pods -n ${K8S_NAMESPACE}
                    kubectl get svc -n ${K8S_NAMESPACE}
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline passed. Secure image deployed: ${IMAGE_URI}"
        }
        failure {
            echo 'Pipeline failed. Security gate blocked deployment or deployment failed.'
        }
        always {
            archiveArtifacts artifacts: 'grype-report-*.json', allowEmptyArchive: true
            sh 'docker system prune -f || true'
        }
    }
}
