# Obtener el Account ID de AWS
$AWS_ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text

# Región de AWS
$AWS_REGION = "us-east-1"

# Construir el proyecto con Maven
Write-Host "Construyendo el proyecto con Maven..."
cd ..
mvn clean package -DskipTests

# Inicializar Terraform
Write-Host "Inicializando Terraform..."
cd despliegue
terraform init

# Aplicar la infraestructura base
Write-Host "Aplicando infraestructura base..."
terraform apply -auto-approve

# Obtener la URL del repositorio ECR
$ECR_REPOSITORY = "demo-app"
$ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
$IMAGE_URL = "${ECR_URL}/${ECR_REPOSITORY}:latest"

# Login en ECR
Write-Host "Iniciando sesión en ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

# Construir la imagen Docker
Write-Host "Construyendo imagen Docker..."
cd ..
docker build -t $ECR_REPOSITORY .

# Etiquetar la imagen
Write-Host "Etiquetando imagen..."
docker tag ${ECR_REPOSITORY}:latest $IMAGE_URL

# Subir la imagen a ECR
Write-Host "Subiendo imagen a ECR..."
docker push $IMAGE_URL

# Obtener información del despliegue
Write-Host "Obteniendo información del despliegue..."
cd despliegue

# Obtener el endpoint de RDS
$RDS_ENDPOINT = terraform output -raw rds_endpoint
Write-Host "RDS Endpoint: $RDS_ENDPOINT"

# Crear la base de datos libreria_db usando una tarea ECS temporal
Write-Host "Creando base de datos libreria_db..."
$DB_INIT_TASK_DEF = @"
{
    "family": "db-init",
    "containerDefinitions": [{
        "name": "db-init",
        "image": "postgres:16",
        "command": ["psql", "-h", "$RDS_ENDPOINT", "-U", "postgres", "-c", "CREATE DATABASE libreria_db;"],
        "environment": [
            {
                "name": "PGPASSWORD",
                "value": "demo123456"
            }
        ],
        "essential": true
    }],
    "requiresCompatibilities": ["FARGATE"],
    "networkMode": "awsvpc",
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "$(terraform output -raw task_execution_role_arn)",
    "taskRoleArn": "$(terraform output -raw task_role_arn)"
}
"@

# Registrar la definición de tarea temporal
$DB_INIT_TASK_DEF_ARN = aws ecs register-task-definition --cli-input-json $DB_INIT_TASK_DEF --query 'taskDefinition.taskDefinitionArn' --output text

# Ejecutar la tarea temporal
Write-Host "Ejecutando tarea para crear la base de datos..."
$SUBNET_ID = terraform output -raw public_subnet_id
$SECURITY_GROUP_ID = terraform output -raw ecs_security_group_id

aws ecs run-task --cluster demo-cluster `
    --task-definition $DB_INIT_TASK_DEF_ARN `
    --launch-type FARGATE `
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}"

# Esperar un momento para que la tarea se complete
Start-Sleep -Seconds 30

# Esperar a que el servicio esté estable
Write-Host "Esperando a que el servicio ECS esté estable..."
Start-Sleep -Seconds 60

# Obtener la URL del servicio ECS
$TASKS = aws ecs list-tasks --cluster demo-cluster --service-name demo-service --query 'taskArns[0]' --output text
if ($TASKS -ne "None") {
    $TASK_ENI = aws ecs describe-tasks --cluster demo-cluster --tasks $TASKS --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text
    $PUBLIC_IP = aws ec2 describe-network-interfaces --network-interface-ids $TASK_ENI --query 'NetworkInterfaces[0].Association.PublicIp' --output text
} else {
    $PUBLIC_IP = "No tasks running yet"
}

Write-Host "============================================"
Write-Host "Despliegue completado!"
Write-Host "============================================"
Write-Host "URLs y endpoints importantes:"
Write-Host "Microservicio URL: http://${PUBLIC_IP}:8080"
Write-Host "Base de datos URL: ${RDS_ENDPOINT}"
Write-Host "Usuario BD: postgres"
Write-Host "Contraseña BD: demo123456"
Write-Host "Base de datos: libreria_db"
Write-Host "============================================"

# Verificar el estado del servicio ECS
Write-Host "Estado del servicio ECS:"
aws ecs describe-services --cluster demo-cluster --services demo-service --query 'services[0].status' --output text

# Verificar las tareas en ejecución
Write-Host "Tareas en ejecución:"
aws ecs list-tasks --cluster demo-cluster --service-name demo-service --output table 