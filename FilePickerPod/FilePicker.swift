import UIKit
import UniformTypeIdentifiers

public protocol FilePickerDelegate: AnyObject {
    func didPickImage(_ image: UIImage, url: URL?)
    func didPickDocument(_ url: URL)
    func didCancelDocumentPicker()
    func didSelectInvalidDocument()
    func didFailWithError(_ error: Error)
}

public class FilePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    private weak var viewController: UIViewController?
    private weak var delegate: FilePickerDelegate?
    private var allowedDocumentTypes: Set<String> = []
    
    // Properties for file size limits
    public var imageSizeMinLimit: Int
    public var imageSizeMaxLimit: Int
    public var documentSizeMinLimit: Int
    public var documentSizeMaxLimit: Int

    public init(viewController: UIViewController, delegate: FilePickerDelegate,
                imageSizeMinLimit: Int, imageSizeMaxLimit: Int,
                documentSizeMinLimit: Int, documentSizeMaxLimit: Int) {
        self.viewController = viewController
        self.delegate = delegate
        self.imageSizeMinLimit = imageSizeMinLimit
        self.imageSizeMaxLimit = imageSizeMaxLimit
        self.documentSizeMinLimit = documentSizeMinLimit
        self.documentSizeMaxLimit = documentSizeMaxLimit
    }

    public func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [UTType.image.identifier]
        viewController?.present(imagePicker, animated: true, completion: nil)
    }

    public func pickDocument(type: DocumentType) {
        allowedDocumentTypes = Set(type.fileTypes)
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: type.contentTypes, asCopy: true)
        documentPicker.delegate = self
        viewController?.present(documentPicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            // Check image size limits
            if let imageData = image.pngData(), imageData.count >= imageSizeMinLimit && imageData.count <= imageSizeMaxLimit {
                // Save the image to a temporary file and get the URL
                let tempDirectory = FileManager.default.temporaryDirectory
                let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
                do {
                    try imageData.write(to: tempFileURL)
                    delegate?.didPickImage(image, url: tempFileURL)
                } catch {
                    print("Error saving image to temporary file: \(error)")
                    delegate?.didPickImage(image, url: nil)
                }
            } else {
                let error = NSError(domain: "FilePickerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Image size is out of range."])
                delegate?.didFailWithError(error)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - UIDocumentPickerDelegate

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize, fileSize >= documentSizeMinLimit && fileSize <= documentSizeMaxLimit {
                // Check if the selected file's type is allowed
                let fileUTI = (try? url.resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier ?? ""

                if allowedDocumentTypes.contains(fileUTI) {
                    delegate?.didPickDocument(url)
                } else {
                    delegate?.didSelectInvalidDocument()
                }
            } else {
                let error = NSError(domain: "FilePickerError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Document size is out of range."])
                delegate?.didFailWithError(error)
            }
        } catch {
            delegate?.didFailWithError(error)
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.didCancelDocumentPicker()
    }

    // MARK: - DocumentType

    public enum DocumentType {
        case pdf
        case text
        case word
        case all

        var fileTypes: [String] {
            switch self {
            case .pdf:
                return [UTType.pdf.identifier]
            case .text:
                return [UTType.text.identifier]
            case .word:
                return [
                    "com.microsoft.word.doc",
                    "org.openxmlformats.wordprocessingml.document"
                ]
            case .all:
                return [
                    UTType.pdf.identifier,
                    UTType.text.identifier,
                    "com.microsoft.word.doc",
                    "org.openxmlformats.wordprocessingml.document"
                ]
            }
        }

        var contentTypes: [UTType] {
            switch self {
            case .pdf:
                return [UTType.pdf]
            case .text:
                return [UTType.text]
            case .word:
                return [
                    UTType("com.microsoft.word.doc")!,
                    UTType("org.openxmlformats.wordprocessingml.document")!
                ]
            case .all:
                return [
                    UTType.pdf,
                    UTType.text,
                    UTType("com.microsoft.word.doc")!,
                    UTType("org.openxmlformats.wordprocessingml.document")!
                ]
            }
        }
    }
}
