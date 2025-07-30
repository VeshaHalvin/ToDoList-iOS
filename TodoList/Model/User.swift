//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var phoneNumber: String
    var profileImage: String
}

