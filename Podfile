platform :ios, '8.0'
use_frameworks!

target 'AIBot' do
   pod 'ApiAI'
   pod 'JSQMessagesViewController'
   pod 'RealmSwift'
  post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
end
