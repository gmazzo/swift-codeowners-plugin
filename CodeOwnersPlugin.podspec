Pod::Spec.new do |s|
  s.name = 'CodeOwnersPlugin'
  s.summary = 'A Swift Package Manager plugin to validate CODEOWNERS files.'
  s.version = `git describe --tags --abbrev=0`.strip!.delete_prefix('v')
  s.license = 'MIT'
  s.source = { :git => 'https://github.com/gmazzo/swift-codeowners-plugin.git', :tag => "v#{s.version.to_s}" }
  s.homepage = 'https://github.com/gmazzo/swift-codeowners-plugin/'
  s.authors = { 'Guillermo Mazzola' => 'gmazzo65@gmail.com' }
  s.swift_versions = '5'
  s.ios.deployment_target = '13.0'
  s.source_files = 'Sources/CodeOwnersPlugin/**/*.swift'

  s.subspec 'Core' do |ss|
    ss.header_dir = 'CodeOwnersCore'
    ss.source_files = 'Sources/CodeOwnersCore/**/*.swift'
  end

  s.subspec 'Tool' do |ss|
    ss.header_dir = 'CodeOwnersTool'
    ss.source_files = 'Sources/CodeOwnersTool/**/*.swift'
  end

  s.prepare_command = <<-CMD
    swift build --product CodeOwnersTool --configuration release
  CMD

end
