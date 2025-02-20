import SwiftUI

struct TaskRow: View {
    let task: ToDoTaskItem
    let isEditing: Bool
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                }
                
                Spacer()
                
                if !task.description.isEmpty {
                    Button(action: { isExpanded.toggle() }) {
                        Image(systemName: isExpanded ? AppConstants.Images.chevronUp : AppConstants.Images.chevronDown)
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if !isEditing {
                    Button(action: {}) {
                        Image(systemName: task.isCompleted ? AppConstants.Images.checkmarkCircleFill : AppConstants.Images.circle)
                            .foregroundColor(task.isCompleted ? .green : .gray)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                    }
                }
                
                if isEditing {
                    Image(systemName: AppConstants.Images.editIcon)
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            if isExpanded && !task.description.isEmpty {
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(task.priority.color.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(task.isCompleted ? Color.gray.opacity(0.3) : task.priority.color.opacity(0.5), lineWidth: 2)
        )
        .padding(.vertical, 6)
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
