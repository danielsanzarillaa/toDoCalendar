import SwiftUI
//prueba git
enum TaskPriority: Int, Codable {
    case baja = 0
    case media = 1
    case alta = 2
    
    var color: Color {
        switch self {
        case .baja: return .green
        case .media: return .orange
        case .alta: return .red
        }
    }
    
    var text: String {
        switch self {
        case .baja: return "Baja"
        case .media: return "Media"
        case .alta: return "Alta"
        }
    }
} 