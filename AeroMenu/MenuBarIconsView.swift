import SwiftUI

struct MenuBarIconsView: View {
    @ObservedObject var workspaces: Workspaces
    var showWorkspaceNames: Bool
    var showUnfocusedWorkspaces: Bool

    @State public var size: CGSize = .zero

    var body: some View {
        HStack(spacing: 5) {
            if workspaces.workspaces.isEmpty {
                Image(systemName: "circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 16, alignment: .center)
            }
            ForEach($workspaces.workspaces) { $w in
                if showUnfocusedWorkspaces || w.focused {
                    Image(systemName: w.symbol)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 16, alignment: .center)
                        .symbolEffect(.bounce, value: w.animate)
                        .symbolVariant(w.focused ? .fill : .none)
                    if showWorkspaceNames && w.focused {
                        Text(w.id)
                    }
                }
            }
        }
        .onGeometryChange(for: CGSize.self, of: { $0.size }) { size in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .updateMenuBarSize, object: size)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .workspaceChange)) { n in
            animate(n.object as! String)
        }
    }

    private func animate(_ id: String) {
        if let i = workspaces.workspaces.firstIndex(where: { $0.id == id }) {
            workspaces.workspaces[i].animate.toggle()
        }
    }
}
