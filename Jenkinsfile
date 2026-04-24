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
        stage('Generate SBOM') {
            steps {
                script {
                    def sbomFile = "sbom-${env.BUILD_NUMBER}.spdx.json"

                    sh """
                        syft ${APP_NAME}:latest \
                         -o spdx-json=${sbomFile}
                    """

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
                    def sbomFile  = "sbom-${env.BUILD_NUMBER}.spdx.json"
                    def reportFile = "grype-report-${env.BUILD_NUMBER}.json"

                    unstash 'sbom'

                    // Run Grype — exit code 0 regardless of findings so we control the gate
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
                        // Parse report to surface a quick summary in the build log
                        def report = readJSON file: reportFile
                        def criticals = report.matches.findAll {
                            it.vulnerability.severity.toUpperCase() == 'CRITICAL'
                        }
                        echo "CRITICAL vulnerabilities found (${criticals.size()}):"
                        criticals.each { vuln ->
                            echo "  [${vuln.vulnerability.id}] ${vuln.artifact.name}@${vuln.artifact.version} — ${vuln.vulnerability.description?.take(120) ?: 'no description'}"
                        }
                        error "Build failed: ${criticals.size()} CRITICAL vulnerability(s) detected. Review grype-report-${env.BUILD_NUMBER}.json for full details."
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
        }
    }
}
