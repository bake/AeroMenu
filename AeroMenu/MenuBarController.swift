import SwiftUI

class MenuBarController {
    private var workspaces: Workspaces
    private var statusItem: NSStatusItem
    private var hostingView: NSHostingView<MenuBarIconsView>
    private var error: Error?

    init() {
        workspaces = Workspaces(
            aerospace: AeroSpace(path: "/run/current-system/sw/bin/aerospace"),
            socket: Socket(path: "/tmp/aeromenu.socket")
        )

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        hostingView = NSHostingView(rootView: MenuBarIconsView(workspaces: workspaces))

        setupButton()
        setupMenu()

        NotificationCenter.default.addObserver(forName: .updateMenuBarSize, object: nil, queue: OperationQueue.main) { n in
            if let size = n.object as? CGSize {
                self.statusItem.length = size.width
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.workspaces.listen()
            } catch {
                // TODO: Change icon
                print(error.localizedDescription)
                self.error = error
                self.setupMenu()
            }
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
