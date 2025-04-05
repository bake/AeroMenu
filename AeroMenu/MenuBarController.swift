import SwiftUI

class MenuBarController {
    private var workspaces: Workspaces
    private var statusItem: NSStatusItem
    private var hostingView: NSHostingView<MenuBarIconsView>
    private var error: Error?

    init() throws {
        let config = try ConfigParser().parse()

        workspaces = Workspaces(
            aerospace: AeroSpace(path: config.aeroSpacePath),
            socket: Socket(path: config.socketPath),
            symbols: config.workspaces
        )

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        hostingView = NSHostingView(rootView: MenuBarIconsView(
            workspaces: workspaces,
            showWorkspaceNames: config.showWorkspaceNames,
            showUnfocusedWorkspaces: config.showUnfocusedWorkspaces
        ))

        setupButton()
        setupMenu()

        NotificationCenter.default.addObserver(forName: .updateMenuBarSize, object: nil, queue: OperationQueue.main) { n in
            if let size = n.object as? CGSize {
                self.statusItem.length = size.width
            }
        }

        DispatchQueue.global(qos: .userInitiated).async(execute: listen)
    }

    private func listen() {
        do {
            try workspaces.listen()
        } catch {
            print(error.localizedDescription)
            self.error = error
            setupMenu()
        }
    }

    private func setupButton() {
        if let button = statusItem.button {
            button.addSubview(hostingView)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                hostingView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
            ])
        }
    }

    private func setupMenu() {
        let menu = NSMenu()

        if error != nil {
            let errorItem = NSMenuItem(title: error!.localizedDescription, action: nil, keyEquivalent: "")
            menu.addItem(errorItem)
        }

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
