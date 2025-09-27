pipeline {
    agent any

    environment {
        // Correct: These are simple string assignments
        DB_DSN = 'localhost:1521/XE' // Example DSN for Oracle XE
        
        // Correct: These are simple string assignments
        EC2_HOST = 'your.ec2.public.ip.or.dns' 
        EC2_USER = 'ec2-user'
        EC2_CREDENTIALS_ID = 'EC2_SSH_KEY'
        
        APP_PATH = '/var/www/product-app'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Clone the repository
                git url: 'https://github.com/SanjayM08/Product-Catalog-Manager-.git', branch: 'main'
            }
        }
        
        stage('Database Deployment (PL/SQL)') {
            steps {
                echo 'Deploying SQL and PL/SQL changes...'
                
                // *** FIX APPLIED HERE: Use withCredentials to bind the variables ***
                withCredentials([
                    // Bind the Username/Password pair credential with ID 'ORACLE_USER' 
                    // to temporary environment variables 'DB_USR' and 'DB_PWD'
                    // NOTE: I'm using temporary names (DB_USR/DB_PWD) to avoid conflicts, 
                    // though it's optional if you remove the previous environment block vars.
                    usernamePassword(credentialsId: 'ORACLE_USER', usernameVariable: 'DB_USR', passwordVariable: 'DB_PWD')
                ]) {
                    // 1. Run the Schema DDL
                    // Now, reference the temporary environment variables defined above
                    sh "sqlplus ${env.DB_USR}/${env.DB_PWD}@${env.DB_DSN} @db/schema.sql"
                    
                    // 2. Deploy the PL/SQL Package
                    sh "sqlplus ${env.DB_USR}/${env.DB_PWD}@${env.DB_DSN} @db/product_pkg.sql"
                
                    echo 'Database objects updated successfully.'
                }
            }
        }
        
        stage('Application Build & Deploy') {
            steps {
                echo "Deploying application files to ${env.EC2_HOST}..."
                
                // Copy files to the EC2 host using scp
                sh "scp -r app.py requirements.txt ${env.EC2_USER}@${env.EC2_HOST}:${env.APP_PATH}/"
                
                // We must use withCredentials here too, to expose the ORACLE DB credentials 
                // so they can be written to the remote .env file.
                withCredentials([
                    usernamePassword(credentialsId: 'ORACLE_USER', usernameVariable: 'DB_USR', passwordVariable: 'DB_PWD')
                ]) {
                    sshagent(credentials: ["${env.EC2_CREDENTIALS_ID}"]) {
                        sh """
                            ssh ${env.EC2_USER}@${env.EC2_HOST} "
                                echo 'Running remote deployment steps...'
                                
                                # ... (other remote commands)
                                
                                # 3. Set environment variables for the application user
                                # IMPORTANT: Note the use of ${DB_USR} and ${DB_PWD} inside the remote script
                                echo 'DB_USER=${DB_USR}' > ${env.APP_PATH}/.env
                                echo 'DB_PASS=${DB_PWD}' >> ${env.APP_PATH}/.env
                                echo 'DB_DSN=${env.DB_DSN}' >> ${env.APP_PATH}/.env
                            "
                        """
                    }
                } // End of withCredentials block
                echo 'Application files deployed successfully.'
            }
        }
        
        stage('Restart Application Service') {
            steps {
                echo "Restarting service on ${env.EC2_HOST}..."

                sshagent(credentials: ["${env.EC2_CREDENTIALS_ID}"]) {
                    sh "ssh ${env.EC2_USER}@${env.EC2_HOST} \"sudo systemctl restart product-app-flask.service\""
                }
                echo 'Application service restarted.'
            }
        }
    }
}
