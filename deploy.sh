#!/usr/bin/env sh

# 当发生错误时中止脚本
set -e

# 构建
npm run build:prod

# cd 到构建输出的目录下 
cd dist

# 部署到自定义域域名
# echo 'www.example.com' > CNAME

git init
git add .
git commit -m 'version1.0'

# 部署到 https://<USERNAME>.github.io
# git push -f git@github.com:<USERNAME>/<USERNAME>.github.io.git master
git push version1.0 git@github.com:dorasans/Amap-test.git
# 部署到 https://<USERNAME>.github.io/<REPO>
 git push -f git@github.com:dorasans/Amap-test.git master:gh-pages

cd -