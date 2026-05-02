pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '3'))
    }

    tools {
        nodejs 'NodeJS'
    }

    environment {
        APP_NAME      = 'security-gate-simulator'
        PORT          = '3000'
        AWS_REGION    = 'us-east-1'
        ECR_REGISTRY  = '723322847039.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPO      = "${ECR_REGISTRY}/${APP_NAME}"
        IMAGE_TAG     = "build-${BUILD_NUMBER}"
        IMAGE_URI     = "${ECR_REPO}:${IMAGE_TAG}"
        K8S_NAMESPACE = 'securechain-dev'
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

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${APP_NAME}:latest .
                    docker tag ${APP_NAME}:latest ${IMAGE_URI}
                '''
            }
        }

        stage('Generate SBOM') {
            steps {
                sh 'syft ${APP_NAME}:latest -o spdx-json=sbom-${BUILD_NUMBER}.spdx.json'
                archiveArtifacts artifacts: 'sbom-*.spdx.json', fingerprint: true
            }
            post {
                success {
                    echo "SBOM generated successfully: sbom-${BUILD_NUMBER}.spdx.json"
                }
                failure {
                    error "SBOM generation failed — check Syft output above"
                }
            }
        }

        stage('Vulnerability Scan Gate') {
            steps {
                script {
                    def reportFile = "grype-report-${env.BUILD_NUMBER}.json"

                    def grypeExit = sh(
                        script: """
                            grype sbom:sbom-${env.BUILD_NUMBER}.spdx.json \
                                -o json \
                                --file ${reportFile} \
                                --fail-on critical
                        """,
                        returnStatus: true
                    )

                    archiveArtifacts artifacts: reportFile, fingerprint: true

                    if (grypeExit == 0) {
                        echo "Vulnerability scan passed — no CRITICAL vulnerabilities found."
                    } else {
                        def report    = readJSON file: reportFile
                        def criticals = report.matches.findAll {
                            it.vulnerability.severity.toUpperCase() == 'CRITICAL'
                        }
                        echo "CRITICAL vulnerabilities found (${criticals.size()}):"
                        criticals.each { vuln ->
                            echo "  [${vuln.vulnerability.id}] ${vuln.artifact.name}@${vuln.artifact.version} — ${vuln.vulnerability.description?.take(120) ?: 'no description'}"
                        }
                        error "Build failed: ${criticals.size()} CRITICAL vulnerability(s) detected."
                    }
                }
            }
            post {
                success {
                    echo "Vulnerability scan completed — no CRITICAL issues."
                }
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
            post {
                success {
                    echo "ECR push completed successfully: ${IMAGE_URI}"
                }
                failure {
                    error "ECR push failed — check AWS credentials and ECR permissions."
                }
            }
        }

        stage('Sign Image with Cosign') {
            steps {
                withCredentials([
                    file(credentialsId: 'cosign-private-key', variable: 'COSIGN_KEY'),
                    string(credentialsId: 'cosign-password', variable: 'COSIGN_PASSWORD')
                ]) {
                    sh '''
                        COSIGN_PASSWORD=$COSIGN_PASSWORD cosign sign \
                            --key $COSIGN_KEY \
                            --yes ${IMAGE_URI}
                    '''
                }
            }
            post {
                success {
                    echo "Cosign signing completed successfully."
                }
                failure {
                    error "Image signing failed — check Cosign output above."
                }
            }
        }

        stage('Verify Image Signature Gate') {
            steps {
                sh '''
                    cosign verify --key cosign.pub ${IMAGE_URI}
                '''
            }
            post {
                success {
                    echo "Signature verification passed."
                }
                failure {
                    error "Signature verification failed — image may have been tampered with."
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')
                ]) {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG_FILE

                        kubectl get nodes

                        kubectl apply -f k8s/namespace.yaml --validate=false
                        kubectl apply -f k8s/deployment.yaml --validate=false
                        kubectl apply -f k8s/service.yaml --validate=false

                        kubectl set image deployment/securechain-app \
                            securechain-app=${IMAGE_URI} \
                            -n ${K8S_NAMESPACE}

                        kubectl rollout status deployment/securechain-app \
                            -n ${K8S_NAMESPACE} \
                            --timeout=120s

                        kubectl get pods -n ${K8S_NAMESPACE}
                        kubectl get svc -n ${K8S_NAMESPACE}
                    '''
                }
            }
            post {
                success {
                    echo "Kubernetes deployment successful: ${IMAGE_URI}"
                }
                failure {
                    error "Kubernetes deployment failed — check kubectl output above."
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded for ${APP_NAME}! Secure image deployed: ${IMAGE_URI}"
        }
        failure {
            echo "Pipeline FAILED for ${APP_NAME}. Check logs above."
        }
        always {
            cleanWs()
            sh 'rm -rf /var/jenkins_home/.cache/grype || true'
            sh 'docker system prune -af || true'
        }
    }
}
