import Foundation

enum Disk {
    private static var fileManager: FileManager {
        FileManager.default
    }

    static var applicationSupportDirectory: URL {
        try! fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }

    static var cachesDirectory: URL {
        try! fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }

    static var rootDirectory: URL {
        let url = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return url.deletingLastPathComponent()
    }

    static var documentsDirectory: URL {
        try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }

    static var temporaryDirectory: URL {
        fileManager.temporaryDirectory
    }

    static func directoryExists(at path: URL) -> Bool {
        // https://forums.developer.apple.com/forums/thread/54110
        guard let values = try? path.resourceValues(forKeys: [.isDirectoryKey]) else {
            return false
        }
        return values.isDirectory == true
    }

    static func fileExists(at path: URL) -> Bool {
        var isDirectory = true as ObjCBool
        let exists = fileManager.fileExists(atPath: path.relativePath, isDirectory: &isDirectory)
        return exists && !isDirectory.boolValue
    }

    static func createDirectory(named: String, under directory: URL) throws {
        let url = if #available(iOS 16.0, *) {
            directory.appending(path: named, directoryHint: .isDirectory)
        } else {
            directory.appendingPathComponent(named, isDirectory: true)
        }
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }
}

