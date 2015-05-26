Pod::Spec.new do |s|
  s.name = "FluxKit"
  s.version = "0.0.1"
  s.summary = "Flux implementation in Swift."
  s.homepage = "https://github.com/nubbel/FluxKit"
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { "Dominique d'Argent" => "nicky.nubbel@gmail.com" }
  s.social_media_url = "http://twitter.com/nubbel"
  s.source = { :git => "https://github.com/nubbel/FluxKit.git", :tag => "v#{s.version}" }
  s.source_files  = 'FluxKit/**/*.{h,swift}'
  s.ios.deployment_target = '8.3'
  s.requires_arc = true
end
