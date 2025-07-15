#!/bin/bash

set -e  # Exit if any command fails

echo -e "\n\033[1;34m🚀 Starting VEC DB Refresh Process...\033[0m"

# === STEP 1: DROP MONGO DATABASE ===
echo -e "\n\033[1;33m⚙️  Connecting to MongoDB and dropping VEC database...\033[0m"
mongosh <<EOF
use VEC
db.dropDatabase()
exit
EOF

# === STEP 2: GO TO ROOT AND CLONE BACKEND REPO ===
echo -e "\n\033[1;33m📦 Cloning Velammal Engineering College Backend Repository...\033[0m"
cd ~
rm -rf Velammal-Engineering-College-Backend
git clone https://github.com/Siddharth-magesh/Velammal-Engineering-College-Backend

echo -e "\n\033[1;33m🐍 Running awws.py inside database folder...\033[0m"
cd ~/Velammal-Engineering-College-Backend/database
python3 aws.py

# === STEP 4: DELETE CLONED REPO ===
echo -e "\n\033[1;31m🧹 Deleting cloned repo from system...\033[0m"
cd ~
rm -rf Velammal-Engineering-College-Backend

echo -e "\n\033[1;32m✅ VEC DB Refresh Complete.\033[0m"
