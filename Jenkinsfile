pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {

        stage('Clone Repo') {
            steps {
                git 'https://github.com/Kennyjaymes/first-jenkins-project.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds'
                    ]]) {
                        sh '''
                        terraform init
                        terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Get Public IP') {
            steps {
                script {
                    EC2_IP = sh(
                        script: "cd terraform && terraform output -raw public_ip",
                        returnStdout: true
                    ).trim()
                    echo "EC2 IP: ${EC2_IP}"
                }
            }
        }

        stage('Deploy App') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh """
                    scp -r app/* ec2-user@${EC2_IP}:/home/ec2-user/

                    ssh ec2-user@${EC2_IP} '
                    docker build -t myapp .
                    docker run -d -p 80:80 myapp
                    '
                    """
                }
            }
        }
    }
}
