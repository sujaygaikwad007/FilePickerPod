Pod::Spec.new do |spec|

spec.name         = "FilePickerPod"
spec.version      = "1.0.2"
spec.summary      = "A custom pod to select images or files with type validation."
spec.description  = "FilePickerPod is a custom CocoaPods library that provides an easy way to                     select images or files from the user's device.It allows developers to specify                and validate file types, so users can choose only specific formats such as                    PDF, Word documents,text files, or all available formats. This feature ensures               that only the intended file types are presented to users,improving both user                   experience and data integrity."
spec.homepage     = "https://github.com/sujaygaikwad007/FilePickerPod.git"
spec.license      = "MIT"
spec.author       = { "Sujay Gaikwad" => "gaikwadsujay007@gmail.com" }
spec.platform     = :ios, "15.0"
spec.source       = { :git => "https://github.com/sujaygaikwad007/FilePickerPod.git", :tag => spec.version.to_s }
spec.source_files  = "FilePickerPod/**/*.{swift}" 
spec.swift_versions = "5.0"


end
