pipeline {
    agent any

    environment {
        // IMPORTANT: Store these credentials securely in Jenkins using 'Credentials'
        DB_USER = credentials('ORACLE_USER').username
        DB_PASS = credentials('ORACLE_USER').password
        DB_DSN = 'localhost:1521/XE' 
        
        // **NEW**
        EC2_HOST = 'your.ec2.public.ip.or.dns' // <<-- REPLACE THIS
        EC2_USER = 'ec2-user' // or 'ubuntu', etc.
        EC2_CREDENTIALS_ID = 'EC2_SSH_KEY' // Jenkins credential ID for SSH private key
        
        APP_PATH = '/var/www/product-app'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Clone the repository
                git url: 'https://github.com/SanjayM08/Product-Catalog-Manager-.git', branch: 'main'
            }
        }
        
        // This stage does NOT need SSH, as it uses the SQL*Plus client on the Jenkins agent
        stage('Database Deployment (PL/SQL)') {
            steps {
                echo 'Deploying SQL and PL/SQL changes...'
                
                // 1. Run the Schema DDL
                sh "sqlplus ${env.DB_USER}/${env.DB_PASS}@${env.DB_DSN} @db/schema.sql"
                
                // 2. Deploy the PL/SQL Package
                sh "sqlplus ${env.DB_USER}/${env.DB_PASS}@${env.DB_DSN} @db/product_pkg.sql"
                
                echo 'Database objects updated successfully.'
            }
        }
        
        // *** REWORKED STAGE - Uses SSH for remote execution ***
        stage('Application Build & Deploy') {
            steps {
                echo "Deploying application files to ${env.EC2_HOST}..."
                
                // Copy files to the EC2 host using scp
                sh "scp -r app.py requirements.txt ${env.EC2_USER}@${env.EC2_HOST}:${env.APP_PATH}/"
                
                // Execute remaining steps on the remote EC2 host using the sshagent block
                sshagent(credentials: ["${env.EC2_CREDENTIALS_ID}"]) {
                    sh """
                        ssh ${env.EC2_USER}@${env.EC2_HOST} "
                            echo 'Running remote deployment steps...'
                            
                            # 1. Create deployment directory (if it doesn't exist)
                            sudo mkdir -p ${env.APP_PATH}
                            
                            # NOTE: Files are already copied via scp above.
                            
                            # 2. Install Python dependencies
                            sudo pip3 install -r ${env.APP_PATH}/requirements.txt
                            
                            # 3. Set environment variables for the application user (Security Note: Use a better secret management system for production)
                            echo 'DB_USER=${env.DB_USER}' > ${env.APP_PATH}/.env
                            echo 'DB_PASS=${env.DB_PASS}' >> ${env.APP_PATH}/.env
                            echo 'DB_DSN=${env.DB_DSN}' >> ${env.APP_PATH}/.env
                        "
                    """
                }
                echo 'Application files deployed successfully.'
            }
        }
        
        // *** REWORKED STAGE - Uses SSH to restart service remotely ***
        stage('Restart Application Service') {
            steps {
                echo "Restarting service on ${env.EC2_HOST}..."

                sshagent(credentials: ["${env.EC2_CREDENTIALS_ID}"]) {
                    sh """
                        ssh ${env.EC2_USER}@${env.EC2_HOST} "
                            sudo systemctl restart product-app-flask.service
                        "
                    """
                }
                echo 'Application service restarted.'
            }
        }
    }
}
