# DevOps Practice — Lesson 7

Коротка документація проєкту для розгортання Django-застосунку на AWS EKS з використанням Terraform, Docker, ECR та Helm.

## Структура проєкту
- `modules/`
  - `s3-backend/` — конфігурація бекенду для стану Terraform (S3 bucket + DynamoDB для блокувань).
  - `vpc/` — створення VPC: підмережі (public/private), route tables, Internet Gateway, NAT Gateway, security groups.
  - `eks/` — створення EKS-кластера з node group (EC2 інстанси t3.small).
  - `ecr/` — створення ECR репозиторіїв для зберігання образів Docker.
- `charts/django-app/` — Helm-чарт для розгортання Django-застосунку та PostgreSQL.
- `events-app/app/` — код для Django-застосунку.
- `main.tf`, `variables.tf`, `outputs.tf` — кореневі конфігураційні файли Terraform.
- `backend.tf` — налаштування збереження стану у S3.

## Попередні вимоги
- AWS-акаунт з налаштованими креденшіалами (AWS CLI: `aws configure`).
- Встановлені інструменти:
  - Terraform (v1.5+)
  - Docker
  - AWS CLI (v2+)
  - kubectl
  - Helm (v3+)
- Налаштований kubeconfig для EKS (після створення кластера).

## Розгортання

### 1. Ініціалізація та створення інфраструктури (Terraform)
```bash
# Ініціалізація (якщо S3-бакет існує)
terraform init

# Перегляд плану
terraform plan

# Застосування (створить VPC, EKS, ECR, S3-backend)
terraform apply
```

### 2. Побудова та завантаження Docker-образу
```bash
# Перехід до каталогу з кодом
cd events-app/app

# Побудова образу
docker build -t django-app .

# Автентифікація в ECR (замініть <account-id> на ваш)
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-1.amazonaws.com

# Тегування та завантаження
docker tag django-app:latest <account-id>.dkr.ecr.eu-west-1.amazonaws.com/lesson-8-9-ecr:latest
docker push <account-id>.dkr.ecr.eu-west-1.amazonaws.com/lesson-8-9-ecr:latest
```

### 3. Розгортання застосунку (Helm)
```bash
# Перехід до чарта
cd ../charts/django-app

# Оновлення values.yaml (вкажіть правильний ECR-URL)
# image.repository: <account-id>.dkr.ecr.eu-west-1.amazonaws.com/lesson-8-9-ecr

# Встановлення чарта
helm install django-app .

# Підключення kubectl до EKS (якщо потрібно)
aws eks update-kubeconfig --name eks-cluster-demo --region eu-west-1
```

## Перевірка розгортання

### Статус подів
```bash
kubectl get pods
# Має показати: django-app-django-* (Running), django-app-postgres-* (Running)
```

### Статус сервісів
```bash
kubectl get svc
# Має показати LoadBalancer з EXTERNAL-IP
```

