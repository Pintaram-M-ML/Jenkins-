
pipeline {
    agent any

    environment {
        IMAGE = 'pintaram369/kuber-site'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Build and Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
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

        stage('Production Approval') {
    steps {
        script {
            timeout(time: 30, unit: 'MINUTES') {
                input(
                    message: "Deploy ${IMAGE}:${IMAGE_TAG} to PRODUCTION?",
                    ok: 'Approve Deployment',
                    submitter: 'admin',
                    submitterParameter: 'APPROVED_BY'
                )
            }
        }
    }
}
        stage('Deploy to Minikube') {
             when {
                    branch 'testing'
                }
            steps {
               
                sh '''
                    helm upgrade --install kuber-site ./kuber_helm \
                        --kube-context minikube \
                        --namespace testing --create-namespace \
                        --set image.repository="$IMAGE" \
                        --set image.tag="$IMAGE_TAG"

                    kubectl --context=minikube rollout status \
                        deployment/kuber-site -n testing
                '''

                
            }
        }
    }

    post {
        always {
            echo 'docker logout || true'
        }
    }
}
