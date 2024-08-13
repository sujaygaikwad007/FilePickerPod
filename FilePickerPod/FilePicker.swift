import UIKit
import UniformTypeIdentifiers

public protocol FilePickerDelegate: AnyObject {
    func didPickImage(_ image: UIImage, url: URL?)
    func didPickDocument(_ url: URL)
    func didCancelDocumentPicker()
    func didSelectInvalidDocument()
}

public class FilePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    private weak var viewController: UIViewController?
    private weak var delegate: FilePickerDelegate?
    private var allowedDocumentTypes: Set<String> = []

    public init(viewController: UIViewController, delegate: FilePickerDelegate) {
        self.viewController = viewController
        self.delegate = delegate
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
        
        // Update the initializer to use the new method
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: type.contentTypes, asCopy: true)
        documentPicker.delegate = self
        viewController?.present(documentPicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            // Save the image to a temporary file and get the URL
            if let imageData = image.pngData() {
                let tempDirectory = FileManager.default.temporaryDirectory
                let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
                do {
                    try imageData.write(to: tempFileURL)
                    delegate?.didPickImage(image, url: tempFileURL)
                } catch {
                    print("Error saving image to temporary file: \(error)")
                    delegate?.didPickImage(image, url: nil)
                }
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

        // Check if the selected file's type is allowed
        let fileUTI = (try? url.resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier ?? ""

        if allowedDocumentTypes.contains(fileUTI) {
            delegate?.didPickDocument(url)
        } else {
            delegate?.didSelectInvalidDocument()
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
