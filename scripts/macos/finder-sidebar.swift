import Foundation

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
    exit(1)
}

let paths = Array(CommandLine.arguments.dropFirst())
guard !paths.isEmpty else {
    fail("No Finder sidebar items supplied.")
}

let fileManager = FileManager.default
var items = [[String: Any]]()

for path in paths {
    var isDirectory: ObjCBool = false
    guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory),
          isDirectory.boolValue else {
        fail("Finder sidebar directory not found: \(path)")
    }

    let url = URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL
    let bookmark: Data
    do {
        bookmark = try url.bookmarkData(
            options: .suitableForBookmarkFile,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    } catch {
        fail("Unable to create Finder sidebar bookmark for \(path): \(error)")
    }

    items.append([
        "Bookmark": bookmark,
        "CustomItemProperties": [String: Any](),
        "uuid": UUID().uuidString,
        "visibility": 0,
    ])
}

let archive: [String: Any] = [
    "items": items,
    "properties": ["com.apple.LSSharedFileList.ForceTemplateIcons": true],
]

let applicationSupport = fileManager.urls(
    for: .applicationSupportDirectory,
    in: .userDomainMask
)[0]
let listDirectory = applicationSupport.appendingPathComponent(
    "com.apple.sharedfilelist",
    isDirectory: true
)
let listName = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
    ? "com.apple.LSSharedFileList.FavoriteItems.sfl4"
    : "com.apple.LSSharedFileList.FavoriteItems.sfl3"
let listURL = listDirectory.appendingPathComponent(listName)

do {
    try fileManager.createDirectory(
        at: listDirectory,
        withIntermediateDirectories: true
    )
    let data = try NSKeyedArchiver.archivedData(
        withRootObject: archive,
        requiringSecureCoding: false
    )
    try data.write(to: listURL, options: .atomic)
} catch {
    fail("Unable to save the Finder sidebar: \(error)")
}
