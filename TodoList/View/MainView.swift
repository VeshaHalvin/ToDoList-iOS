//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isSignedIn {
            TodoListView()
        } else {
            LoginView()
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
