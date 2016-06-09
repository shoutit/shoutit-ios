Pod::Spec.new do |s|
  s.name = 'Material'
  s.version = '1.39.0'
  s.license = 'BSD'
  s.summary = 'Express your creativity with Material, an animation and graphics framework for Google\'s Material Design and Apple\'s Flat UI in Swift.'
  s.homepage = 'http://cosmicmind.io'
  s.social_media_url = 'https://www.facebook.com/graphkit'
  s.authors = { 'CosmicMind, Inc.' => 'support@cosmicmind.io' }
  s.source = { :git => 'https://github.com/CosmicMind/Material.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.ios.source_files = 'Sources/iOS/**/*.swift'
  s.osx.deployment_target = '10.9'
  s.osx.source_files = 'Sources/OSX/**/*.swift'
  s.requires_arc = true
  s.resource_bundles = {
      'Fonts' => ['Sources/**/*.ttf']
  }
end
