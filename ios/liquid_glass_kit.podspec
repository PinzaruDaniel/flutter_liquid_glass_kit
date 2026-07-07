Pod::Spec.new do |spec|
  spec.name             = 'liquid_glass_kit'
  spec.version          = '0.1.0'
  spec.summary          = 'Native iOS Liquid Glass and Android matte-glass widgets for Flutter.'
  spec.description      = <<-DESC
A Flutter UI kit that uses native SwiftUI Liquid Glass on iOS and a Flutter
matte or tinted glass fallback on Android.
                       DESC
  spec.homepage         = 'https://github.com/yourname/liquid_glass_kit'
  spec.license          = { :type => 'MIT' }
  spec.author           = { 'liquid_glass_kit' => 'dev@example.com' }
  spec.source           = { :path => '.' }
  spec.source_files     = 'liquid_glass_kit/Sources/liquid_glass_kit/**/*'
  spec.dependency 'Flutter'
  spec.platform         = :ios, '16.0'
  spec.swift_version    = '5.0'
end