### Доступ до застосунку
- Відкрийте EXTERNAL-IP у браузері (наприклад: http://af169e7d00b55440bb2bb151383e2198-287370733.eu-west-1.elb.amazonaws.com)
- Має завантажитися Django-сторінка з подіями.

### Перевірка HPA
```bash
kubectl get hpa
# Має показати: django-app-django-hpa (1/1 replicas)

# Тестування масштабування (запустіть у окремому терміналі)
kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://django-app-django; done"
# Потім перевірте: kubectl get hpa (має збільшити replicas)
```

## Команди Terraform
- `terraform init` — Ініціалізація робочого каталогу, завантаження провайдерів і налаштування бекенду.
- `terraform plan` — Перегляд плану змін.
- `terraform apply` — Застосування плану (створення ресурсів).
- `terraform destroy` — Видалення створених ресурсів.

Примітка: Виконувати в корені проєкту; переконайтеся в налаштованих AWS-креденшіалах.

## Команди Helm
- `helm install <release-name> .` — Встановлення чарта.
- `helm upgrade <release-name> .` — Оновлення чарта.
- `helm uninstall <release-name>` — Видалення релізу.
- `helm list` — Список встановлених релізів.

## Очищення
```bash
# Видалення Helm-релізу
helm uninstall django-app

# Видалення інфраструктури
terraform destroy
```

## Пояснення модулів
- **s3-backend**:
  - **Призначення**: Забезпечує надійне збереження стану Terraform у хмарі, використовуючи S3-бакет для зберігання файлів стану (.tfstate) та DynamoDB-таблицю для блокувань (lock) під час паралельних операцій.
  - **Чому важливо**: Дозволяє спільну роботу команди або CI/CD систем без ризику конфліктів стану. Стан зберігається віддалено, що захищає від втрати даних при локальних збоях.
  - **Ключові компоненти**: S3-бакет з версіями для історії; DynamoDB-таблиця для атомарних блокувань; політики доступу для обмеження прав.

- **vpc**:
  - **Призначення**: Створює ізольовану мережеву інфраструктуру в AWS, необхідну для безпечного розміщення ресурсів.
  - **Чому важливо**: VPC забезпечує сегментацію мережі, контроль трафіку та безпеку. Public subnets для доступу до інтернету (наприклад, LoadBalancer), private — для внутрішніх сервісів (наприклад, бази даних).
  - **Ключові компоненти**: VPC з CIDR-блоком; public/private subnets у різних AZ для високої доступності; Internet Gateway для зовнішнього трафіку; NAT Gateway для egress з private subnets; Route Tables для маршрутизації; Security Groups для фільтрації трафіку на рівні інстансів.

- **eks**:
  - **Призначення**: Розгортає Kubernetes-кластер на AWS (EKS) з managed node group для автоматичного управління EC2-інстансами.
  - **Чому важливо**: EKS спрощує управління Kubernetes, забезпечуючи високу доступність, автоматичні оновлення та інтеграцію з AWS-сервісами. Node group дозволяє динамічне масштабування робочих вузлів.
  - **Ключові компоненти**: EKS-кластер з control plane; IAM-ролі для кластера та вузлів; Managed node group з EC2 t3.small інстансами; Autoscaling (1-2 вузли); Політики доступу (WorkerNode, CNI, ECR) для вузлів.

- **ecr**:
  - **Призначення**: Створює приватний реєстр для Docker-образів (ECR), що дозволяє безпечне зберігання та поширення контейнерів.
  - **Чому важливо**: ECR інтегрується з EKS та IAM, забезпечуючи швидкий pull образів без аутентифікації. Політики життєвого циклу допомагають керувати витратами, видаляючи старі образи.
  - **Ключові компоненти**: ECR-репозиторій з шифруванням; політики доступу для обмеження pull/push; правила життєвого циклу (наприклад, зберігати останні 10 версій); сканування на вразливості.

- **charts/django-app** (Helm-чарт):
  - **Призначення**: Визначає Kubernetes-ресурси для розгортання Django-застосунку та PostgreSQL у вигляді пакета Helm.
  - **Чому важливо**: Helm спрощує управління складними додатками, дозволяючи параметризацію, версіяність та повторне використання. ConfigMap передає змінні середовища, HPA забезпечує авто-масштабування.
  - **Ключові компоненти**: Deployment для Django та Postgres; Service (LoadBalancer) для зовнішнього доступу; ConfigMap/Secret для конфігурації; PersistentVolumeClaim (emptyDir для тестування) для даних; HorizontalPodAutoscaler для масштабування на основі CPU.

- **jenkins**:
  - **Призначення**: Інсталює Jenkins через Helm для виконання CI пайплайнів.
  - **Чому важливо**: Автоматизує збірку образів (Kaniko) та пуш у ECR.

- **argo_cd**:
  - **Призначення**: Інсталює Argo CD через Helm для забезпечення CD (Continuous Deployment) та GitOps підходу.
  - **Чому важливо**: Автоматично синхронізує стан кластера зі змінами у Git-репозиторії.

## CI/CD Інструкції

### Як застосувати Terraform
Для встановлення всієї інфраструктури, включаючи Jenkins та Argo CD, виконайте:
1. `terraform init` (якщо ще не ініціалізовано)
2. `terraform apply` (перевірте план і підтвердіть)
Це створить кластер EKS та автоматично розгорне на ньому Jenkins і Argo CD за допомогою Helm провайдера.

### Як перевірити Jenkins job
1. Отримайте URL Jenkins: `kubectl get svc -n jenkins` (скопіюйте EXTERNAL-IP).
2. Отримайте пароль адміністратора: `kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode` (або `adminPassword123` з `values.yaml`).
3. Увійдіть у Jenkins, створіть новий Pipeline, вкажіть Git репозиторій (events-app), і Jenkins завантажить `Jenkinsfile` та почне збірку.
4. Після успішної збірки образ з'явиться в ECR, а тег у `values.yaml` в Git-репозиторії буде оновлено автоматично.

### Як побачити результат в Argo CD
1. Застосуйте Argo CD Application: `helm install argo-apps ./charts/argo-apps`
2. Отримайте URL Argo CD: `kubectl get svc argo-cd-argocd-server -n argocd` (скопіюйте EXTERNAL-IP).
3. Отримайте пароль: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
4. Увійдіть у веб-інтерфейс (логін: `admin`).
5. Перевірте статус `django-app` Application — він має бути `Healthy` та `Synced`. Застосунок автоматично підхопить новий image tag з Git після успішного виконання Jenkins job.
