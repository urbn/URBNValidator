#
# Be sure to run `pod lib lint URBNValidator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "URBNValidator"
  s.version          = "0.1.0"
  s.summary          = "A short description of URBNValidator."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://github.com/urbn/URBNValidator"
  s.license          = 'MIT'
  s.author           = { "Joe" => "jridenour@mercury.io" }
  s.source           = { :git => "https://github.com/urbn/URBNValidator.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.preserve_paths = "Pod/Supporting Files/**/*"
  s.module_map = "Pod/Supporting Files/URBNValidator.modulemap"
  s.source_files = ['Pod/Classes/**/*', "Pod/Supporting Files/**/*.h"]
  s.resources = ['Pod/Resources/**/*.lproj']

  s.subspec 'ObjC' do |ss|
    ss.source_files = 'Pod/ObjC/**.*'
  end
end
