#!/bin/bash

# 提示用户输入路径
read -p "Enter the Swift Android Runtime SDK installation path: " swift_sdk_path
read -p "Enter the Swift compiler (swiftc) path: " swift_compiler_path
read -p "Enter the NDK installation path: " ndk_path

# 生成JSON文件内容
json_content=$(cat <<EOF
{
    "version": 1,
    "sdk": "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/sysroot",
    "sysroot-flag": "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/sysroot",
    "toolchain-bin-dir": "$swift_compiler_path",
    "target": "aarch64-unknown-linux-android28",
    "dynamic-library-extension": "so",
    "extra-cc-flags": [
        "-isystem", "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/lib/clang/17/include/",
        "-isystem", "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include/"
    ],
    "extra-swiftc-flags": [
        "-target", "aarch64-unknown-linux-android28",
        "-tools-directory", "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/bin/",
        "-resource-dir", "$swift_sdk_path/usr/lib/swift",
        "-lstdc++", "-landroid", "-llog"
    ],
    "extra-cpp-flags": [
        "-isystem", "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/lib/clang/17/include/"
    ]
}
EOF
)

json_content_static=$(cat <<EOF
{
    "version": 1,
    "sdk": "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/sysroot",
    "sysroot-flag": "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/sysroot",
    "toolchain-bin-dir": "$swift_compiler_path",
    "target": "aarch64-unknown-linux-android28",
    "dynamic-library-extension": "so",
    "extra-cc-flags": [
        "-isystem", "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/lib/clang/17/include/",
        "-isystem", "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include/"
    ],
    "extra-swiftc-flags": [
        "-target", "aarch64-unknown-linux-android28",
        "-tools-directory", "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/bin/",
        "-resource-dir", "$swift_sdk_path/usr/lib/swift_static",
        "-lstdc++", "-landroid", "-llog"
    ],
    "extra-cpp-flags": [
        "-isystem", "$ndk_path/toolchains/llvm/prebuilt/darwin-x86_64/lib/clang/17/include/"
    ]
}
EOF
)

# 将JSON内容写入文件
output_file="aarch64-android28.json"
echo "$json_content" > "$output_file"
echo "JSON file generated: $output_file"

output_file_static="aarch64-android28-static.json"
echo "$json_content_static" > "$output_file_static"
echo "JSON file generated: $output_file_static"
