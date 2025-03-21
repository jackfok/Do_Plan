import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NotesViewModel()
    
    @State private var noteTitle: String = ""
    @State private var noteContent: String = ""
    @State private var noteType: NoteType = .text
    @State private var selectedCategory: Category = .personal
    @State private var tags: [String] = []
    @State private var tagInput: String = ""
    @State private var reminderDate: Date? = nil
    @State private var showDatePicker: Bool = false
    @State private var isPinned: Bool = false
    
    @State private var showingDiscardAlert = false
    @State private var isNewNote = true
    @State private var editingNote: Note? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 标题输入
                    TextField("标题", text: $noteTitle)
                        .font(.title)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    // 笔记类型选择
                    VStack(alignment: .leading) {
                        Text("笔记类型")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(NoteType.allCases, id: \.self) { type in
                                    noteTypeButton(type)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 内容输入
                    VStack(alignment: .leading) {
                        if noteType == .todo {
                            todoEditor
                        } else {
                            TextEditor(text: $noteContent)
                                .frame(minHeight: 200)
                                .padding(.horizontal)
                                #if os(iOS)
                                .background(Color(UIColor.systemGray6))
                                #else
                                .background(Color(NSColor.controlBackgroundColor))
                                #endif
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                    }
                    
                    // 分类选择
                    VStack(alignment: .leading) {
                        Text("分类")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Category.allCases, id: \.self) { category in
                                    categoryButton(category)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 标签输入
                    VStack(alignment: .leading) {
                        Text("标签")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            TextField("添加标签", text: $tagInput, onCommit: addTag)
                                .padding(10)
                                #if os(iOS)
                                .background(Color(UIColor.systemGray6))
                                #else
                                .background(Color(NSColor.controlBackgroundColor))
                                #endif
                                .cornerRadius(8)
                            
                            Button(action: addTag) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if !tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack {
                                            Text(tag)
                                                .padding(.leading, 8)
                                                .padding(.trailing, 0)
                                            
                                            Button(action: {
                                                removeTag(tag)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                                    .font(.caption)
                                            }
                                            .padding(.trailing, 8)
                                        }
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(15)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 提醒设置
                    VStack(alignment: .leading) {
                        Toggle(isOn: Binding<Bool>(
                            get: { reminderDate != nil },
                            set: { if $0 { reminderDate = Date() } else { reminderDate = nil } }
                        )) {
                            Text("设置提醒")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        if reminderDate != nil {
                            DatePicker("提醒时间", selection: Binding<Date>(
                                get: { reminderDate ?? Date() },
                                set: { reminderDate = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            .padding(.horizontal)
                        }
                    }
                    
                    // 置顶选项
                    Toggle(isOn: $isPinned) {
                        Text("置顶笔记")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    // 保存按钮
                    Button(action: saveNote) {
                        Text("保存笔记")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.vertical)
            }
            .navigationTitle("编辑笔记")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        if hasChanges() {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        saveNote()
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        if hasChanges() {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        saveNote()
                    }
                }
                #endif
            }
            .alert("放弃更改？", isPresented: $showingDiscardAlert) {
                Button("放弃", role: .destructive) {
                    dismiss()
                }
                Button("继续编辑", role: .cancel) {}
            } message: {
                Text("您有未保存的更改，确定要放弃吗？")
            }
        }
    }
    
    private var todoEditor: some View {
        VStack(alignment: .leading) {
            Text("待办事项")
                .font(.headline)
                .padding(.horizontal)
            
            TextEditor(text: $noteContent)
                .frame(minHeight: 200)
                .padding(.horizontal)
                #if os(iOS)
                .background(Color(UIColor.systemGray6))
                #else
                .background(Color(NSColor.controlBackgroundColor))
                #endif
                .cornerRadius(8)
                .padding(.horizontal)
                .overlay(
                    Group {
                        if noteContent.isEmpty {
                            VStack(alignment: .leading) {
                                Text("- [ ] 第一个待办事项")
                                Text("- [ ] 第二个待办事项")
                                Text("- [ ] 第三个待办事项")
                                Spacer()
                            }
                            .foregroundColor(.gray.opacity(0.5))
                            .padding()
                            .padding(.horizontal)
                        }
                    }
                )
        }
    }
    
    private func noteTypeButton(_ type: NoteType) -> some View {
        Button(action: {
            self.noteType = type
        }) {
            VStack {
                Image(systemName: typeIcon(for: type))
                    .font(.title2)
                    .foregroundColor(noteType == type ? .white : .blue)
                    .frame(width: 40, height: 40)
                    .background(noteType == type ? Color.blue : Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(type.rawValue)
                    .font(.caption)
                    .foregroundColor(noteType == type ? .blue : .gray)
            }
        }
    }
    
    private func categoryButton(_ category: Category) -> some View {
        Button(action: {
            self.selectedCategory = category
        }) {
            VStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(selectedCategory == category ? .white : .blue)
                    .frame(width: 40, height: 40)
                    .background(selectedCategory == category ? Color.blue : Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(category.rawValue)
                    .font(.caption)
                    .foregroundColor(selectedCategory == category ? .blue : .gray)
            }
        }
    }
    
    private func typeIcon(for type: NoteType) -> String {
        switch type {
        case .text:
            return "doc.text"
        case .list:
            return "list.bullet"
        case .todo:
            return "checklist"
        case .reminder:
            return "bell"
        case .alarm:
            return "alarm"
        }
    }
    
    private func addTag() {
        let tag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tag.isEmpty && !tags.contains(tag) {
            tags.append(tag)
            tagInput = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        if let index = tags.firstIndex(of: tag) {
            tags.remove(at: index)
        }
    }
    
    private func hasChanges() -> Bool {
        if isNewNote {
            return !noteTitle.isEmpty || !noteContent.isEmpty || !tags.isEmpty || reminderDate != nil || isPinned
        } else {
            // 检查与原始笔记的差异...
            return true
        }
    }
    
    private func saveNote() {
        let note = Note(
            title: noteTitle,
            content: noteContent,
            type: noteType,
            tags: tags,
            reminderDate: reminderDate,
            isPinned: isPinned,
            category: selectedCategory
        )
        
        if isNewNote {
            viewModel.addNote(note)
        } else if let editingNote = editingNote {
            var updatedNote = note
            updatedNote.id = editingNote.id
            updatedNote.creationDate = editingNote.creationDate
            viewModel.updateNote(updatedNote)
        }
        
        dismiss()
    }
}

#Preview {
    EditView()
} 