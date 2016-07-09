Pod::Spec.new do |s|
s.name = 'BJNotification'
s.version = '1.0'
s.license = 'MIT'
s.summary = 'A Notification framework in iOS.'
s.homepage = 'https://github.com/beijiahiddink/BJNotification'
s.authors = { 'beijiahiddink' => 'beijiahiddink@163.com' }
s.source = { :git => "https://github.com/beijiahiddink/BJNotification.git", :tag => s.version}
s.requires_arc = true
s.ios.deployment_target = '7.0'
s.source_files = "BJNotificationFW/BJNotificationFW", "*.{h,m}"
end

