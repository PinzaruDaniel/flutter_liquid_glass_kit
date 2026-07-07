Pod::Spec.new do |spec|
  spec.name             = 'flutter_liquid_glass_kit'
  spec.version          = '1.0.1'
  spec.summary          = 'Native iOS Liquid Glass and Android matte-glass widgets for Flutter.'
  spec.description      = <<-DESC
A Flutter UI kit that uses native SwiftUI Liquid Glass on iOS and a Flutter
matte or tinted glass fallback on Android.
                       DESC
  spec.homepage         = 'https://github.com/PinzaruDaniel/flutter_liquid_glass_kit'
  spec.license          = { :type => 'MIT' }
  spec.author           = { 'flutter_liquid_glass_kit' => 'Daniel Pinzaru' }
  spec.source           = { :path => '.' }
  spec.source_files     = 'flutter_liquid_glass_kit/Sources/flutter_liquid_glass_kit/**/*'
  spec.dependency 'Flutter'
  spec.platform         = :ios, '16.0'
  spec.swift_version    = '5.0'
end
