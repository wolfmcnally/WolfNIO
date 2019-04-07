Pod::Spec.new do |s|
    s.name             = 'WolfNIO'
    s.version          = '0.1.0'
    s.summary          = 'NIO and concurrency tools (including futures) for iOS apps.'

    # s.description      = <<-DESC
    # TODO: Add long description of the pod here.
    # DESC

    s.homepage         = 'https://github.com/wolfmcnally/WolfNIO'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Wolf McNally' => 'wolf@wolfmcnally.com' }
    s.source           = {
        :git => 'https://github.com/wolfmcnally/WolfNIO.git',
        :tag => s.version.to_s,
        :submodules => true
    }

    s.source_files = 'Sources/WolfNIO/**/*', 'Sources/nio-kit/Sources/**/*'

    s.swift_version = '5.0'

    s.ios.deployment_target = '12.0'
    s.macos.deployment_target = '10.14'
    s.tvos.deployment_target = '12.0'

    s.module_name = 'WolfNIO'

    s.dependency 'SwiftNIO', '~> 2.0'
    s.dependency 'SwiftNIOTransportServices', '~> 1.0'
end
