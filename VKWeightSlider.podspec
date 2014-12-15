Pod::Spec.new do |s|
  s.name         = 'VKWeightSlider'
  s.version      = '0.0.1'
  s.summary      = 'VKWeighSlider'
  s.platform     =  :ios, "7.0"
  s.requires_arc = true
  s.author = {
    'Maciej Banasiewicz' => 'mbanasiewicz@gmail.com'
  }
  s.source = {
    :git => 'https://github.com/stoprocent/VKWeightSlider.git',
    :tag => '0.0.1'
  }
  s.source_files = 'Source/*.{h,m}'
end