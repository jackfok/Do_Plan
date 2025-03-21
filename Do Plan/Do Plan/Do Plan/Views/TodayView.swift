import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingAddNote = false
    @State private var currentDate = Date()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日，EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 日期显示区域
                    HStack {
                        VStack(alignment: .leading) {
                            Text("今天")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(dateFormatter.string(from: currentDate))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 日程区域
                    VStack(alignment: .leading, spacing: 15) {
                        Text("日程")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // 今日提醒
                        ForEach(viewModel.getTodayNotes()) { note in
                            TodayNoteCard(note: note) {
                                viewModel.togglePinStatus(for: note.id)
                            }
                        }
                        
                        if viewModel.getTodayNotes().isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("今天没有待办事项")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Button("添加新待办") {
                                    showingAddNote = true
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        }
                    }
                    
                    // 任务区域
                    VStack(alignment: .leading, spacing: 15) {
                        Text("任务")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.notes.filter { $0.type == .todo }) { note in
                            TodoCard(note: note) {
                                // 标记为完成逻辑
                            }
                        }
                        
                        if viewModel.notes.filter({ $0.type == .todo }).isEmpty {
                            Text("没有待办任务")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                    
                    // 置顶笔记
                    VStack(alignment: .leading, spacing: 15) {
                        Text("置顶笔记")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.notes.filter { $0.isPinned }) { note in
                            NoteCard(note: note) {
                                viewModel.togglePinStatus(for: note.id)
                            }
                        }
                        
                        if viewModel.notes.filter({ $0.isPinned }).isEmpty {
                            Text("没有置顶笔记")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                }
                .padding(.vertical)
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(isPresented: $showingAddNote) {
                EditView()
            }
            .overlay(
                Button(action: {
                    showingAddNote = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(25),
                alignment: .bottomTrailing
            )
        }
    }
}

struct TodayNoteCard: View {
    let note: Note
    let onTogglePin: () -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                if let reminderDate = note.reminderDate {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        
                        Text(timeFormatter.string(from: reminderDate))
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onTogglePin) {
                Image(systemName: note.isPinned ? "pin.fill" : "pin")
                    .foregroundColor(note.isPinned ? .blue : .gray)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct TodoCard: View {
    let note: Note
    let onComplete: () -> Void
    @State private var isCompleted = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Button(action: {
                isCompleted.toggle()
                onComplete()
            }) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.blue, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(note.title)
                    .font(.headline)
                    .strikethrough(isCompleted)
                    .foregroundColor(isCompleted ? .gray : .primary)
                
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if let reminderDate = note.reminderDate {
                Text(reminderDate, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct NoteCard: View {
    let note: Note
    let onTogglePin: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
                
                HStack {
                    ForEach(note.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                    
                    if note.tags.count > 3 {
                        Text("+\(note.tags.count - 3)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onTogglePin) {
                Image(systemName: "pin.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    TodayView()
} 