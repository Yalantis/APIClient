Pod::Spec.new do |s|

  s.name         = "APIClient"
  s.version      = '1.0.7'

  s.summary      = "Lightweight networking framework."

  s.homepage     = "https://github.com/Yalantis/APIClient.git"
  s.license      = "MIT"
  s.authors      = { 'Eugene Andreyev' => 'eugene.andreyev@yalantis.com' }

  s.source       = { :git => "git@github.com:Yalantis/APIClient.git", :tag => s.version }

  s.frameworks = 'Foundation'

  s.requires_arc = true
  s.ios.deployment_target = '9.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = "APIClient/Default/**/*.swift"
    ss.dependency 'Bolts-Swift', '~> 1.3' 
  end

  s.subspec 'Alamofire' do |ss|
    ss.dependency 'APIClient/Core'
    ss.dependency 'Alamofire', '~> 4.6' 
    ss.source_files = "APIClient/Alamofire/*"
  end

  s.subspec 'ObjectMapper' do |ss|
    ss.dependency 'APIClient/Core'
    ss.dependency 'ObjectMapper', '~> 3.1' 
    ss.source_files = "APIClient/ObjectMapper/*"
  end

  s.subspec 'StubbedClient' do |ss|
    ss.dependency 'APIClient/Core'
    ss.source_files = "APIClient/StubbedClient/*"
  end

  s.subspec 'OHHTTPStubs' do |ss|
    ss.dependency 'APIClient/StubbedClient'
    ss.dependency 'OHHTTPStubs/Swift'
    ss.source_files = "APIClient/OHHTTPStubs/*"
  end

end