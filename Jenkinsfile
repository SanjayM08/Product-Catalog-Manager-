stage('Database Deployment (PL/SQL)') {
            steps {
                echo 'Deploying SQL and PL/SQL changes...'
                
                withCredentials([
                    usernamePassword(credentialsId: 'ORACLE_USER', usernameVariable: 'DB_USR', passwordVariable: 'DB_PWD')
                ]) {
                    // 1. Run the Schema DDL
                    // ESCAPE THE $ FOR BASH:
                    sh "sqlplus \${env.DB_USR}/\${env.DB_PWD}@\${env.DB_DSN} @db/schema.sql" 
                    
                    // 2. Deploy the PL/SQL Package
                    // ESCAPE THE $ FOR BASH:
                    sh "sqlplus \${env.DB_USR}/\${env.DB_PWD}@\${env.DB_DSN} @db/product_pkg.sql"
                
                    echo 'Database objects updated successfully.'
                }
            }
        }
