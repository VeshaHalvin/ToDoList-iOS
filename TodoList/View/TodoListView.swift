//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    
    @State private var isAddTodoItemDialogPresented = false
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    private func presentAddTodoItemView(){
        isAddTodoItemDialogPresented.toggle()
    }
    
    private func logout() {
            authViewModel.signOut()
        }
    
    var body: some View {
        NavigationView {
            List(viewModel.todolists){ item in
                TodoItemView(item: item) { updatedItem in
                        viewModel.updateTodoItem(updatedItem)
                    }
            }
            .navigationTitle("To Do List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: logout) {
                        Text("Logout")
                        .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: presentAddTodoItemView) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddTodoItemDialogPresented) {
                AddNewItemView{
                    newItem in
                    viewModel.addItem(newItem)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
