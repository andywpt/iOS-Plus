import Foundation
import UniformTypeIdentifiers

extension URL {
    var mimeType: String {
        UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
    }

    /// File url video memory footprint. Remote url will return 0.
    func fileSizeInMB() -> Double? {
        guard isFileURL else { return 0.0 }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let size = attributes[.size] as? NSNumber {
                return size.doubleValue / (1024 * 1024)
            }
        } catch {
            print("⚠️ Cannot get attributes for path: \(error)")
        }
        return 0.0
    }
}

