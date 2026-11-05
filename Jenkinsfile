pipeline {
    agent any

    environment {
        DOCKER_HUB_USER_NAME = 'pintaram369'
        IMAGE_NAME           = 'kuber-site'
        IMAGE_TAG            = "${BUILD_NUMBER}"
        RELEASE_NAME         = 'kuber-site'
        NAMESPACE            = 'default'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        docker build -t ${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG} .
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    helm upgrade --install ${RELEASE_NAME} ./kuber_helm \
                        --namespace ${NAMESPACE} \
                        --create-namespace \
                        --set fullnameOverride=${RELEASE_NAME} \
                        --set image.repository=${DOCKER_HUB_USER_NAME}/${IMAGE_NAME} \
                        --set image.tag=${IMAGE_TAG} \
                        --wait --timeout 5m

                    kubectl rollout status deployment/${RELEASE_NAME} -n ${NAMESPACE}
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}