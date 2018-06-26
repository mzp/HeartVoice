use_frameworks!

abstract_target 'App' do
  pod 'SwiftLint'
  pod '※ikemen'

  target 'HeartVoice' do
    platform :ios, '11.0'
    pod 'NorthLayout', '~> 5'
    pod 'ReactiveCocoa'
    pod 'ReactiveSwift'
    pod 'BrightFutures'
  end

  target 'HeartVoice(macOS)' do
    platform :osx, '10.13'
    pod 'NorthLayout', '~> 5'
    pod 'ReactiveCocoa'
    pod 'ReactiveSwift'
    pod 'YesBDTime'
  end

  target 'HeartVoiceWatch Extension' do
    platform :watchos, '4.2'
    pod 'ReactiveSwift'
  end
end
