
pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials("AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY = credentials("AWS_SECRET_ACCESS_KEY")
        AWS_DEFAULT_REGION = "us-east-1"
    }
    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Choose the action to perform: apply to create or update the EKS cluster, destroy to delete the EKS cluster'
        )
    }
    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    // Checkout code from GitHub repository
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/naveensilver/Terraform-Jenkins-EKS.git']])
                }
            }
        }
        stage('Initializing Terraform') {
            steps {
                script {
                    // Change directory to where the Terraform files are located
                    dir('EKS-Terraform') {
                        // Initialize Terraform to download provider plugins and set up the backend
                        sh 'terraform init'
                    }
                }
            }
        }
        stage('Formatting Terraform Code') {
            steps {
                script {
                    // Change directory to where the Terraform files are located
                    dir('EKS-Terraform') {
                        // Format Terraform configuration files
                        sh 'terraform fmt'
                    }
                }
            }
        }
        stage('Validating Terraform') {
            steps {
                script {
                    // Change directory to where the Terraform files are located
                    dir('EKS-Terraform') {
                        // Validate the Terraform configuration files to catch syntax errors and other issues
                        sh 'terraform validate'
                    }
                }
            }
        }
        stage('Previewing Infra using Terraform') {
            steps {
                script {
                    // Change directory to where the Terraform files are located
                    dir('EKS-Terraform') {
                        // Generate and show an execution plan without applying it
                        sh 'terraform plan'
                    }
                    // Pauses the pipeline and prompts for user input before proceeding
                    input(message: "Are you sure to Proceed?", ok: "Proceed") 
                }
            }
        }
        stage('Create/Destroy an EKS Cluster') {
            steps {
                script {
                    // Change directory to where the Terraform files are located
                    dir('EKS-Terraform') {
                        if (params.ACTION == 'apply') {
                            // Apply the Terraform plan to create or update resources
                            sh 'terraform apply --auto-approve'
                        } else if (params.ACTION == 'destroy') {
                            // Destroy the Terraform-managed infrastructure
                            sh 'terraform destroy --auto-approve'
                        }
                    }
                }
            }
        }
        stage('Update kubeconfig for EKS Cluster') {
            steps {
                script {
                    // Change directory to where the Kubernetes configuration files are located
                    dir('EKS-Terraform/ConfigurationFiles') {
                        // Update kubeconfig to use the specified EKS cluster
                        sh 'aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name my-eks-cluster --kubeconfig /var/lib/jenkins/.kube/config'
                    }
                }
            }
        }
        stage('Deploy Nginx App to EKS') {
            steps {
                withEnv(["KUBECONFIG=/var/lib/jenkins/.kube/config"]) {
                    script {
                        dir('EKS-Terraform/ConfigurationFiles') {
                            sh '''
                            kubectl apply -f deployment.yaml 
                            kubectl apply -f service.yaml
                            '''
                        }
                    }
                }
            }
        }
    }
}