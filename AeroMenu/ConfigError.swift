
import Foundation

enum ConfigError: LocalizedError {
    case FailedToFind
    case FailedToRead(underlying: Error, path: String)
    case FailedToParse(underlying: Error, path: String)

    var errorDescription: String? {
        switch self {
        case .FailedToFind:
            return NSLocalizedString("Config file not found", comment: "")
        case .FailedToRead(let error, let path):
            return NSLocalizedString("Could not read config file at \(path): \(error.localizedDescription)", comment: "")
        case .FailedToParse(let error, let path):
            return NSLocalizedString("Could not parse config file at \(path): \(error.localizedDescription)", comment: "")
        }
    }
}
