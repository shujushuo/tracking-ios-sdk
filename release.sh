#!/bin/bash

# 确保传入版本号
VERSION=$1
if [ -z "$VERSION" ]; then
  echo "You must specify a version number, e.g. './release.sh 0.2.5'"
  exit 1
fi


# 创建或强制覆盖 Git tag（如果已有同名 tag，使用 -f 覆盖）
echo "Creating or overwriting Git tag v$VERSION..."
git tag -f "v$VERSION"

# 推送到远程仓库
echo "Pushing changes to remote repository..."
git push origin main
git push origin "v$VERSION" --force

# 进入到 SjsTrackingSDK 目录
cd SjsTrackingSDK

# 更新 Podspec 中的版本和 source 中的 tag
echo "Updating Podspec with version $VERSION..."
sed -i "" "s/s.version.*/s.version          = '$VERSION'/" SjsTrackingSDK.podspec
sed -i '' "s/tag => \'.*\'/tag => \'v$VERSION'/" SjsTrackingSDK.podspec

# 提交 Podspec 文件更新
echo "Committing Podspec file with version $VERSION..."
git add SjsTrackingSDK.podspec
git commit -m "Update Podspec for version $VERSION"

# 推送 Podspec 到 CocoaPods
echo "Pushing Podspec to CocoaPods..."
pod trunk push SjsTrackingSDK.podspec --skip-tests

# 返回到父目录
cd ..

echo "Release $VERSION completed."
