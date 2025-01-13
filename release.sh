#!/bin/bash

# 确保传入版本号
VERSION=$1
if [ -z "$VERSION" ]; then
  echo "You must specify a version number, e.g. './release.sh 0.2.5'"
  exit 1
fi

# 获取当前 Git tag
TAG=$(git describe --tags --abbrev=0)
if [ "$TAG" != "v$VERSION" ]; then
  echo "Error: Git tag ($TAG) does not match the specified version ($VERSION)."
  echo "Please create the correct tag first using 'git tag v$VERSION'."
  exit 1
fi

# 进入到 SjsTrackingSDK 目录
cd SjsTrackingSDK

# 更新 Podspec 中的版本
echo "Updating Podspec with version $VERSION..."
sed -i "" "s/s.version.*/s.version          = '$VERSION'/" SjsTrackingSDK.podspec

# 提交 Podspec 文件更新
echo "Committing Podspec file with version $VERSION..."
git add SjsTrackingSDK.podspec
git commit -m "Update Podspec for version $VERSION"

# 创建 Git tag
echo "Creating Git tag v$VERSION..."
git tag -f "v$VERSION"

# 推送到 Git 和 CocoaPods
echo "Pushing changes to remote repository..."
git push origin master
git push --force origin "v$VERSION"

# 推送 Podspec 到 CocoaPods
# echo "Pushing Podspec to CocoaPods..."
# pod trunk push SjsTrackingSDK.podspec --skip-tests

# 返回到父目录
cd ..

echo "Release $VERSION completed."
