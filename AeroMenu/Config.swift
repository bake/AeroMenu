import Foundation
import TOMLKit

struct Config: Codable {
    var aeroSpacePath: String = "/opt/homebrew/bin/aerospace"
    var socketPath: String = "/tmp/aeromenu.sock"
    var showWorkspaceNames: Bool = false
    var showUnfocusedWorkspaces: Bool = true
    var workspaces: [String: String] = [:]

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try values.decodeIfPresent(String.self, forKey: .aeroSpacePath) {
            self.aeroSpacePath = value
        }

        if let value = try values.decodeIfPresent(String.self, forKey: .socketPath) {
            self.socketPath = value
        }

        if let value = try values.decodeIfPresent(Bool.self, forKey: .showWorkspaceNames) {
            self.showWorkspaceNames = value
        }

        if let value = try values.decodeIfPresent(Bool.self, forKey: .showUnfocusedWorkspaces) {
            self.showUnfocusedWorkspaces = value
        }

        if let value = try values.decodeIfPresent([String: String].self, forKey: .workspaces) {
            self.workspaces = value
        }
    }
}

class ConfigParser {
    private let paths: [String] = [
        ".aeromenu.toml",
        ".config/aeromenu/aeromenu.toml"
    ]

    public func parse() throws -> Config {
        let path = paths
            .map { FileManager.default.homeDirectoryForCurrentUser.appending(path: $0) }
            .first(where: { FileManager.default.isReadableFile(atPath: $0.path()) })
        guard let path = path else {
            throw ConfigError.FailedToFind
        }

        let content: String
        do {
            content = try String(contentsOf: path, encoding: .utf8)
        } catch {
            throw ConfigError.FailedToRead(underlying: error, path: path.path())
        }

        let config: Config
        do {
            config = try TOMLDecoder().decode(Config.self, from: content)
        } catch {
            throw ConfigError.FailedToParse(underlying: error, path: path.path())
        }

        return config
    }
}
