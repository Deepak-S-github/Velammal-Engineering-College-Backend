#!/bin/bash

set -e

echo -e "\n\033[1;34m🚀 Starting Safe Deployment...\033[0m"

# ✅ Load environment variables from /root/.env
if [ -f "/root/.env" ]; then
  echo -e "\n\033[1;36m📦 Loading environment variables from /root/.env...\033[0m"
  set -a
  source /root/.env
  set +a
else
  echo -e "\n\033[0;31m❌ /root/.env file not found. Deployment aborted.\033[0m"
  exit 1
fi
  
# Variables
REPO_URL="https://github.com/SAMSDP/VEC_Landing.git"
CLONE_DIR=~/VEC_Landing
FRONTEND_DIR="$CLONE_DIR/Frontend"
BACKEND_DIR="$CLONE_DIR/Backend"
FRONTEND_TARGET="/var/www/html/Frontend"
BACKEND_TARGET="/var/www/Backend"

# Step 1: Cleanup old clone if exists
echo -e "\n\033[1;32m========== Cleaning old repo ==========\033[0m"
rm -rf "$CLONE_DIR"

# Step 2: Clone latest code
echo -e "\n\033[1;32m========== Cloning Frontend Repo ==========\033[0m"
git clone "$REPO_URL" "$CLONE_DIR"

# ================= FRONTEND ====================
echo -e "\n\033[1;32m========== Installing Frontend Dependencies ==========\033[0m"
cd "$FRONTEND_DIR"
npm install --legacy-peer-deps

echo -e "\n\033[1;32m========== Creating .env in Frontend ==========\033[0m"
cat <<EOF > "$FRONTEND_DIR/.env"
REACT_APP_BASE_URL=${REACT_APP_BASE_URL}
EOF

echo -e "\n\033[1;32m========== Building React App ==========\033[0m"
npm run build

# ================= BACKEND ====================
echo -e "\n\033[1;32m========== Stopping PM2 Backend Temporarily ==========\033[0m"
pm2 stop server.js || true

echo -e "\n\033[1;32m========== Installing Backend Dependencies ==========\033[0m"
cd "$BACKEND_DIR"
npm install --legacy-peer-deps

echo -e "\n\033[1;32m========== Creating .env in Backend ==========\033[0m"
cat <<EOF > "$BACKEND_DIR/.env"
MONGO_URI=${MONGO_URI}
DB_NAME=${DB_NAME}
CHAT_DB_NAME=${CHAT_DB_NAME}
PORT=${PORT}
BASE_EMAIL=${BASE_EMAIL}
PASSWORD=${PASSWORD}
TARGET_EMAIL=${TARGET_EMAIL}
ICELL_TARGET_EMAIL=${ICELL_TARGET_EMAIL}
GROQ_API_KEY_1=${GROQ_API_KEY_1}
GROQ_API_KEY_2=${GROQ_API_KEY_2}
GROQ_API_KEY_3=${GROQ_API_KEY_3}
GROQ_API_KEY_4=${GROQ_API_KEY_4}
GROQ_API_KEY_5=${GROQ_API_KEY_5}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
AWS_S3_NAME=${AWS_S3_NAME}
AWS_REGION=${AWS_REGION}
EOF

# ============= REPLACE FRONTEND & BACKEND ==============
echo -e "\n\033[1;32m========== Replacing Frontend ==========\033[0m"
sudo rm -rf "$FRONTEND_TARGET"
sudo mv "$FRONTEND_DIR" "$FRONTEND_TARGET"

echo -e "\n\033[1;32m========== Replacing Backend ==========\033[0m"
sudo rm -rf "$BACKEND_TARGET"
sudo mv "$BACKEND_DIR" "$BACKEND_TARGET"

# ============= RESTART SERVICES ==============
echo -e "\n\033[1;32m========== Restarting PM2 Backend ==========\033[0m"
cd "$BACKEND_TARGET"
pm2 start server.js || pm2 restart server.js
pm2 save

echo -e "\n\033[1;32m========== Restarting NGINX ==========\033[0m"
sudo systemctl restart nginx

cd ~
rm -rf VEC_Landing

echo -e "\n\033[1;32m========== ✅ Deployment Complete ==========\033[0m"
