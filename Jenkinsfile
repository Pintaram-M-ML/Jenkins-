
pipeline {
    agent any

    environment {
        IMAGE = 'pintaram369/kuber-site'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Build and Push Image') {
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
                        docker build -t "$IMAGE:$IMAGE_TAG" .
                        docker push "$IMAGE:$IMAGE_TAG"
                    '''
                }
            }
        }

        stage('Deploy to Minikube') {
            when {
                expression {
                    (env.BRANCH_NAME ?: env.GIT_BRANCH?.replaceFirst('^origin/', '')) == 'feature/login'
                }
            }
            steps {
                sh '''
                    helm upgrade --install kuber-site ./kuber_helm \
                        --kube-context minikube \
                        --namespace prod --create-namespace \
                        --set image.repository="$IMAGE" \
                        --set image.tag="$IMAGE_TAG" \
                        --wait --timeout 5m
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
