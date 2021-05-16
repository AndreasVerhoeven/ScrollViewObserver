Pod::Spec.new do |s|
    s.name             = 'ScrollViewObserver'
    s.version          = '1.0.0'
    s.summary          = 'Observer UIScrollView scrolling without setting a delegate'
    s.homepage         = 'https://github.com/AndreasVerhoeven/ScrollViewObserver'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Andreas Verhoeven' => 'cocoapods@aveapps.com' }
    s.source           = { :git => 'https://github.com/AndreasVerhoeven/ScrollViewObserver.git', :tag => s.version.to_s }
    s.module_name      = 'ScrollViewObserver'

    s.swift_versions = ['5.0']
    s.ios.deployment_target = '11.0'
    s.source_files = 'Sources/*.swift'
end
