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
                retry(2) {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-creds',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]) {
                        sh '''
                            export DOCKER_BUILDKIT=0
                            docker build -t ${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG} .
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
    steps {
        sh '''
            helm upgrade --install kuber-site ./kuber_helm \
                --namespace default \
                --create-namespace \
                --set fullnameOverride=kuber-site \
                --set image.repository=${DOCKER_HUB_USER_NAME}/${IMAGE_NAME} \
                --set image.tag=${IMAGE_TAG} \
                --force-conflicts \
                --wait \
                --timeout 5m

            kubectl rollout status deployment/kuber-site -n default
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