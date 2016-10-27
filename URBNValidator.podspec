#
# Be sure to run `pod lib lint URBNValidator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = "URBNValidator"
  s.version          = "2"
  s.summary          = "URBNValidator is a simple swift validation library with support for objc"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC

    URBNValidator is a lightweight extensible swift validation library.   You can easily add validation to
    any of your swift objects as well as any objc objects (if you're into that sort of thing).

    Features
    ========
    * Full swift support
    * Objc compatibility
    * Ability to create your own validations and extend custom types
    * Full localization support (global and per instance).

  DESC

  s.homepage         = "https://github.com/urbn/URBNValidator"
  s.license          = 'MIT'
  s.author           = { "Joe" => "jridenour@mercury.io" }
  s.source           = { :git => "https://github.com/urbn/URBNValidator.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.tvos.deployment_target = '9.0'
  s.source_files = ['Pod/Classes/**/*']
  s.resources = ['Pod/Resources/**/*.lproj']

end
