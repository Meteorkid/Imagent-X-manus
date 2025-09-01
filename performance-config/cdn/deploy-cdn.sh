#!/bin/bash

# CDN部署脚本

set -e

echo "🚀 开始部署CDN资源..."

# 配置变量
CDN_PROVIDER="cloudflare"
STATIC_DOMAIN="cdn.imagentx.ai"
IMAGES_DOMAIN="img.imagentx.ai"
FONTS_DOMAIN="fonts.imagentx.ai"

# 构建前端项目
echo "📦 构建前端项目..."
cd imagentx-frontend-plus
npm run build

# 上传静态资源到CDN
echo "📤 上传静态资源到CDN..."
aws s3 sync out/ s3://$STATIC_DOMAIN --delete --cache-control "public, max-age=31536000, immutable"

# 上传图片资源
echo "🖼️  上传图片资源..."
aws s3 sync public/images/ s3://$IMAGES_DOMAIN --delete --cache-control "public, max-age=31536000, immutable"

# 上传字体资源
echo "🔤 上传字体资源..."
aws s3 sync public/fonts/ s3://$FONTS_DOMAIN --delete --cache-control "public, max-age=31536000, immutable"

# 刷新CDN缓存
echo "🔄 刷新CDN缓存..."
if [ "$CDN_PROVIDER" = "cloudflare" ]; then
    # Cloudflare缓存刷新
    curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"purge_everything":true}'
elif [ "$CDN_PROVIDER" = "aws" ]; then
    # AWS CloudFront缓存刷新
    aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
fi

echo "✅ CDN部署完成！"
