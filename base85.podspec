Pod::Spec.new do |s|
  s.name             = 'base85'
  s.version          = '1.0.0'
  s.summary          = 'Swift library for ASCII85 and Z85 encoding/decoding'
  s.homepage         = 'https://github.com/batonPiotr/base85'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Pawel Sulik' => 'pawelsulik@gmail.com' }
  s.source           = { :git => 'https://github.com/batonPiotr/base85.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'
  s.source_files = 'Sources/base85/**/*'
end
