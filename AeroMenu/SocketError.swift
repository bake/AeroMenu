import Foundation

enum SocketError: LocalizedError {
    case FailedToCreate(path: String)
    case FailedToBind(path: String)
    case FailedToListen(path: String)

    var errorDescription: String? {
        switch self {
        case .FailedToCreate(let path):
            return NSLocalizedString("Could not create the socket at \(path)", comment: "")
        case .FailedToBind(let path):
            return NSLocalizedString("Could not bind socket at \(path)", comment: "")
        case .FailedToListen(let path):
            return NSLocalizedString("Could not listen on socket at \(path)", comment: "")
        }
    }
}
