//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import SwiftUI

struct AddNewItemView: View {
    enum FocusableField : Hashable {
        case title
    }
    @FocusState private var focusField : FocusableField?
    
   @State private var newItem = TodoItem(title: "", isChecked: false)
    
    @Environment(\.dismiss)
    private var dismiss
    
    var on_commit : (_ newItem : TodoItem) ->Void
    
    private func commit(){
        on_commit(newItem)
        dismiss()
    }
    private func cancel(){
        dismiss()
    }
    var body: some View {
        NavigationView {
            Form {
                TextField("Input a new item", text: $newItem.title)
                    .focused($focusField, equals: .title)

                Picker("Importance", selection: $newItem.importance) {
                    ForEach(Importance.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: commit) {
                        Text("Add")
                    }
                    .disabled(newItem.title.isEmpty)
                }
            }
            .toolbar{
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
            }
            .onAppear{
                focusField = .title
            }
        }
        
    }
}

struct AddNewItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewItemView{ newItem in
            print("hello world \(newItem.title)")
        }
    }
}
