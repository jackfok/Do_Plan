import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var searchText = ""
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 搜索栏
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("搜索分类", text: $searchText)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    #if os(iOS)
                    .background(Color(UIColor.systemGray6))
                    #else
                    .background(Color(NSColor.controlBackgroundColor))
                    #endif
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // 分类列表
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(Category.allCases.filter {
                            searchText.isEmpty ||
                            $0.rawValue.localizedCaseInsensitiveContains(searchText)
                        }, id: \.self) { category in
                            categoryCard(category)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("分类")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                // 移除工具栏中的添加按钮
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
            .sheet(isPresented: $showingAddNote) {
                EditView()
            }
        }
    }
    
    private func categoryCard(_ category: Category) -> some View {
        let notesCount = viewModel.getNotesByCategory(category).count
        
        return NavigationLink(destination: CategoryDetailView(category: category)) {
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(colorForCategory(category))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                Text(category.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(notesCount) 个笔记")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            #if os(iOS)
            .background(Color(UIColor.systemBackground))
            #else
            .background(Color(NSColor.windowBackgroundColor))
            #endif
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private func colorForCategory(_ category: Category) -> Color {
        switch category {
        case .work:
            return Color.blue
        case .personal:
            return Color.purple
        case .study:
            return Color.green
        case .health:
            return Color.red
        case .food:
            return Color.orange
        case .other:
            return Color.gray
        }
    }
}

struct CategoryDetailView: View {
    let category: Category
    @StateObject private var viewModel = NotesViewModel()
    @State private var searchText = ""
    @State private var showingAddNote = false
    
    var body: some View {
        VStack {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("搜索笔记", text: $searchText)
                    #if os(iOS) && compiler(>=5.9)
                    .onChange(of: searchText) { _, newValue in
                        viewModel.searchText = newValue
                    }
                    #else
                    .onChange(of: searchText) { newValue in
                        viewModel.searchText = newValue
                    }
                    #endif
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            #if os(iOS)
            .background(Color(UIColor.systemGray6))
            #else
            .background(Color(NSColor.controlBackgroundColor))
            #endif
            .cornerRadius(10)
            
            // 笔记列表
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(filteredNotes) { note in
                        noteCard(for: note)
                    }
                    
                    if filteredNotes.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "note.text")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text(searchText.isEmpty ? "此分类中没有笔记" : "没有找到匹配的笔记")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Button("创建新笔记") {
                                showingAddNote = true
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(category.rawValue)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            // 移除工具栏中的添加按钮
        }
        #if os(iOS)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
        .sheet(isPresented: $showingAddNote) {
            EditView()
        }
    }
    
    private var filteredNotes: [Note] {
        viewModel.notes.filter { note in
            note.category == category &&
            (searchText.isEmpty ||
             note.title.localizedCaseInsensitiveContains(searchText) ||
             note.content.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    private func noteCard(for note: Note) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                
                Text(note.creationDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                // 笔记类型图标
                switch note.type {
                case .text:
                    Label("文本", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.gray)
                case .list:
                    Label("列表", systemImage: "list.bullet")
                        .font(.caption)
                        .foregroundColor(.gray)
                case .todo:
                    Label("待办", systemImage: "checklist")
                        .font(.caption)
                        .foregroundColor(.gray)
                case .reminder:
                    Label("提醒", systemImage: "bell")
                        .font(.caption)
                        .foregroundColor(.gray)
                case .alarm:
                    Label("闹钟", systemImage: "alarm")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 标签
                if !note.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
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
                        }
                    }
                    .frame(height: 25)
                }
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
    }
}

#Preview {
    CategoriesView()
}
