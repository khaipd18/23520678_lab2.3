# End-to-End Microservices CI/CD Pipeline on AWS EKS (lab2.3)

Dự án này cấu hình và triển khai một quy trình CI/CD hoàn toàn tự động cho hệ thống Microservices (`user-service` và `product-service`) lên nền tảng Amazon EKS (Elastic Kubernetes Service). Quy trình sử dụng Infrastructure as Code (IaC) với Terraform và công cụ tự động hóa Jenkins.

## 1. Kiến trúc hệ thống (System Architecture)
* **Source Control:** GitHub
* **CI/CD Pipeline:** Jenkins
* **Static Code Analysis:** SonarQube
* **Security Scanner:** Trivy
* **Container Registry:** Amazon ECR
* **Container Orchestration:** Amazon EKS
* **Infrastructure as Code:** Terraform

---

## 2. Yêu cầu môi trường (Prerequisites)

Trước khi tiến hành cài đặt, đảm bảo Local Machine hoặc Server của bạn đã được cài đặt các công cụ sau:
* **AWS CLI** (Đã cấu hình IAM User có quyền Admin thông qua `aws configure`).
* **Terraform** (Phiên bản >= 1.0).
* **Docker** và **Docker Compose**.
* **kubectl** (Tương thích với phiên bản Kubernetes 1.35).
* **Git**.

---

## 3. Hướng dẫn cài đặt và triển khai (Deployment Guide)

### Bước 1: Khởi tạo hạ tầng mạng và EKS Cluster bằng Terraform
Hạ tầng được định nghĩa tự động thông qua Terraform, bao gồm VPC, Subnets, Security Groups và Amazon EKS Cluster.

1. Clone mã nguồn về máy:
```bash
   git clone https://github.com/khaipd18/23520678_lab2.3.git
   cd 23520678_lab2.3
```

2. Di chuyển vào thư mục Terraform và khởi tạo hạ tầng:
```bash
   cd terraform/enviroments/dev
   terraform init
   terraform plan
   terraform apply -auto-approve
```

3. Cập nhật kubeconfig để kết nối với EKS Cluster:
```bash
   aws eks update-kubeconfig --region ap-southeast-1 --name lab02-3-cluster
```

### Bước 2: Cấu hình Jenkins CI/CD

Đảm bảo Jenkins Server đã được cài đặt các Plugins: **Docker Pipeline**, **SonarQube Scanner**, **Kubernetes CLI**, **AWS Credentials**.

Thiết lập Credentials trên hệ thống Jenkins:
- **k8s-kubeconfig:** Loại Secret file, tải lên file `~/.kube/config` (Đã được cấu hình Static Token).
- **SonarQube-Server:** Cấu hình Secret Text chứa Token của SonarQube.

Tạo một **Pipeline Item** mới trên Jenkins, trỏ Source Code Management (SCM) về repository này và chỉ định Script Path là `Jenkinsfile`.

Nhấn **Build Now** để khởi chạy Pipeline.

---

## 4. Hướng dẫn kiểm tra kết quả (Verification)

Sau khi Jenkins Pipeline báo trạng thái **SUCCESS**, tiến hành kiểm tra trên Terminal cục bộ:

### 4.1. Kiểm tra trạng thái các Pods
Đảm bảo tất cả các Pods của `user-service` và `product-service` đều ở trạng thái **Running**:

```bash
kubectl get pods -n default
```
### 4.2. Kiểm tra Services và lấy Endpoint truy cập
Hệ thống sử dụng LoadBalancer để expose ứng dụng ra Public Network.

```bash
kubectl get svc -n default
```

> **Chú ý:** Copy địa chỉ tại cột `EXTERNAL-IP` và truy cập thông qua trình duyệt web. LoadBalancer trên AWS có thể mất từ 2-3 phút để Provisioning thành công.

### 4.3. Kiểm tra log của ứng dụng (Troubleshooting)
Trong trường hợp cần debug hoặc kiểm tra luồng thực thi bên trong container:

```bash
kubectl logs deployment/user-service
kubectl logs deployment/product-service
```

---

## 5. Dọn dẹp tài nguyên (Clean up)

Để tránh phát sinh chi phí không mong muốn trên AWS sau khi hoàn thành kiểm thử, tiến hành gỡ bỏ toàn bộ hạ tầng bằng Terraform:

```bash
cd terraform/enviroments/dev
terraform destroy -auto-approve
```
