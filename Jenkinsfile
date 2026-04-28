pipeline {
    agent any
    tools {
        nodejs 'NodeJS'
    }
    environment {
        APP_NAME     = 'security-gate-simulator'
        PORT         = '3000'
        AWS_REGION   = 'us-east-1'
        ECR_REGISTRY = '723322847039.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPO     = "${ECR_REGISTRY}/${APP_NAME}"
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
                sh 'docker build -t ${APP_NAME}:latest .'
                sh 'docker stop app || true'
                sh 'docker rm app || true'
                sh 'docker run -d -p 3000:3000 --name app ${APP_NAME}:latest'
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                            docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        docker tag ${APP_NAME}:latest ${ECR_REPO}:latest
                        docker tag ${APP_NAME}:latest ${ECR_REPO}:build-${env.BUILD_NUMBER}
                        docker push ${ECR_REPO}:latest
                        docker push ${ECR_REPO}:build-${env.BUILD_NUMBER}
                    """
                    echo "Image pushed to ECR: ${ECR_REPO}:build-${env.BUILD_NUMBER}"
                }
            }
            post {
                success {
                    echo "ECR push completed successfully."
                }
                failure {
                    error "ECR push failed — check AWS credentials and ECR permissions."
                }
            }
        }
        stage('Sign Image') {
            steps {
                withCredentials([
                    file(credentialsId: 'cosign-private-key', variable: 'COSIGN_KEY'),
                    string(credentialsId: 'cosign-password', variable: 'COSIGN_PASSWORD')
                ]) {
                    script {
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | \
                                docker login --username AWS --password-stdin ${ECR_REGISTRY}

                            cosign sign --key \$COSIGN_KEY \
                                --yes \
                                ${ECR_REPO}:build-${env.BUILD_NUMBER}
                        """
                        echo "Image signed: ${ECR_REPO}:build-${env.BUILD_NUMBER}"
                    }
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
        stage('Generate SBOM') {
            steps {
                script {
                    def sbomFile = "sbom-${env.BUILD_NUMBER}.spdx.json"
                    sh "syft ${APP_NAME}:latest -o spdx-json=${sbomFile}"
                    archiveArtifacts artifacts: sbomFile, fingerprint: true
                    stash name: 'sbom', includes: sbomFile
                }
            }
            post {
                success {
                    echo "SBOM generated successfully: sbom-${env.BUILD_NUMBER}.spdx.json"
                }
                failure {
                    error "SBOM generation failed — check Syft output above"
                }
            }
        }
        stage('Vulnerability Scan') {
            steps {
                script {
                    def sbomFile   = "sbom-${env.BUILD_NUMBER}.spdx.json"
                    def reportFile = "grype-report-${env.BUILD_NUMBER}.json"

                    unstash 'sbom'

                    def grypeExit = sh(
                        script: """
                            grype sbom:./${sbomFile} \
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
            sh 'rm -rf /var/jenkins_home/.cache/grype || true'
            sh 'docker system prune -f || true'
        }
    }
}
