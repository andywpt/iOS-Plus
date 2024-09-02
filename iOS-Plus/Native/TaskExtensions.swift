extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        // sleep() will throw an error if the task is cancelled.
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
