## システム構成図
<br><br>

## ディレクトリ構成
```
├─ environments
│  ├─ prd
│  ├─ stg
│  └─ dev
│     ├─ main.tf
│     ├─ local.tf
│     ├─ variable.tf
│     └─ (terraform.tfvars)
│
├─ modules(各Moduleにmain.tf,variable.tf,output.tfが存在)
│     ├─ alb_ingress(Public ALB関連のリソース）
│     ├─ alb_internal(Private ALB関連のリソース）
│     ├─ ec2(管理EC2関連のリソース）
│     ├─ ecr(ECR関連のリソース）
│     ├─ ecs_backend(Backend ECS関連のリソース）
│     ├─ ecs_frontend(Frontend ECS関連のリソース）
│     ├─ initializer（tfstate用S3バケット作成）
│     ├─ network（VPC、Subnet、VPNなどネットワーク全般のリソース）
│     ├─ rds（RDS関連のリソース）
│     └─ secrets_manager（Secrets Manager関連のリソース）
│
├─ backend_app（CI/CD対象となるバックエンドアプリ）
│ 
└─ appspec.yml（Code Deployによるデプロイ処理内容を記載）
```
