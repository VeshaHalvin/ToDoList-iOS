//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import Foundation
import Combine

class TodoListViewModel : ObservableObject{
    @Published var todolists = [TodoItem]()
    
    var todolistRepositary = TodolistRepositories()
    
    @Published
    var errorMessage : String?
    
    init(){
        todolistRepositary.$todoItems.assign(to: &$todolists)
    }
    
    
    func addItem(_ newItem : TodoItem){
        do{
            try todolistRepositary.addTodoItems(newItem)
            errorMessage = nil
        }
        catch{ 
            print(error)
            errorMessage = error.localizedDescription
        }
        
    }
    
    func updateTodoItem(_ newItem: TodoItem) {
        do {
            try todolistRepositary.updateTodoItems(newItem)

            if newItem.isChecked {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.todolistRepositary.deleteTodoItem(newItem)
                }
            }
        } catch {
            print("Error when updating item in viewmodel: \(error)")
        }
    }
}
