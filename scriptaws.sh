#!/bin/bash

# Variables
DB_INSTANCE_IDENTIFIER="myinstancemoti"
DB_ENGINE="mysql"
DB_MASTER_USERNAME="root"
DB_MASTER_PASSWORD="rooot1234"
DB_NAME="dbsaidi"
DB_INSTANCE_CLASS="db.t2.micro"
DB_ALLOCATED_STORAGE=20
DB_PORT=3306

# Create a security group to allow connection from MySQL Workbench
aws ec2 create-security-group \
    --group-name mysql-workbench-sg \
    --description "Grupo de seguridad para MySQL Workbench"

# Get the ID of the newly created security group
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --group-names mysql-workbench-sg --query "SecurityGroups[0].GroupId" --output text)

# Authorize traffic on the database port from MySQL Workbench
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port $DB_PORT \
    --cidr 0.0.0.0/0
# Create RDS database instance
aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
    --db-instance-class $DB_INSTANCE_CLASS \
    --engine $DB_ENGINE \
    --master-username $DB_MASTER_USERNAME \
    --master-user-password $DB_MASTER_PASSWORD \
    --allocated-storage $DB_ALLOCATED_STORAGE \
    --vpc-security-group-ids $SECURITY_GROUP_ID \
    --db-name $DB_NAME \
    --port $DB_PORT

# Wait until the instance is available
echo "Esperando a que la instancia de la base de datos esté disponible..."
aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE_IDENTIFIER
echo "La instancia de la base de datos está disponible."

# Get the endpoint of the database instance
DB_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_IDENTIFIER --query "DBInstances[0].Endpoint.Address" --output text)


echo "The database instance has been created, and the security group for MySQL Workbench has been configured."
echo "Database endpoint: $DB_ENDPOINT"
echo "Security group ID: $SECURITY_GROUP_ID"
