import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Image(systemName: "calendar.day")
                    Text("今日视图")
                }
                .tag(0)
            
            NotesView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("笔记")
                }
                .tag(1)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text("日历")
                }
                .tag(2)
            
            CategoriesView()
                .tabItem {
                    Image(systemName: "folder")
                    Text("分类")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
} 