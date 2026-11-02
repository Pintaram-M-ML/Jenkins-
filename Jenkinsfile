
pipeline {
    agent any

    environment {
        DOCKER_HUB_USER_NAME = 'pintaram369'
        IMAGE_NAME = 'kuber-site'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Building branch: ${BRANCH_NAME}"
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${BRANCH_NAME}-${IMAGE_TAG} .
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        set +x
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh '''
                    docker push ${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${BRANCH_NAME}-${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml

                    kubectl set image deployment/kuber-site \
                        kuber-site=${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${BRANCH_NAME}-${IMAGE_TAG}

                    kubectl rollout status deployment/kuber-site
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }

        success {
            echo "Pipeline successful for branch: ${BRANCH_NAME}"
        }

        failure {
            echo "Pipeline failed for branch: ${BRANCH_NAME}"
        }
    }
}
