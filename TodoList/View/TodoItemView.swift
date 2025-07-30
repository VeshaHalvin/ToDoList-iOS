//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import SwiftUI

struct TodoItemView: View {
     @State var item : TodoItem
    var onToggleCheck: (TodoItem) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: item.isChecked ? "record.circle" : "circle")
                .onTapGesture {
                    item.isChecked.toggle()
                    onToggleCheck(item)
                }
            VStack(alignment: .leading) {
                Text(item.title)
                Text(item.importance.rawValue)
                    .font(.caption)
                    .foregroundColor(color(for: item.importance))
            }
            Spacer()
            Image(systemName: "info.circle")
        }

        .font(.system(size: 20))
        .padding()
    }
    
    private func color(for importance: Importance) -> Color {
            switch importance {
            case .high:
                return .red
            case .medium:
                return .orange
            case .low:
                return .green
            }
        }
}

struct TodoItemView_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemView(item: TodoItem(title: "Eating", isChecked: false, importance: .low)) { _ in }
    }
}

