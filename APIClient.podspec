Pod::Spec.new do |s|

  s.name         = "APIClient"
  s.version      = "0.1.0"

  s.summary      = "Lightweight networking framework."

  s.homepage     = "https://git.yalantis.com/eugene.andreyev/APIClient"
  s.license      = "MIT"
  s.authors      = { 'Eugene Andreyev' => 'eugene.andreyev@yalantis.com' }

  s.source       = { :git => "git@git.yalantis.com:eugene.andreyev/APIClient.git", :tag => '0.1.2' }

  s.frameworks = 'Foundation'

  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.default_subspec = 'Default'

  # Default subspec that includes the most commonly-used components
  s.subspec 'Default' do |default|
    default.source_files = "APIClient/Source/**/*.swift"
    default.dependency 'Bolts-Swift', '1.1.0' 
  end

  # JSON Deserializer
  s.subspec 'JSONDeserializer' do |jsonDeserializer|
    jsonDeserializer.dependency 'APIClient/Default'
    jsonDeserializer.source_files = "APIClient/Defaults/Deserializers/*"
  end

  # Optional subspecs
  s.subspec 'Alamofire' do |alamofire|
    alamofire.dependency 'APIClient/Default'
    alamofire.dependency 'Alamofire', '3.3' 
    alamofire.dependency 'OHHTTPStubs'
    alamofire.dependency 'OHHTTPStubs/Swift'
    alamofire.source_files = "APIClient/Defaults/Alamofire/*"
  end

  s.subspec 'ObjectMapper' do |objectMapper|
    objectMapper.dependency 'APIClient/Default'
    objectMapper.dependency 'ObjectMapper', '1.3.0' 
    objectMapper.source_files = "APIClient/Defaults/Parser/*"
  end

end
