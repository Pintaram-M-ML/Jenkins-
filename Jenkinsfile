pipeline { agent any

environment {
    DOCKER_HUB_USER_NAME = 'pintaram369'
    IMAGE_NAME = 'kuber-site'
    IMAGE_TAG = "${BUILD_NUMBER}"
    RELEASE_NAME = 'kuber-site'
    NAMESPACE = 'default'
}

stages {

    stage('Checkout') {
        steps {
            checkout scm
        }
    }

    stage('Verify Tools') {
        steps {
            sh '''
                echo "Checking Docker..."
                docker --version

                echo "Checking kubectl..."
                kubectl version --client

                echo "Checking Helm..."
                helm version

                echo "Checking Kubernetes connection..."
                kubectl cluster-info
                kubectl get nodes
            '''
        }
    }

    stage('Build Docker Image') {
        steps {
            sh '''
                docker build \
                    -t ${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG} .
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
                docker push \
                    ${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
            '''
        }
    }

    stage('Validate Helm Chart') {
        steps {
            sh '''
                helm lint ./kuber_helm
                helm template ${RELEASE_NAME} ./kuber_helm \
                    --namespace ${NAMESPACE} \
                    --set fullnameOverride=${RELEASE_NAME} \
                    --set image.repository=${DOCKER_HUB_USER_NAME}/${IMAGE_NAME} \
                    --set image.tag=${IMAGE_TAG}
            '''
        }
    }

    stage('Adopt Existing Resources') {
        steps {
            sh '''
                # If kuber-site resources already exist but were created outside Helm
                # (e.g. via kubectl apply), label/annotate them so Helm can adopt
                # them instead of failing with "invalid ownership metadata".
                for kind in service deployment serviceaccount; do
                    if kubectl get ${kind} ${RELEASE_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
                        kubectl label ${kind} ${RELEASE_NAME} -n ${NAMESPACE} \
                            app.kubernetes.io/managed-by=Helm --overwrite
                        kubectl annotate ${kind} ${RELEASE_NAME} -n ${NAMESPACE} \
                            meta.helm.sh/release-name=${RELEASE_NAME} \
                            meta.helm.sh/release-namespace=${NAMESPACE} --overwrite
                    fi
                done
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
                    --wait \
                    --timeout 5m

                kubectl rollout status \
                    deployment/${RELEASE_NAME} \
                    -n ${NAMESPACE} \
                    --timeout=300s

                kubectl get pods -n ${NAMESPACE}
                kubectl get services -n ${NAMESPACE}
            '''
        }
    }
}

post {
    always {
        sh 'docker logout || true'
    }

    success {
        echo "Deployment successful!"
        echo "Image: ${DOCKER_HUB_USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    failure {
        echo "Pipeline failed!"
    }
}


}