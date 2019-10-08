Pod::Spec.new do |s|

s.name         = "TextPaths"
s.version      = "0.1.0"
s.license      = "MIT"
s.homepage     = "https://github.com/malczak/TextPaths"
s.summary      = "NSAttributedString to CGPaths"
s.author       = { "Mateusz Malczak" => "mateusz@malczak.info" }
s.source       = { :git => "https://github.com/malczak/TextPaths.git", :branch => "swift" }

s.platform     = :ios, "8.0"

s.source_files  = "Source/*.swift"
s.exclude_files = "Source/*Tests.swift"

s.requires_arc = true
end
