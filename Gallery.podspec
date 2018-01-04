Pod::Spec.new do |s|
  s.name             = "Gallery"
  s.summary          = "Something good about gallery"
  s.version          = "2.0.6"
  s.homepage         = "https://github.com/hyperoslo/Gallery"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = {
    :git => "https://github.com/hyperoslo/Gallery.git",
    :tag => s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/hyperoslo'

  s.ios.deployment_target = '9.0'

  s.requires_arc = true
  s.source_files = 'Sources/**/*'
  s.resource = 'Resources/Gallery.bundle'
  s.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'Photos', 'PhotosUI', 'CoreLocation', 'AVKit'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  
end
