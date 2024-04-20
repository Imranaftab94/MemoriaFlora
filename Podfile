# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Caro Estinto' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MemoriaFlora
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift5'
  pod 'IQKeyboardManager'
  pod 'Firebase'
  pod 'FirebaseCore'
  pod 'Firebase/Auth'
  pod 'Firebase/DynamicLinks'
  pod 'FirebaseDatabase'
  pod 'FirebaseMessaging'
  pod 'Firebase/Storage'
  pod 'Kingfisher'

  post_install do |installer|
      installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              end
          end
      end
  end
end
