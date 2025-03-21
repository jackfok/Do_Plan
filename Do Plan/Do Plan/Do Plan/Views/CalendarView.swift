import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingAddNote = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    private let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack {
                // 月份导航
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: currentMonth))
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // 星期标题
                HStack {
                    ForEach(getWeekdaySymbols(), id: \.self) { weekday in
                        Text(weekday)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                // 日历网格
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(getDaysInMonth(), id: \.self) { date in
                        if let date = date {
                            DayCell(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                hasNotes: hasNotesForDate(date),
                                isToday: calendar.isDateInToday(date)
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        } else {
                            // 空单元格（填充月份前后的空位）
                            Text("")
                                .frame(height: 40)
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical)
                
                // 选中日期的笔记
                VStack(alignment: .leading) {
                    Text(fullDateFormatter.string(from: selectedDate))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if getNotesForDate(selectedDate).isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("没有笔记")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Button("添加笔记") {
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
                    } else {
                        List {
                            ForEach(getNotesForDate(selectedDate)) { note in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(note.title)
                                            .font(.headline)
                                        
                                        if let reminderDate = note.reminderDate {
                                            HStack {
                                                Image(systemName: "clock")
                                                    .foregroundColor(.orange)
                                                
                                                Text(reminderDate, style: .time)
                                                    .font(.caption)
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                        
                                        Text(note.content)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: typeIcon(for: note.type))
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
                Spacer()
            }
            .navigationTitle("日历")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedDate = Date()
                        currentMonth = Date()
                    }) {
                        Text("今天")
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        selectedDate = Date()
                        currentMonth = Date()
                    }) {
                        Text("今天")
                    }
                }
                #endif
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
    
    private func getWeekdaySymbols() -> [String] {
        return ["日", "一", "二", "三", "四", "五", "六"]
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
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        var days = [Date?]()
        
        // 获取当前月份的第一天
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstDayOfMonth = calendar.date(from: components) else { return [] }
        
        // 获取当前月份的天数
        guard let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else { return [] }
        let numDays = range.count
        
        // 获取第一天是星期几（0是星期日）
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 填充月份前面的空白
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // 添加当月的天数
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // 填充月份后面的空白，使总数为7的倍数
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7 {
            for _ in 0..<remainingDays {
                days.append(nil)
            }
        }
        
        return days
    }
    
    private func hasNotesForDate(_ date: Date) -> Bool {
        return !getNotesForDate(date).isEmpty
    }
    
    private func getNotesForDate(_ date: Date) -> [Note] {
        return viewModel.notes.filter { note in
            if let reminderDate = note.reminderDate {
                return calendar.isDate(reminderDate, inSameDayAs: date)
            }
            return false
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasNotes: Bool
    let isToday: Bool
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(height: 40)
            
            Text(dayFormatter.string(from: date))
                .font(.system(size: 16, weight: isToday || isSelected ? .bold : .regular))
                .foregroundColor(textColor)
            
            if hasNotes {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
                    .offset(y: 15)
            }
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.blue
        } else if isToday {
            return Color.blue.opacity(0.2)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else {
            return .primary
        }
    }
}

#Preview {
    CalendarView()
} 