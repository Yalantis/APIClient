Pod::Spec.new do |s|
  s.name         = 'APIClient'
  s.version      = '3.0'
  s.summary      = 'Extensible network client.'
  s.homepage     = 'https://github.com/rnkyr/APIClient.git'
  s.license      = { type: 'MIT', file: 'License' }
  s.authors      = {
    'Eugene Andreyev': 'eugene.andreyev@yalantis.com',
    'Roman Kyrylenko': 'roman.kyrylenko@yalantis.com',
    'Anton Vodolazkyi': 'anton.vodolazky@yalantis.com'
  }
  s.source       = { git: 'https://github.com/Yalantis/APIClient.git', tag: s.version }
  s.frameworks   = 'Foundation'
  s.ios.deployment_target = '10.0'
  s.default_subspec = 'Alamofire'

  s.subspec 'Core' do |ss|
    ss.source_files = 'APIClient/Default/**/*.swift'
  end

  s.subspec 'Alamofire' do |ss|
    ss.dependency 'APIClient/Core'
    ss.dependency 'Alamofire', '5.2.1'
    ss.source_files = 'APIClient/Alamofire/*'
  end
end
