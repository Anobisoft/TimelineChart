
Pod::Spec.new do |s|

s.name             = 'TimelineChart'
s.version          = '0.0.1'
s.summary          = 'TimelineChart - tool for automated build timeline chart view.'

s.description      = <<-DESC
TimelineChart - tool for automated build timeline chart view.
TODO: Add long description of the pod here.
DESC

  s.homepage         = 'https://github.com/Anobisoft/TimelineChart'
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Stanislav Pletnev" => "anobisoft@gmail.com" }
  s.social_media_url   = "https://twitter.com/Anobisoft"

  s.platform     = :ios, "8.3"
  s.source       = { :git => "https://github.com/Anobisoft/TimelineChart.git", :tag => "#{s.version}" }
  s.source_files  = "TimelineChart/**/*.{h,m}"

  s.framework  = "UIKit"

  s.requires_arc = true

end
