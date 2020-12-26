Pod::Spec.new do |s|
  s.name = "UserDefaultsSnapshotLib"

  s.version = "1.0.0"
  s.summary = "A library that provides a snapshot of the UserDefaults for the state-management."
  s.description = <<-DESC
    A library that provides a snapshot of the UserDefaults for the state-management.
                        DESC
  s.author = "Muukii"
  s.homepage = "https://github.com/VergeGroup/UserDefaultsSnapshot"
  s.source = { :git => "https://github.com/VergeGroup/UserDefaultsSnapshot.git", :tag => s.version }

  s.ios.deployment_target = "10.0"

  s.swift_version = "5.3"
  s.source_files = "Sources/**/*.swift"
  s.frameworks = "Foundation"
end
