struct Workspace: Identifiable, Codable {
    let id: String
    let symbol: String
    var focused: Bool = false
    var animate: Bool = false
}
