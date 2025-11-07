# 🚀 Roadmap Docker & Kubernetes - ESIGELEC

## 📋 Vue d'ensemble

Cette roadmap vous guide à travers l'apprentissage de Docker et Kubernetes avec un focus sur le déploiement AWS. Le projet est structuré en plusieurs labs progressifs qui couvrent les concepts fondamentaux jusqu'aux déploiements avancés en production.

---

## 🎯 Objectifs d'apprentissage

- Maîtriser la containerisation avec Docker
- Comprendre l'orchestration avec Kubernetes
- Déployer des applications sur AWS (EKS, ECR, Fargate)
- Implémenter des microservices avec Open Liberty
- Appliquer les bonnes pratiques DevOps

---

## 📚 Phase 1: Fondamentaux Docker

### 🐳 Lab 1: Introduction aux Containers et Docker
**Dossier:** `lab-docker/1_ContainersAndDocker/`

#### Objectifs
- Comprendre les concepts de containerisation
- Créer et gérer des images Docker
- Déployer une application Node.js simple

#### Étapes pratiques
1. **Cloner et explorer le repository**
   ```bash
   git clone https://github.com/marc1025-ui/Docker-K8S-Esigelec.git
   cd Docker-K8S-Esigelec/lab-docker/1_ContainersAndDocker
   ```

2. **Construire l'image Docker**
   ```bash
   docker build -t hello-world-node:v1 .
   ```

3. **Exécuter le container localement**
   ```bash
   docker run -p 8080:8080 hello-world-node:v1
   ```

4. **Tester l'application**
   - Ouvrir http://localhost:8080
   - Vérifier le message "Hello world from [hostname]!"

#### ✅ Livrables
- [ ] Application fonctionnelle en local
- [ ] Image Docker créée
- [ ] Tests de connectivité réussis

---

### 🔧 Lab 2: Containers Avancés et Registries
**Dossier:** `lab-docker/1_ContainersAndDocker_2/`

#### Objectifs
- Explorer différents types de containers (UBI, Nginx, Java)
- Configurer des registries Docker
- Préparer le déploiement cloud

#### Applications à containeriser

1. **Hello World Nginx**
   - **Dossier:** `hello-world-nginx/`
   - **Port:** 8080
   - **Type:** Serveur web statique

2. **Application Java (Thorntail)**
   - **Dossier:** `hello-java/`
   - **Port:** 8080
   - **Type:** Microservice REST

3. **Containers UBI (Red Hat)**
   - **ubi-info:** Affichage d'informations système
   - **ubi-sleep:** Container de test longue durée
   - **ubi-echo:** Container avec utilisateur non-root

#### Étapes AWS
1. **Créer un repository ECR**
   ```bash
   aws ecr create-repository --repository-name hello-world-node --region us-east-1
   ```

2. **Authentification ECR**
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   ```

3. **Tag et push des images**
   ```bash
   docker tag hello-world-node:v1 <account-id>.dkr.ecr.us-east-1.amazonaws.com/hello-world-node:v1
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/hello-world-node:v1
   ```

#### ✅ Livrables
- [ ] 4 images Docker construites et testées
- [ ] Images pushées sur Amazon ECR
- [ ] Documentation des commandes utilisées

---

## ☸️ Phase 2: Kubernetes Fondamentaux

### 🎯 Lab 3: Introduction à Kubernetes
**Dossier:** `labs-docker-k8s/1_IntroKubernetes/`

#### Objectifs
- Déployer des applications sur Kubernetes
- Comprendre les concepts de Pods et Deployments
- Utiliser kubectl pour la gestion

#### Configuration AWS EKS
1. **Créer un cluster EKS**
   ```bash
   eksctl create cluster --name esigelec-cluster --region us-east-1 --nodes 2
   ```

2. **Configurer kubectl**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name esigelec-cluster
   ```

#### Déploiements Kubernetes
1. **Pod simple** (`hello-world-create.yaml`)
   ```bash
   kubectl apply -f hello-world-create.yaml
   ```

2. **Deployment avec réplication** (`hello-world-apply.yaml`)
   ```bash
   kubectl apply -f hello-world-apply.yaml
   ```

#### ✅ Livrables
- [ ] Cluster EKS opérationnel
- [ ] Application déployée en Pods
- [ ] Deployment avec 3 répliques
- [ ] Service exposé et accessible

---

### 📈 Lab 4: Scaling et Mise à jour
**Dossier:** `labs-docker-k8s/2_K8sScaleAndUpdate/`

#### Objectifs
- Implémenter le scaling horizontal
- Gérer les mises à jour rolling
- Configurer des variables d'environnement

