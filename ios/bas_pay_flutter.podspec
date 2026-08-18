#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint bas_pay_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'bas_pay_flutter'
  s.version          = '1.0.0'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'https://github.com/BasPlatform/BasPayment-IOS'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bas' => 'alabbasidev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'bas_pay_flutter/Sources/bas_pay_flutter/**/*.swift'
  s.resource_bundles = {
    'bas_pay_flutter_privacy' => ['bas_pay_flutter/Sources/bas_pay_flutter/PrivacyInfo.xcprivacy']
  }
# s.vendored_frameworks = 'Frameworks/bas_pay.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'


  s.prepare_command = <<-CMD
    set -e # Exit immediately if a command exits with a non-zero status.

    DEST_DIR_NAME="Frameworks" # Name of the directory to unzip into
    FRAMEWORK_NAME="bas_pay.xcframework" # The name of the framework inside the zip

    ZIP_URL="https://github.com/BasPlatform/BasPayment-IOS/releases/latest/download/bas_pay.xcframework.zip"

    rm -rf "${DEST_DIR_NAME}"
    rm -f "${FRAMEWORK_NAME}".zip

    curl -L "${ZIP_URL}" -o "${FRAMEWORK_NAME}".zip

    mkdir -p "${DEST_DIR_NAME}"

    unzip -q "${FRAMEWORK_NAME}.zip" -d "${DEST_DIR_NAME}"
#     unzip -q "${FRAMEWORK_NAME}".zip "${FRAMEWORK_NAME}"* -d "${DEST_DIR_NAME}"

    rm "${FRAMEWORK_NAME}".zip

    if [ ! -d "${DEST_DIR_NAME}/${FRAMEWORK_NAME}" ]; then
      echo "Error: ${FRAMEWORK_NAME} not found in ${DEST_DIR_NAME} after unzipping."
      echo "Contents of ${DEST_DIR_NAME}:"
      ls -lR "${DEST_DIR_NAME}"
      exit 1
    fi

    # SPM embed validation rejects underscores in CFBundleIdentifier.
    find "${DEST_DIR_NAME}/${FRAMEWORK_NAME}" -name Info.plist -print0 | while IFS= read -r -d '' plist; do
      if /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist" 2>/dev/null | grep -q 'com.superstore.bas_pay'; then
        /usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.superstore.baspay' "$plist"
      fi
    done

  CMD

  s.vendored_frameworks = 'Frameworks/bas_pay.xcframework'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    # Kotlin XCFramework is arm64-only. Leaving x86_64 enabled makes CocoaPods skip the
    # simulator slice copy, so Swift cannot import bas_pay.
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 x86_64',
    # Xcode 26 Swift explicit modules cannot resolve the Kotlin/Native Clang module.
    'SWIFT_ENABLE_EXPLICIT_MODULES' => 'NO',
  }
  s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 x86_64',
  }
  s.swift_version = '5.0'


end
