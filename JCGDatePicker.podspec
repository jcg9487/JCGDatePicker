#
#  Be sure to run `pod spec lint JCGDatePicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|


  spec.name         = 'JCGDatePicker'
  spec.version      = '0.0.1'
  spec.summary      = 'A customer DatePicker use Objective-C'
  spec.description  = <<-DESC
Customer DateOicker use Objetive-C,combine date
                   DESC
  spec.homepage     = 'https://github.com/jcg9487/JCGDatePicker'
  spec.license      = 'MIT'
  spec.author       = { 'EdwardJCG' => 'jcg9487@163.com' }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => 'https://github.com/jcg9487/JCGDatePicker.git', :tag => "v0.0.1" }
  spec.source_files  = 'JCGDatePicker/JCGDatePicker/JCGDatePicker.{h,m}'
end
