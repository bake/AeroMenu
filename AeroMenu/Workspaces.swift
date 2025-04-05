import Foundation

class Workspaces: ObservableObject {
    private let aerospace: AeroSpace
    private let socket: Socket

    private let symbols: [String: String]

    @Published
    public var workspaces: [Workspace] = []

    init(aerospace: AeroSpace, socket: Socket, symbols: [String: String]) {
        self.aerospace = aerospace
        self.socket = socket
        self.symbols = symbols
    }

    public func listen() throws {
        try socket.setup()

        var workspaces = try aerospace.listAllWorkspaces()
            .map { Workspace(id: $0, symbol: symbols[$0] ?? "circle") }

        for w in try aerospace.listFocusedWorkspaces() {
            if let i = workspaces.firstIndex(where: { $0.id == w }) {
                workspaces[i].focused = true
            }
        }

        DispatchQueue.main.async {
            self.workspaces = workspaces
        }

        socket.listen(handler: handler)
    }

    private func handler(message: String) {
        let parts = message.split(separator: " ", maxSplits: 1)
        if parts.count != 2 {
            return
        }
        switch (parts[0], parts[1]) {
        case ("workspace-change", _):
            handleWorkspaceChange(String(parts[1]))
        default:
            print("unknown command \(parts[0])")
        }
    }

    private func handleWorkspaceChange(_ id: String) {
        DispatchQueue.main.async {
            for i in self.workspaces.indices {
                self.workspaces[i].focused = self.workspaces[i].id == id
            }
            NotificationCenter.default.post(name: .workspaceChange, object: id)
        }
    }
}
