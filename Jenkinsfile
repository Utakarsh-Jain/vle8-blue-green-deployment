
pipeline {
    agent any

    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        MINIKUBE_HOME = '/var/lib/jenkins/.minikube'
        APP_IMAGE = "myapp:jenkins-${BUILD_NUMBER}"
    }

    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                sh 'git rev-parse --short HEAD'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t "$APP_IMAGE" ./green'
            }
        }

        stage('Load Image into Minikube') {
            steps {
                sh 'minikube image load "$APP_IMAGE"'
            }
        }

        stage('Deploy to Green') {
            steps {
                sh '''
                    kubectl set image deployment/green-deployment \
                    myapp="$APP_IMAGE"

                    kubectl rollout status deployment/green-deployment \
                    --timeout=120s
                '''
            }
        }

        stage('Validate Green') {
            steps {
                sh '''
                    GREEN_POD=$(kubectl get pods \
                    -l app=myapp,version=green \
                    -o jsonpath='{.items[0].metadata.name}')

                    kubectl exec "$GREEN_POD" -- \
                    wget -qO- http://127.0.0.1 | \
                    grep -q "GREEN ENVIRONMENT"

                    echo "Green environment validation successful"
                '''
            }
        }

        stage('Approve Traffic Switch') {
            steps {
                input message: 'Green is healthy. Switch live traffic to Green?',
                      ok: 'Switch Traffic'
            }
        }

        stage('Switch Traffic to Green') {
            steps {
                sh '''
                    kubectl patch service myapp-service \
                    -p '{"spec":{"selector":{"app":"myapp","version":"green"}}}'

                    kubectl get endpoints myapp-service

                    kubectl get service myapp-service \
                    -o jsonpath='{.spec.selector.version}'
                '''
            }
        }
    }

    post {
        failure {
            sh '''
                echo "Pipeline failed. Restoring Blue traffic."
                kubectl patch service myapp-service \
                -p '{"spec":{"selector":{"app":"myapp","version":"blue"}}}'
            '''
        }
    }
}

