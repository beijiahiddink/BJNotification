Pod::Spec.new do |s|
s.name = 'BJNotification'
s.version = '1.0'
s.license = 'MIT'
s.summary = 'A Notification Demo in iOS.'
s.homepage = 'https://github.com/beijiahiddink/BJNotification'
s.authors = { 'beijiahiddink' => 'beijiahiddink@163.com' }
s.source = { :git => "https://github.com/beijiahiddink/BJNotification.git", :tag => "1.0"}
s.requires_arc = true
s.ios.deployment_target = '7.0'
s.source_files = "BJNotification", "*.{h,m}"
end

