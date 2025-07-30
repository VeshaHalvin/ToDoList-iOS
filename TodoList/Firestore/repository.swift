//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

public class TodolistRepositories: ObservableObject{
    @Published
    var todoItems = [TodoItem]()
    private var listenerRegistration: ListenerRegistration?
    private var currentUserUID: String?
    
    init(){
        currentUserUID = Auth.auth().currentUser?.uid
        subscribe()
    }
    
    deinit{
        unsubscribe()
    }
    
    func addTodoItems(_ todoItem : TodoItem) throws {
        guard let currentUserUID = currentUserUID else {
                    print("No authenticated user.")
                    return
                }

                try Firestore.firestore()
                    .collection("users")
                    .document(currentUserUID)
                    .collection(TodoItem.collectionName)
                    .addDocument(from: todoItem)
    }
    
    func subscribe(){
        guard let currentUserUID = currentUserUID else {
            print("No authenticated user.")
            return
        }
        
        if listenerRegistration == nil {
            let query = Firestore.firestore()
            .collection("users")
            .document(currentUserUID)
            .collection(TodoItem.collectionName)
                    
            listenerRegistration = query.addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No documents in this collection")
                    return
                }
                        
            self.todoItems = documents.compactMap { queryDocumentSnapshot in
                do {
                    return try queryDocumentSnapshot.data(as: TodoItem.self)
                } catch {
                    print("Error when mapping the documents")
                    return nil
                }
            }
        }
    }
    }
    
    private func unsubscribe(){
        if listenerRegistration != nil{
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }
    

    func updateTodoItems(_ newItem: TodoItem) throws {
        guard let currentUserUID = currentUserUID, let documentID = newItem.id else {
            print("No authenticated user or document ID.")
            return
        }
        try Firestore.firestore()
            .collection("users")
            .document(currentUserUID)
            .collection(TodoItem.collectionName)
            .document(documentID)
            .setData(from: newItem, merge: true)
    }
    
    func deleteTodoItem(_ item: TodoItem) {
        guard let currentUserUID = currentUserUID, let documentID = item.id else {
            print("No authenticated user or document ID.")
            return
        }
        Firestore.firestore()
            .collection("users")
            .document(currentUserUID)
            .collection(TodoItem.collectionName)
            .document(documentID)
            .delete { error in
                if let error = error {
                    print("Error deleting item: \(error)")
                }
            }
    }
}
