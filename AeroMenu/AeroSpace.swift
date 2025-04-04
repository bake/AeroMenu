import Foundation

class AeroSpace {
    private var path: String

    init(path: String) {
        self.path = path
    }

    func listWorkspaces(flag: String) throws -> [String] {
        let stdout = Pipe()

        let process = Process()
        process.standardOutput = stdout
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", "\(self.path) list-workspaces \(flag)"]

        try process.run()

        return String(
            data: stdout.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        )!
            .components(separatedBy: NSCharacterSet.newlines)
            .filter { w in !w.isEmpty }
    }

    func listAllWorkspaces() throws -> [String] {
        return try self.listWorkspaces(flag: "--all")
    }

    func listFocusedWorkspaces() throws -> [String] {
        return try self.listWorkspaces(flag: "--focused")
    }
}
