# FilePickerPod

FilePicker is a Swift class for picking images and documents in an iOS application, with support for customizable file size limits. It integrates with UIImagePickerController for images and UIDocumentPickerViewController for documents.


 [![Version](https://img.shields.io/cocoapods/v/FilePickerPod.svg?style=flat)](https://cocoapods.org/pods/FilePickerPod)
 [![License](https://img.shields.io/cocoapods/l/FilePickerPod.svg?style=flat)](https://cocoapods.org/pods/FilePickerPod)
 [![Platform](https://img.shields.io/cocoapods/p/FilePickerPod.svg?style=flat)](https://cocoapods.org/pods/FilePickerPod)

## Requirements

- iOS 15.0+
- Swift 5.0+

## Installation

### CocoaPods

FilePicker is available through [CocoaPods](https://cocoapods.org/pods/FilePickerPod). To install it, simply add the following line to your Podfile:

```ruby
pod 'FilePickerPod'
```


## Usage

Initialize FilePicker with required parameters including view controller, delegate, and file size limits.

1. Import the module:

```swift
import 'FilePickerPod'
```

2. Initialize FilePicker with required parameters including view controller, delegate, and file size limits.


```swift
import UIKit

class ViewController: UIViewController, FilePickerDelegate {

    private var filePicker: FilePicker?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize FilePicker with size limits
        filePicker = FilePicker(
            viewController: self,
            delegate: self,
            imageSizeMinLimit: 100 * 1024, // 100 KB
            imageSizeMaxLimit: 5 * 1024 * 1024, // 5 MB
            documentSizeMinLimit: 200 * 1024, // 200 KB
            documentSizeMaxLimit: 10 * 1024 * 1024 // 10 MB
        )
    }

    @IBAction func pickImageButtonTapped(_ sender: UIButton) {
        filePicker?.pickImage()
    }

    @IBAction func pickDocumentButtonTapped(_ sender: UIButton) {
        filePicker?.pickDocument(type: .all) // You can change to .pdf, .text, or .word
    }

    // MARK: - FilePickerDelegate

    func didPickImage(_ image: UIImage, url: URL?) {
        // Handle picked image
        print("Image picked. URL: \(url?.absoluteString ?? "No URL")")
    }

    func didPickDocument(_ url: URL) {
        // Handle picked document
        print("Document picked. URL: \(url.absoluteString)")
    }

    func didCancelDocumentPicker() {
        // Handle cancellation
        print("Document picker was cancelled")
    }

    func didSelectInvalidDocument() {
        // Handle invalid document type
        print("Selected document is invalid")
    }

    func didFailWithError(_ error: Error) {
        // Handle error
        print("Error: \(error.localizedDescription)")
    }
}



```







