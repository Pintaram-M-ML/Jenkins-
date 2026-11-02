
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

        stage('Prepare Image Tag') {
            steps {
                script {
                    env.SAFE_BRANCH_NAME = env.BRANCH_NAME.replaceAll('/', '-')
                    env.FULL_IMAGE_NAME = "${env.DOCKER_HUB_USER_NAME}/${env.IMAGE_NAME}:${env.SAFE_BRANCH_NAME}-${env.IMAGE_TAG}"

                    echo "Docker Image: ${env.FULL_IMAGE_NAME}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t "$FULL_IMAGE_NAME" .
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
                    docker push "$FULL_IMAGE_NAME"
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
                        kuber-site="$FULL_IMAGE_NAME"

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
            echo "Image: ${FULL_IMAGE_NAME}"
        }

        failure {
            echo "Pipeline failed for branch: ${BRANCH_NAME}"
        }
    }
}
