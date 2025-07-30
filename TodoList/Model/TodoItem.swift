//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import Foundation
import FirebaseFirestore

struct TodoItem : Identifiable, Codable{
    @DocumentID var id  : String?
    var title : String
    var isChecked : Bool
    var importance: Importance = .medium
    
}

enum Importance: String, Codable, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var id: String { self.rawValue }
}

extension TodoItem{
    static let collectionName = "todoItems"
}
