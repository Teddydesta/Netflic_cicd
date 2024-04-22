pipeline{
    
    agent any
    
    tools{
        jdk 'jdk17'
        nodejs 'NodeJs'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    
    stages{
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/Teddydesta/Netflic_cicd.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix '''
                }
            }
        }
        stage('quality gate'){
            steps {
               script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token' 
                }
            }
        
    }
     
        stage('Install Dependencies'){
            steps {
                sh 'npm install'
            }
        
    }
     
        stage('OWASP FS SCAN'){
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                
        }
    }
    stage('TRIVY FS SCAN'){
        steps{
            sh 'trivy fs . > trivyfs.txt'
        }
    }
    stage('Docker Build and Push'){
        steps{
            script{
                withDockerRegsitry(credentialsId: 'docker', toolName: 'docker'){
                    sh 'docker build --build-arg TMDB_V3_API_KEY=23dd1c24e155676db8c322e9f8968084 -t netflix .'
                    sh 'docker tag netflix teddy2000/netflix:latest'
                    sh 'docker push teddy2000/netflix:latest'
                }
            }
        }
    }
    stage('TRIVY'){
        steps{
            sh 'trivy image teddy2000/netflix:latest >trivyimage.txt'
        }
    }
    stage ('Deploy to container'){
        steps{
            sh 'docker run -d --name netflix -p 8081:8081 teddy2000/netflix:latest'
            
            
        }
    }
}
     post{
         always{
             emailtext attachLog: true,
             subject: "'${currentBuild.result}'",
             body: "Project: ${env.JOB_NAME}<br/>" + 
             "Build Number: ${env.BUILD_NUMBER} <br/>" +
             "URL: ${env.BUILD_URL} <br/>",
             to: 'teddydesta2021@gmail.com',
             attachmentsPattern: 'trivy.txt'
         }
     }
}