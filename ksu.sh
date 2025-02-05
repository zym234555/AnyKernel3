GIT_REPO="https://github.com/rifsxd/KernelSU-Next.git"

TAR_NAME=$(git -c 'versionsort.suffix=-' ls-remote --exit-code --refs --sort='version:refname' --tags $GIT_REPO | tail --lines=1 | cut --delimiter='/' --fields=3)

git clone --branch "$TAR_NAME" "$GIT_REPO" next

cd next

COMMIT_COUNT=$(git rev-list --count HEAD)

VERSION=$(echo $((1 * 10000 + "$COMMIT_COUNT" + 200)))

KSUNEXT_NAME="KernelSU_Next_"$TAR_NAME"_"$VERSION"-release.apk"

cd ..

wget https://github.com/rifsxd/KernelSU-Next/releases/download/"$TAR_NAME"/"$KSUNEXT_NAME"

mv "$KSUNEXT_NAME" KernelSU_Next.apk

SUSFS_REPO=$(git -c 'versionsort.suffix=-' ls-remote --exit-code --refs --sort='version:refname' --tags https://github.com/sidex15/susfs4ksu-module.git | tail --lines=1 | cut --delimiter='/' --fields=3)

wget https://github.com/sidex15/susfs4ksu-module/releases/download/"$SUSFS_REPO"/ksu_module_susfs_1.5.2+.zip

rm -rf ./next

rm -rf ksu.sh