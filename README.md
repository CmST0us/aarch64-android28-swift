# aarch64-unknown-linux-android28 Toolchain
Swift Toolchian for aarch64-unknown-linux-android28

# Current support Swift version

* `5.10.1`

# How to install in macOS host

1. Firstly you need to install official swift version `5.10.1`, download it from https://swift.org

2. Decompression file `swift-5.10.1-runtime-aarch64-unknown-linux-android28.tar.gz` into `/Library/Developer/Runtimes/aarch64-unknown-linux-android28`:
```bash
mkdir -p /Library/Developer/Runtimes/aarch64-unknown-linux-android28
tar xf swift-5.10.1-runtime-aarch64-unknown-linux-android28.tar.gz -C /Library/Developer/Runtimes/swift-5.10.1-runtime-aarch64-unknown-linux-android28
```

1. Generate destination json file:
```bash
cd Destinations
./generate_darwin.sh
# Enter runtime sdk install path: Library/Developer/Runtimes/swift-5.10.1-runtime-aarch64-unknown-linux-android28
# Enter the Swift compiler (swiftc) path: /path/to/offical/swift-5.10.1/swiftc
# Enter Enter the NDK(26d) installation path:
```

1. Copy generated destination json file:
```bash
mkdir -p /Library/Developer/Destinations
cp Destination/aarch64-android28-static.json /Library/Developer/Destinations
cp Destination/aarch64-android28.json /Library/Developer/Destinations
```

# How to test in android target

You need to upload runtime libraries into you aarch64 android device.
```
adb push /Library/Developer/Runtimes/swift-5.10.1-runtime-aarch64-unknown-linux-android28/usr/lib/swift/android/*.so /data/local/tmp

# Then you can build an test executable app using:
swift build --destination /Library/Developer/Destinations/aarch64-android28.json
adb push .build/debug/<YourApp> /data/local/tmp

# Then run in your android device
adb shell
cd /data/local/tmp
LD_LIBRARY_PATH=. ./<YourApp>
```

Also, you can build static. With static building, you not need to copy android swift runtime so.


# How to build App

Create an example project

```
swift package init --type executable
swift build --destination /Library/Developer/Destinations/aarch64-android28.json
```

Build Static
```
swift package init --type executable
swift build --destination /Library/Developer/Destinations/aarch64-android28-static.json --static-swift-stdlib
```

After building success, you can upload binary to you target device, and run it.


--------------
# How to build swift for aarch64-unknown-linux-android28

## Dependence

Build system: `Ubuntu 22.04`

### Install packages for compile

