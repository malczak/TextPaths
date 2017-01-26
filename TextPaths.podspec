#
# Be sure to run `pod lib lint TextPaths.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TextPaths'
  s.version          = '0.1.0'
  s.summary          = 'Split NSAttributedText into glyph CGPaths'

  s.description      = <<-DESC
Glyph based text animations and effects.
                       DESC

  s.homepage         = 'https://github.com/malczak/TextPaths'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mateusz Malczak' => 'mateusz@malczak.info' }
  s.source           = { :git => 'https://github.com/malczak/TextPaths.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/**/*'

  s.frameworks = 'CoreText', 'CoreGraphics', 'UIKit'
end
