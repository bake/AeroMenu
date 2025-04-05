import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        do {
            menuBarController = try MenuBarController()
        } catch {
            print(error.localizedDescription)
        }
    }
}
