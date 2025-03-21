import Foundation

enum NoteType: String, Codable, CaseIterable {
    case text = "文本"
    case list = "列表"
    case todo = "待办事项"
    case reminder = "提醒"
    case alarm = "闹钟"
}

enum Category: String, Codable, CaseIterable {
    case work = "工作"
    case personal = "个人"
    case study = "学习"
    case health = "健康"
    case food = "食谱"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .work: return "briefcase"
        case .personal: return "person"
        case .study: return "book"
        case .health: return "heart"
        case .food: return "fork.knife"
        case .other: return "ellipsis"
        }
    }
    
    var color: String {
        switch self {
        case .work: return "blue"
        case .personal: return "purple"
        case .study: return "green"
        case .health: return "red"
        case .food: return "yellow"
        case .other: return "gray"
        }
    }
}

struct Note: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var type: NoteType
    var tags: [String]
    var reminderDate: Date?
    var isPinned: Bool
    var creationDate: Date
    var modificationDate: Date
    var category: Category
    
    init(title: String = "", 
         content: String = "", 
         type: NoteType = .text, 
         tags: [String] = [], 
         reminderDate: Date? = nil, 
         isPinned: Bool = false, 
         category: Category = .other) {
        self.title = title
        self.content = content
        self.type = type
        self.tags = tags
        self.reminderDate = reminderDate
        self.isPinned = isPinned
        self.creationDate = Date()
        self.modificationDate = Date()
        self.category = category
    }
} 