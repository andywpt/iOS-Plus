import Foundation

enum Environment {
    
    static var isDebugBuild: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    static var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    static var isRunningSwiftUIPreviews: Bool {
        value(for: "XCODE_RUNNING_FOR_PREVIEWS") == "1"
    }

    static var isRunningUnitTests: Bool {
        value(for: "XCTestConfigurationFilePath") != nil
    }
    
    private static func value(for key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
}
