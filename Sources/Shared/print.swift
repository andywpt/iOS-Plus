import OSLog

func print(_ item: Any, file: String = #file, line: Int = #line){
    guard Environment.isDebugBuild else { return }
    let lastSlashIndex = (file.lastIndex(of: "/") ?? String.Index(utf16Offset: 0, in: file))
    let nextIndex = file.index(after: lastSlashIndex)
    let filename = file.suffix(from: nextIndex)
    let prefix = "[\(filename):\(line)]"
    Swift.print("\(item) \(prefix)[Debug]")
}