Reference: [https://github.com/apple/swift-docker/blob/main/swift-ci/master/ubuntu/22.04/Dockerfile]()

```bash
apt-get -y update && apt-get -y install \
  build-essential       \
  cmake                 \
  git                   \
  icu-devtools          \
  libcurl4-openssl-dev  \
  libedit-dev           \
  libicu-dev            \
  libncurses5-dev       \
  libpython3-dev        \
  libsqlite3-dev        \
  libxml2-dev           \
  ninja-build           \
  pkg-config            \
  python2               \
  python-six            \
  python2-dev           \
  python3-six           \
  python3-distutils     \
  python3-pkg-resources \
  python3-psutil        \
  rsync                 \
  swig                  \
  systemtap-sdt-dev     \
  tzdata                \
  uuid-dev              \
  zip
```

### Prepare compile workspace
Create an empty folder, which is used as our compile workspace.
```bash
mkdir workspace
cd workspace
export WORKSPACE_SWIFT_AARCH64_ANDROID=`pwd`
```

### Download NDK Toolchain
Be careful to the version of ndk, we need `26d`
```bash
cd $WORKSPACE_SWIFT_AARCH64_ANDROID
wget https://dl.google.com/android/repository/android-ndk-r26d-linux.zip
unzip android-ndk-r26d-linux.zip
```

### Prepare Ubuntu-base-22.04-armhf rootfs
Firstly, you need to install `qemu-user-static` for chroot.
```bash
sudo apt install qemu-user-static
```

### Download the same version of swift toolchain
For example, if we are compiling swift-5.10.1, we need to download offical version of swift-5.10.1.
```bash
cd $WORKSPACE_SWIFT_AARCH64_ANDROID
wget https://download.swift.org/swift-5.10.1-release/ubuntu2204/swift-5.10.1-RELEASE/swift-5.10.1-RELEASE-ubuntu22.04.tar.gz
tar xzf swift-5.10.1-RELEASE-ubuntu22.04.tar.gz
```

### Download swift source code
```bash
cd $WORKSPACE_SWIFT_AARCH64_ANDROID
mkdir swift-project
cd swift-project
git clone https://github.com/apple/swift.git swift
cd swift
utils/update-checkout --clone --tag swift-5.10.1-RELEASE
```

## Patch source code

### Apply patch
using patch `Patch/swift.patch`
```bash
cd $WORKSPACE_SWIFT_AARCH64_ANDROID/swift-project/swift
git apply /patch/to/repo/aarch64-android28-swift/Patch/swift.patch
```
using patch `Patch/swift-corelibs-foundation.patch`
```bash
cd $WORKSPACE_SWIFT_AARCH64_ANDROID/swift-project/swift-corelibs-foundation.path
git apply /patch/to/repo/aarch64-android28-swift/Patch/swift-corelibs-foundation.path
```

## Start build

### Build Swift
```bash
cd $WORKSPACE_SWIFT_AARCH64_ANDROID/swift-project/swift
export NDK_PATH=$WORKSPACE_SWIFT_AARCH64_ANDROID/android-ndk-r26d
export SWIFT_PATH=$WORKSPACE_SWIFT_AARCH64_ANDROID/swift-5.10.1-RELEASE-ubuntu22.04/usr/bin
export INSTALL_PATH=$WORKSPACE_SWIFT_AARCH64_ANDROID/install

utils/build-script --preset buildbot_linux_crosscompile_android,tools=RA,stdlib=RD,build,aarch64 \
	ndk_path=$NDK_PATH \
	toolchain_path=$SWIFT_PATH \
	install_destdir=$INSTALL_PATH \
	installable_package=$INSTALL_PATH/../aarch64-unknown-linux-android28-runtime.tar.gz
```

    TODO: If build error you need to copy ndk libclang-rt.so info swift-linux-x86_64/lib/linux

### Build libdispatch
#### Static
```bash
WORKSPACE_SWIFT_ANDROID=$WORKSPACE_SWIFT_AARCH64_ANDROID
NDK_PATH=$WORKSPACE_SWIFT_ANDROID/android-ndk-r26d
ABI="arm64-v8a"
INSTALL_DIR_PATH=$WORKSPACE_SWIFT_ANDROID/install
SWIFT_NATIVE_TOOLCHAIN_PATH=$WORKSPACE_SWIFT_ANDROID/swift-5.10.1-RELEASE-ubuntu22.04/usr/bin/
SWIFT_SOURCE_ROOT=$WORKSPACE_SWIFT_ANDROID/swift-project/
SWIFT_BUILD_PRODUCT_PATH=${SWIFT_SOURCE_ROOT}/build/buildbot_linux
NINJA_EXEC=$SWIFT_BUILD_PRODUCT_PATH/ninja-build/ninja

rm -rf $SWIFT_BUILD_PRODUCT_PATH/libdispatch-android-aarch64
mkdir -p $SWIFT_BUILD_PRODUCT_PATH/libdispatch-android-aarch64
cd $SWIFT_BUILD_PRODUCT_PATH/libdispatch-android-aarch64

cmake -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE=$NDK_PATH/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=$ABI \
    -DANDROID_NDK=$NDK_PATH \
    -DANDROID_PLATFORM=android-28 \
    \
    -DCMAKE_MAKE_PROGRAM=$NINJA_EXEC \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR_PATH}/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_SWIFT=ON \
    -DCMAKE_Swift_COMPILER="${SWIFT_NATIVE_TOOLCHAIN_PATH}/swiftc" \
    -DCMAKE_Swift_FLAGS="-target aarch64-unknown-linux-android28 -tools-directory ${NDK_PATH}/toolchains/llvm/prebuilt/linux-x86_64/bin/ -sdk ${NDK_PATH}/toolchains/llvm/prebuilt/linux-x86_64/sysroot -resource-dir $SWIFT_BUILD_PRODUCT_PATH/swift-linux-x86_64/lib/swift" \
    ../../../swift-corelibs-libdispatch

$NINJA_EXEC -C .
$NINJA_EXEC -C . install
```

#### Dynamic
```bash
WORKSPACE_SWIFT_ANDROID=$WORKSPACE_SWIFT_AARCH64_ANDROID
NDK_PATH=$WORKSPACE_SWIFT_ANDROID/android-ndk-r26d
ABI="arm64-v8a"
INSTALL_DIR_PATH=$WORKSPACE_SWIFT_ANDROID/install
SWIFT_NATIVE_TOOLCHAIN_PATH=$WORKSPACE_SWIFT_ANDROID/swift-5.10.1-RELEASE-ubuntu22.04/usr/bin/
SWIFT_SOURCE_ROOT=$WORKSPACE_SWIFT_ANDROID/swift-project/
SWIFT_BUILD_PRODUCT_PATH=${SWIFT_SOURCE_ROOT}/build/buildbot_linux
NINJA_EXEC=$SWIFT_BUILD_PRODUCT_PATH/ninja-build/ninja

rm -rf $SWIFT_BUILD_PRODUCT_PATH/libdispatch-android-aarch64
mkdir -p $SWIFT_BUILD_PRODUCT_PATH/libdispatch-android-aarch64
cd $SWIFT_BUILD_PRODUCT_PATH/libdispatch-android-aarch64

cmake -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE=$NDK_PATH/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=$ABI \
    -DANDROID_NDK=$NDK_PATH \
    -DANDROID_PLATFORM=android-28 \
    \
    -DCMAKE_MAKE_PROGRAM=$NINJA_EXEC \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR_PATH}/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_SWIFT=ON \
    -DCMAKE_Swift_COMPILER="${SWIFT_NATIVE_TOOLCHAIN_PATH}/swiftc" \
    -DCMAKE_Swift_FLAGS="-target aarch64-unknown-linux-android28 -tools-directory ${NDK_PATH}/toolchains/llvm/prebuilt/linux-x86_64/bin/ -sdk ${NDK_PATH}/toolchains/llvm/prebuilt/linux-x86_64/sysroot -resource-dir $SWIFT_BUILD_PRODUCT_PATH/swift-linux-x86_64/lib/swift" \
    ../../../swift-corelibs-libdispatch

$NINJA_EXEC -C .
$NINJA_EXEC -C . install
```

### Build Foundation
`TODO`

After building success, you can found sdk at `$WORKSPACE_SWIFT_AARCH64_ANDROID/install`

--------------
`Have fun and play with Swift everywhere!`
