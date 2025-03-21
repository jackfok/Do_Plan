import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingAddNote = false
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                .padding(.horizontal)
                .padding(.top)
                
                // 标签切换
                HStack(spacing: 0) {
                    TabButton(title: "全部笔记", isSelected: selectedTab == 0) {
                        selectedTab = 0
                        viewModel.selectedCategory = nil
                    }
                    
                    TabButton(title: "置顶笔记", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    TabButton(title: "收藏", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.top, 10)
                
                // 笔记列表
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredNotes) { note in
                            noteCard(for: note)
                                .contextMenu {
                                    Button(action: {
                                        viewModel.togglePinStatus(for: note.id)
                                    }) {
                                        Label(note.isPinned ? "取消置顶" : "置顶笔记", systemImage: note.isPinned ? "pin.slash" : "pin")
                                    }
                                    
                                    Button(action: {
                                        // 编辑笔记
                                    }) {
                                        Label("编辑", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        viewModel.deleteNote(withID: note.id)
                                    }) {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                        
                        if filteredNotes.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text(searchText.isEmpty ? "没有笔记" : "没有找到匹配的笔记")
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
            .navigationTitle("笔记")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            // 排序按标题
                        }) {
                            Label("按标题排序", systemImage: "textformat")
                        }
                        
                        Button(action: {
                            // 排序按日期
                        }) {
                            Label("按日期排序", systemImage: "calendar")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            // 创建文件夹
                        }) {
                            Label("创建文件夹", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Button(action: {
                            // 排序按标题
                        }) {
                            Label("按标题排序", systemImage: "textformat")
                        }
                        
                        Button(action: {
                            // 排序按日期
                        }) {
                            Label("按日期排序", systemImage: "calendar")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            // 创建文件夹
                        }) {
                            Label("创建文件夹", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                #endif
            }
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
    
    private var filteredNotes: [Note] {
        switch selectedTab {
        case 0:
            return viewModel.filteredNotes
        case 1:
            return viewModel.filteredNotes.filter { $0.isPinned }
        case 2:
            // 这里应该是收藏的笔记，为了示例我们暂时只显示最近创建的笔记
            return viewModel.filteredNotes.sorted { $0.creationDate > $1.creationDate }
        default:
            return viewModel.filteredNotes
        }
    }
    
    @ViewBuilder
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
                noteTypeIcon(for: note.type)
                
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
    
    @ViewBuilder
    private func noteTypeIcon(for type: NoteType) -> some View {
        switch type {
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
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NotesView()
} 