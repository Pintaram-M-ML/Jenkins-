pipeline {
    agent any

    environment {
        IMAGE_NAME = "kuber-site"
        IMAGE_TAG  = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image in Minikube') {
    steps {
        sh '''
            set -e
            minikube image build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
        '''
    }
}
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    kubectl rollout restart deployment/kuber-site
                    kubectl rollout status deployment/kuber-site
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
