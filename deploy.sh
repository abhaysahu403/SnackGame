#!/bin/bash
# deploy.sh — Build images, push to ECR, update ECS services
# Usage: ./deploy.sh <aws-account-id> <region>

set -e

ACCOUNT_ID=${1:-$(aws sts get-caller-identity --query Account --output text)}
REGION=${2:-us-east-1}
APP=gameapp

echo "🚀 Deploying GameApp to AWS"
echo "   Account: $ACCOUNT_ID  |  Region: $REGION"

# Login to ECR
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build & push frontend
echo "📦 Building frontend..."
docker build -t $APP-frontend ./frontend
docker tag $APP-frontend:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$APP-frontend:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$APP-frontend:latest

# Build & push backend
echo "📦 Building backend..."
docker build -t $APP-backend ./backend
docker tag $APP-backend:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$APP-backend:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$APP-backend:latest

# Force ECS service updates
echo "🔄 Updating ECS services..."
aws ecs update-service --cluster $APP-cluster --service $APP-frontend --force-new-deployment --region $REGION
aws ecs update-service --cluster $APP-cluster --service $APP-backend  --force-new-deployment --region $REGION

echo "✅ Deployment triggered! Check ECS console for status."