#### Fonctionnalités avancées
1. **Auto-scaling**
   ```bash
   kubectl autoscale deployment hello-world --cpu-percent=70 --min=2 --max=10
   ```

2. **Rolling updates**
   ```bash
   kubectl set image deployment/hello-world hello-world=<account-id>.dkr.ecr.us-east-1.amazonaws.com/hello-world-node:v2
   ```

3. **ConfigMaps** (`deployment-configmap-env-var.yaml`)
   ```bash
   kubectl create configmap app-config --from-literal=APP_ENV=production
   kubectl apply -f deployment-configmap-env-var.yaml
   ```

#### ✅ Livrables
- [ ] HPA (Horizontal Pod Autoscaler) configuré
- [ ] Rolling update réussi
- [ ] ConfigMaps appliquées
- [ ] Monitoring des métriques

---

## 🏗️ Phase 3: Microservices avec Open Liberty

### ☕ Lab 5: Architecture Microservices
**Dossier:** `lab-docker-microservices/`

#### Objectifs
- Comprendre l'architecture microservices
- Déployer des services Java avec Open Liberty
- Implémenter la communication inter-services

#### Services à déployer

1. **Service System** (`system/`)
   - **Port:** 9080
   - **Endpoint:** `/system/properties`
   - **Fonction:** Fournit les propriétés système

2. **Service Inventory** (`inventory/`)
   - **Port:** 9081
   - **Endpoint:** `/inventory/systems`
   - **Fonction:** Gère l'inventaire des systèmes

#### Configuration AWS
1. **Construire les images**
   ```bash
   cd system
   mvn liberty:package
   docker build -t system-service:v1 .
   
   cd ../inventory
   mvn liberty:package
   docker build -t inventory-service:v1 .
   ```

2. **Déploiement sur EKS**
   - Créer des services Kubernetes
   - Configurer les LoadBalancers
   - Implémenter service discovery

#### ✅ Livrables
- [ ] 2 microservices déployés
- [ ] Communication inter-services fonctionnelle
- [ ] Load balancing configuré
- [ ] Health checks implémentés

---

## 🚀 Phase 4: Déploiement Production AWS

### 🌐 Lab 6: Production sur AWS Fargate

#### Objectifs
- Déployer sans gestion de serveurs
- Configurer l'auto-scaling
- Implémenter la surveillance

#### Services AWS utilisés
- **Amazon EKS** - Orchestration Kubernetes
- **AWS Fargate** - Containers serverless
- **Amazon ECR** - Registry privé
- **Application Load Balancer** - Distribution du trafic
- **CloudWatch** - Monitoring et logs
- **AWS IAM** - Gestion des permissions

#### Architecture finale
```
Internet → ALB → EKS Fargate Pods → Services → ECR Images
                     ↓
               CloudWatch Logs & Metrics
```

#### ✅ Livrables
- [ ] Déploiement Fargate opérationnel
- [ ] Monitoring CloudWatch configuré
- [ ] Auto-scaling basé sur les métriques
- [ ] Sécurité IAM implémentée

---

## 📊 Métriques de réussite

### Indicateurs techniques
- **Disponibilité:** > 99.9%
- **Temps de réponse:** < 200ms
- **Scaling:** 2-10 répliques selon la charge
- **Déploiement:** Rolling update sans downtime

### Compétences acquises
- [x] Containerisation Docker
- [x] Orchestration Kubernetes
- [x] Microservices Java
- [x] Déploiement cloud AWS
- [x] Monitoring et observabilité
- [x] CI/CD et DevOps

---

## 🔧 Outils et prérequis

### Outils locaux
```bash
# Docker
docker --version

# Kubernetes
kubectl version --client

# AWS CLI
aws --version

# Maven (pour les microservices Java)
mvn --version
```

### Comptes et accès
- [x] Compte AWS avec permissions EKS/ECR/Fargate
- [x] kubectl configuré
- [x] Docker Desktop installé
- [x] IDE (VS Code recommandé)

---

## 📝 Ressources complémentaires

### Documentation officielle
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Open Liberty Guides](https://openliberty.io/guides/)

### Commandes de référence
- [Docker Cheat Sheet](https://github.com/wsargent/docker-cheat-sheet)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/)

---

## ✨ Prochaines étapes

1. **Commencer par le Lab 1** - Introduction Docker
2. **Suivre l'ordre séquentiel** des labs
3. **Valider chaque livrable** avant de passer au suivant
4. **Documenter les difficultés** rencontrées
5. **Tester en conditions réelles** sur AWS

---

*Roadmap créée le 6 novembre 2025 - Version 1.0*
*Repository: [Docker-K8S-Esigelec](https://github.com/marc1025-ui/Docker-K8S-Esigelec)*