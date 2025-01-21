// SelectViewModel.swift

import Foundation

class SelectionViewModel: ObservableObject {
    @Published var searchText: String = ""
    
    // サンプルデータ
    private let allScenes: [SceneD] = [
        SceneD(title: "卒業式", date: "2024年11月12日"),
        SceneD(title: "運動会", date: "2024年10月5日"),
        SceneD(title: "誕生日会", date: "2024年7月20日")
    ]
    
    var filteredScenes: [SceneD] {
        if searchText.isEmpty {
            return allScenes
        } else {
            return allScenes.filter { $0.title.contains(searchText) }
        }
    }
}

