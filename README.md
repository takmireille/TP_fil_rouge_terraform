# TP_fil_rouge_terraform
sujet: Créer un cluster kubernetes en utilisant terraform, ansible sur aws sans passer  par le service eks
1- objectifs: 
- utilisation de terraform pour decrir et creer l'infrastructutre aws.
- utlisation de ansible pour configurer et provisionner les differentes instences (master et worker) dans kubernetes

2- Workflow
2-1 pre-requis
- se creer un compte aws
- configurer aws sur sa machine de developpment (asw configure)
- installer terraform et ansible sur sa machine

2-3 definir l'infrastructure avec Terraform

Dans le fichier de configutation terraform (terraform_config_aws.tf), la partie infrastructure est definit comme suit:

-------> la partie introductive
- declaration du proviser aws et des varibles (clées) de connection au comptes aws
---------> la partie network
- creation d'un vpc
- creation d'un subnet (pour les deux instances worker et master)
- creation d'une table de routage
- creation d'une internet gateway
---------> partie creation des instances ec2
- creation d'une clé ssh en local
- creation d'un groupe de securité
- creation des instances ec2 qui sont bien sur reliées au subnet ----> vpc-----> internet gateway

2-3 quelques ressources utlisées : 
- https://adyraj.medium.com/kubernetes-cluster-on-multi-cloud-using-terraform-and-ansible-9cfa51992d6d
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- https://docs.ansible.com/ansible/latest/collections/amazon/aws/docsite/aws_ec2_guide.html
- ...
3- configuration du cluster kubernetes avec ansible
