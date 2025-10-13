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
  s.homepage         = 'https://github.com/Osamah-Attiah/bas_pay_ios'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'YKB' => 'osama.mtm77@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
# s.vendored_frameworks = 'Frameworks/bas_pay.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'


  s.prepare_command = <<-CMD
    set -e # Exit immediately if a command exits with a non-zero status.

    ZIP_URL="https://github.com/Osamah-Attiah/bas_pay_ios/releases/latest/download/bas_pay.xcframework.zip"
#   ZIP_URL="https://github.com/Osamah-Attiah/bas_pay_ios/releases/download/bas_pay_ios/bas_pay.xcframework.zip"

    DEST_DIR_NAME="Frameworks" # Name of the directory to unzip into
    FRAMEWORK_NAME="bas_pay.xcframework" # The name of the framework inside the zip

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

  CMD

  s.vendored_frameworks = 'Frameworks/bas_pay.xcframework'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'


end
