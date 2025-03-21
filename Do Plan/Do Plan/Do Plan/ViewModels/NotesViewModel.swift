import Foundation
import Combine

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var filteredNotes: [Note] = []
    @Published var selectedCategory: Category? = nil
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSampleData()
        setupSearchPublisher()
    }
    
    private func setupSearchPublisher() {
        $searchText
            .combineLatest($selectedCategory, $notes)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { searchText, selectedCategory, notes in
                self.filterNotes(notes: notes, searchText: searchText, category: selectedCategory)
            }
            .assign(to: \.filteredNotes, on: self)
            .store(in: &cancellables)
    }
    
    private func filterNotes(notes: [Note], searchText: String, category: Category?) -> [Note] {
        notes.filter { note in
            let matchesSearch = searchText.isEmpty || 
                                note.title.localizedCaseInsensitiveContains(searchText) || 
                                note.content.localizedCaseInsensitiveContains(searchText) ||
                                note.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            
            let matchesCategory = category == nil || note.category == category
            
            return matchesSearch && matchesCategory
        }
        .sorted { $0.isPinned && !$1.isPinned || $0.modificationDate > $1.modificationDate }
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = note
            updatedNote.modificationDate = Date()
            notes[index] = updatedNote
            saveNotes()
        }
    }
    
    func deleteNote(at indexSet: IndexSet) {
        notes.remove(atOffsets: indexSet)
        saveNotes()
    }
    
    func deleteNote(withID id: UUID) {
        notes.removeAll { $0.id == id }
        saveNotes()
    }
    
    func togglePinStatus(for noteID: UUID) {
        if let index = notes.firstIndex(where: { $0.id == noteID }) {
            notes[index].isPinned.toggle()
            notes[index].modificationDate = Date()
            saveNotes()
        }
    }
    
    func getTodayNotes() -> [Note] {
        let calendar = Calendar.current
        return notes.filter { note in
            if let reminderDate = note.reminderDate {
                return calendar.isDateInToday(reminderDate)
            }
            return false
        }
    }
    
    func getNotesByCategory(_ category: Category) -> [Note] {
        return notes.filter { $0.category == category }
    }
    
    // MARK: - Persistence
    
    private func saveNotes() {
        // 实际应用中，这里会使用CoreData或其他持久化方案
        // 这里暂时不实现真正的存储逻辑
    }
    
    private func loadNotes() {
        // 实际应用中，这里会从CoreData或其他持久化方案加载数据
        // 这里暂时不实现真正的加载逻辑
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        notes = [
            Note(title: "产品设计讨论会", 
                 content: "与设计团队讨论新产品界面原型，重点关注用户体验和交互流程。", 
                 type: .text, 
                 tags: ["会议", "设计"], 
                 reminderDate: Date().addingTimeInterval(3600), 
                 isPinned: true, 
                 category: .work),
            
            Note(title: "周末购物清单", 
                 content: "1. 牛奶\n2. 鸡蛋\n3. 水果\n4. 蔬菜\n5. 面包", 
                 type: .list, 
                 tags: ["购物", "周末"], 
                 category: .personal),
            
            Note(title: "学习Swift UI课程", 
                 content: "完成第5章关于动画和转场效果的学习，并做课后练习。", 
                 type: .todo, 
                 tags: ["学习", "编程"], 
                 reminderDate: Date().addingTimeInterval(7200), 
                 category: .study),
            
            Note(title: "准备会议演示文稿", 
                 content: "为下周技术评审会议准备PPT和演示Demo。", 
                 type: .todo, 
                 tags: ["会议", "准备"], 
                 reminderDate: Date().addingTimeInterval(86400), 
                 category: .work)
        ]
        
        filteredNotes = notes
    }
} 