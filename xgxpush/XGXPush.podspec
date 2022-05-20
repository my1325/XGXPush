#
# Be sure to run `pod lib lint XGXPush.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XGXPush'
  s.version          = '0.1.3'
  s.summary          = 'A short description of XGXPush.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://172.16.170.10:3080/mayong/XGXPush.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'my' => '1173962595@qq.com' }
  s.source           = { :git => 'http://172.16.170.10:3080/mayong/XGXPush.git', :tag => s.version.to_s }
  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'
  s.default_subspec = 'Core'
  s.static_framework = true
  s.pod_target_xcconfig = { 'SWIFT_COMPILATION_MODE' => 'wholemodule' }

  s.subspec 'Core' do |ss|
      ss.source_files = 'XGXPush/Classes/Core/*.swift'
  end
  
  s.subspec 'JPush' do |ss|
      ss.source_files = 'XGXPush/Classes/JPush/*'
      ss.dependency 'XGXPush/Core'
      # ss.dependency 'XGXPushJPush', '0.1.2'
      ss.dependency 'JPush'
      ss.dependency 'JCore'
      ss.preserve_paths = ['Module/module.modulemap', 'Module/BridgeHeader.h']
      ss.pod_target_xcconfig = {
      # 本地开发时为改值
        'SWIFT_INCLUDE_PATHS' => ['$(PODS_ROOT)/XGXPush/Module', '$(PODS_TARGET_SRCROOT)/XGXPush/Module'],
        'ENABLE_BITCODE' => 'NO', #配置Bitcode为NO  
      }
  end

  s.subspec 'GeTuiPush' do |ss| 
    ss.source_files = 'XGXPush/Classes/GeTuiPush/*'
    ss.dependency 'XGXPush/Core'
    # ss.dependency 'XGXPushGeTui', '0.1.1'
    ss.preserve_paths = ['GeTuiModule/module.modulemap', 'GeTuiModule/BridgeHeader.h']
    ss.dependency 'GTSDK', '2.4.5-noidfa'
      ss.pod_target_xcconfig = {
      # 本地开发时为改值
        'SWIFT_INCLUDE_PATHS' => ['$(PODS_ROOT)/XGXPush/GeTuiModule', '$(PODS_TARGET_SRCROOT)/XGXPush/GeTuiModule'],
        'ENABLE_BITCODE' => 'NO', #配置Bitcode为NO  
      }

  end 
end
