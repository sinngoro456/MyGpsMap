platform :ios, '9.0'

target 'MyGpsMap' do
  use_frameworks!
  
  # Pods for MyGpsMap
  pod 'Alamofire'
  pod 'AWSS3'
  pod 'AWSAppSync', '~> 3.0.0'
pod 'AWSCore', '~> 2.12.0'
  
  target 'MyGpsMapTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MyGpsMapUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "16.6"
    end
  end
end
