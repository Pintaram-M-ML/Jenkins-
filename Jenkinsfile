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