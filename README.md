# 🎮 GameApp — Full-Stack Snake Game

A complete full-stack application with a **Snake game**, **user auth**, **leaderboard**, and **Docker + Terraform** deployment — built for DevOps practice on AWS ECS/EC2.

## 📁 Project Structure

```
gameapp/
├── frontend/          # HTML/CSS/JS Snake game + auth UI
│   ├── index.html     # Single-page app
│   ├── nginx.conf     # Nginx config
│   └── Dockerfile
├── backend/           # Node.js + Express REST API
│   ├── server.js
│   ├── db.js          # PostgreSQL connection + init
│   ├── routes/
│   │   ├── auth.js    # /api/auth/register, /login, /me
│   │   └── scores.js  # /api/scores (save, leaderboard, mine)
│   ├── middleware/
│   │   └── auth.js    # JWT middleware
│   ├── .env.example
│   └── Dockerfile
├── terraform/         # AWS ECS on EC2 infra
│   ├── main.tf        # ECS, ALB, RDS, ECR, IAM, ASG
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── docker-compose.yml # Local dev — all 3 services
├── deploy.sh          # Build + push to ECR + ECS update
└── README.md
```

## 🚀 Quick Start (Local)

### Prerequisites
- Docker + Docker Compose
- Node.js 18+ (optional, for local dev without Docker)

### Run locally with Docker Compose
```bash
# Clone the repo
git clone <your-repo-url>
cd gameapp

# Start everything (DB + backend + frontend)
docker-compose up --build

# Open http://localhost in your browser
```

That's it! The app will:
1. Start PostgreSQL on port 5432
2. Start the backend API on port 5000 (auto-creates DB tables)
3. Start the frontend on port 80

### Run backend locally (no Docker)
```bash
cd backend
cp .env.example .env        # Edit DB credentials if needed
npm install
npm run dev                 # Runs on http://localhost:5000
```

## 🌐 API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | /health | No | Health check |
| POST | /api/auth/register | No | Register new user |
| POST | /api/auth/login | No | Login, get JWT |
| GET | /api/auth/me | JWT | Get current user |
| POST | /api/scores | JWT | Save game score |
| GET | /api/scores/leaderboard/:game | No | Top 10 scores |
| GET | /api/scores/me | JWT | My score history |

## 🐳 Docker

### Build images manually
```bash
docker build -t gameapp-backend ./backend
docker build -t gameapp-frontend ./frontend
```

### Docker Compose (all services)
```bash
docker-compose up --build      # Start
docker-compose down            # Stop
docker-compose down -v         # Stop + remove volumes
```

## ☁️ AWS Deployment (Terraform + ECS)

### Architecture
```
Internet → ALB (port 80)
  ├── /api/* → ECS backend service (port 5000) → RDS PostgreSQL
  └── /*     → ECS frontend service (port 80)
                        ↓
               EC2 Auto Scaling Group (ECS-optimized AMI)
```

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.3 installed
- Docker installed

### Step 1 — Provision infrastructure
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

### Step 2 — Build & push images to ECR
```bash
# From project root
./deploy.sh <your-aws-account-id> us-east-1

# Or manually:
ACCOUNT=123456789012
REGION=us-east-1

aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com

docker build -t gameapp-frontend ./frontend
docker tag gameapp-frontend:latest $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/gameapp-frontend:latest
docker push $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/gameapp-frontend:latest

docker build -t gameapp-backend ./backend
docker tag gameapp-backend:latest $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/gameapp-backend:latest
docker push $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/gameapp-backend:latest
```

### Step 3 — Access the app
```bash
terraform output app_url   # Get the ALB URL
```

### Tear down
```bash
terraform destroy
```

## 🗄️ Database Schema

```sql
-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Scores table
CREATE TABLE scores (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  game VARCHAR(50) NOT NULL,
  score INTEGER NOT NULL,
  played_at TIMESTAMP DEFAULT NOW()
);
```

## 🎮 Game Features

- **Snake game** with arrow keys / WASD / mobile D-pad
- Levels that increase speed every 50 points
- Scores saved to DB when logged in
- Live leaderboard (top 10 per game)
- Guest play (no login required, scores not saved)
- Local best score saved in browser

## 🔧 Environment Variables

### Backend
| Variable | Default | Description |
|----------|---------|-------------|
| PORT | 5000 | Server port |
| DB_HOST | localhost | PostgreSQL host |
| DB_PORT | 5432 | PostgreSQL port |
| DB_NAME | gameapp | Database name |
| DB_USER | postgres | DB username |
| DB_PASSWORD | postgres | DB password |
| JWT_SECRET | supersecret | JWT signing secret |
| FRONTEND_URL | * | CORS allowed origin |

## 📝 Notes for DevOps Practice

- Swap `docker-compose.yml` to practice Docker networking
- Use `terraform workspace` for multiple environments (dev/staging/prod)  
- Add GitHub Actions CI/CD using `deploy.sh` as the deployment step
- The ALB listener rules show how to route `/api/*` vs frontend traffic
- RDS is in a private subnet — only accessible from the EC2 security group
