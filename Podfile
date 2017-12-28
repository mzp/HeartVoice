use_frameworks!

abstract_target 'App' do
  pod 'SwiftLint'

  target 'HeartVoice' do
    platform :ios, '11.0'
    pod 'NorthLayout', '~> 5'
    pod 'ReactiveCocoa'
    pod 'ReactiveSwift'
  end

  target 'HeartVoice(macOS)' do
    platform :osx, '10.13'
    pod 'NorthLayout', '~> 5'
    pod 'ReactiveSwift'
  end

  target 'HeartVoiceWatch Extension' do
    platform :watchos, '4.2'
    pod 'ReactiveSwift'
  end
end
