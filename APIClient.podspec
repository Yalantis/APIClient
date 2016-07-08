Pod::Spec.new do |s|

  s.name         = "APIClient"
  s.version      = "0.1.0"

  s.summary      = "Lightweight networking framework."

  s.homepage     = "https://git.yalantis.com/eugene.andreyev/APIClient"
  s.license      = "MIT"
  s.authors      = { 'Eugene Andreyev' => 'eugene.andreyev@yalantis.com' }

  s.source       = { :git => "git@git.yalantis.com:eugene.andreyev/APIClient.git", :tag => s.version.to_s }

  s.frameworks = 'Foundation'

  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.default_subspec = 'Default'

  # Default subspec that includes the most commonly-used components
  s.subspec 'Default' do |default|
    default.source_files = "/Sources/*"
    default.dependency 'Bolts-Swift', '1.1.0' 
  end

  # JSON Deserializer
  s.subspec 'JSONDeserializer' do |JSONDeserializer|
    JSONDeserializer.source_files = "Defaults/Deserializer/*"
  end

  # Optional subspecs
  s.subspec 'Alamofire' do |Alamofire|
    Alamofire.dependency 'Alamofire', '3.3' 
    Alamofire.source_files = "Defaults/Alamofire/*"
  end

  s.subspec 'ObjectMapper' do |ObjectMapper|
    ObjectMapper.dependency 'ObjectMapper', '1.3.0' 
    ObjectMapper.source_files = "Defaults/Parser/*"
  end

end
