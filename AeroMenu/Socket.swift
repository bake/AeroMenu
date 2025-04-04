import Foundation

class Socket {
    let path: String
    var fd: Int32

    init(path: String) {
        self.path = path
        self.fd = -1
    }

    func setup() throws {
        unlink(path)

        fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else {
            throw SocketError.FailedToCreate(path: path)
        }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        strcpy(&addr.sun_path.0, path)

        let addrSize = socklen_t(MemoryLayout<sockaddr_un>.size(ofValue: addr))
        let bindResult = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(fd, $0, addrSize)
            }
        }
        guard bindResult == 0 else {
            throw SocketError.FailedToBind(path: path)
        }

        guard Darwin.listen(fd, 10) == 0 else {
            throw SocketError.FailedToListen(path: path)
        }
    }

    func listen(handler: (String) -> Void) {
        while true {
            if let message = listenOnce() {
                handler(message)
            }
        }
    }

    private func listenOnce() -> String? {
        let client = accept(fd, nil, nil)
        if client < 0 {
            return nil
        }
        defer { close(client) }

        var buffer = [UInt8](repeating: 0, count: 1024)
        let read = read(client, &buffer, buffer.count)

        if read <= 0 {
            return nil
        }

        let data = Data(bytes: buffer, count: read)
        guard let message = String(data: data, encoding: .utf8) else {
            return nil
        }

        return message.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
}
