pipeline {
    agent any

    environment {
        // Thay YOUR_AWS_ACCOUNT_ID bằng ID tài khoản AWS của bạn
        AWS_ACCOUNT_ID = "797226340543"
        AWS_REGION     = "ap-southeast-1"
        ECR_REGISTRY   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_TAG      = "${BUILD_NUMBER}"
        
        SCANNER_HOME   = tool 'SonarScanner' 
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('2. CI Pipeline (Build, Test, Scan, Push)') {
            failFast true // Bất kỳ service nào lỗi, dừng toàn bộ pipeline ngay lập tức
            parallel {
                // ==================== USER SERVICE ====================
                stage('User Service') {
                    steps {
                        dir('src/user-service') { // Di chuyển vào thư mục user-service
                            echo "🚀 Bắt đầu CI cho User Service..."
                            
                            // 2.1 SonarQube Scan
                            withSonarQubeEnv('SonarQube-Server') {
                                sh '''
                                $SCANNER_HOME/bin/sonar-scanner \
                                  -Dsonar.projectKey=user-service \
                                  -Dsonar.sources=.
                                '''
                            }

                            // 2.2 Build Image
                            script {
                                env.USER_IMAGE = "${ECR_REGISTRY}/user-service"
                                sh "docker build -t ${USER_IMAGE}:${IMAGE_TAG} ."
                            }

                            // 2.3 Security Scan (Trivy)
                            sh "trivy image --exit-code 0 --severity HIGH,CRITICAL ${USER_IMAGE}:${IMAGE_TAG}"

                            // 2.4 Push to ECR
                            script {
                                // Yêu cầu server Jenkins phải cài đặt sẵn AWS CLI và được cấp quyền (aws configure)
                                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                                sh "docker push ${USER_IMAGE}:${IMAGE_TAG}"
                            }
                        }
                    }
                }

                // ==================== PRODUCT SERVICE ====================
                stage('Product Service') {
                    steps {
                        dir('src/product-service') { // Di chuyển vào thư mục product-service
                            echo "🚀 Bắt đầu CI cho Product Service..."
                            
                            // 2.1 SonarQube Scan
                            withSonarQubeEnv('SonarQube-Server') {
                                sh '''
                                $SCANNER_HOME/bin/sonar-scanner \
                                  -Dsonar.projectKey=product-service \
                                  -Dsonar.sources=.
                                '''
                            }

                            // 2.2 Build Image
                            script {
                                env.PRODUCT_IMAGE = "${ECR_REGISTRY}/product-service"
                                sh "docker build -t ${PRODUCT_IMAGE}:${IMAGE_TAG} ."
                            }

                            // 2.3 Security Scan (Trivy)
                            sh "trivy image --exit-code 0 --severity HIGH,CRITICAL ${PRODUCT_IMAGE}:${IMAGE_TAG}"

                            // 2.4 Push to ECR
                            script {
                                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                                sh "docker push ${PRODUCT_IMAGE}:${IMAGE_TAG}"
                            }
                        }
                    }
                }
            }
        }

        stage('3. Deploy to EKS') {
            steps {
                withKubeConfig([credentialsId: 'k8s-kubeconfig']) {
                    sh '''
                    echo "🔄 Cập nhật tag mới và Deploy..."
                    
                    sed -i "s|image: 797226340543.*|image: ${ECR_REGISTRY}/user-service:${IMAGE_TAG}|g" k8s/user-service/deployment.yaml
                    kubectl apply -f k8s/user-service/ --validate=false
                    
                    sed -i "s|image: 797226340543.*|image: ${ECR_REGISTRY}/product-service:${IMAGE_TAG}|g" k8s/product-service/deployment.yaml
                    kubectl apply -f k8s/product-service/ --validate=false
                    '''
                }
    }
}
    }

    post {
        always {
            echo "🧹 Dọn dẹp Docker images trên Jenkins node..."
            sh "docker rmi ${ECR_REGISTRY}/user-service:${IMAGE_TAG} || true"
            sh "docker rmi ${ECR_REGISTRY}/product-service:${IMAGE_TAG} || true"
        }
        success {
            echo "✅ Toàn bộ hệ thống đã được triển khai thành công!"
        }
        failure {
            echo "❌ Quá trình CI/CD thất bại. Vui lòng kiểm tra lại log."
        }
    }
}