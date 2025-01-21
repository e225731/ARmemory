//
//
//import SwiftUI
//import ARKit
//
//struct SelectionView: View {
//    @EnvironmentObject var store: WorldMapStore
//    
//    @State private var selectedMap: ARWorldMap?
//    @State private var isShowingARView = false
//    
//    var body: some View {
//        NavigationView {
//            GeometryReader { geometry in
//                ZStack {
//                    Color.white.ignoresSafeArea()
//                    
//                    VStack(spacing: 0) {
//                        
//                        // タイトル
//                        Text("おもいで")
//                            .font(.largeTitle)
//                            .padding(.top, 16)
//                        
//                        // 検索バー
//                        HStack(spacing: 0) {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(width: geometry.size.width * 0.8, height: 45)
//                                .background(Color(red: 0.92, green: 0.93, blue: 0.94))
//                                .cornerRadius(10)
//                                .overlay(
//                                    HStack {
//                                        Image(systemName: "magnifyingglass")
//                                            .resizable()
//                                            .frame(width: 24, height: 24)
//                                            .foregroundColor(.gray)
//                                            .padding(3.6)
//                                        Spacer()
//                                    }
//                                    .padding(.horizontal, 10)
//                                )
//                        }
//                        .frame(width: geometry.size.width * 0.8, height: 45)
//                        .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
//                        
//                        // --- Listを使ってスワイプ削除 & タップ復元 ---
//                        List {
//                            ForEach(store.records) { record in
//                                
//                                // 1つのセル
//                                VStack(alignment: .leading, spacing: 8) {
//                                    // 画像部分
//                                    ZStack {
//                                        Rectangle()
//                                            .foregroundColor(.gray.opacity(0.2))
//                                            .cornerRadius(16)
//                                            .frame(height: 200)
//                                        
//                                        if let thumbFilename = record.thumbnailFilename,
//                                           let thumbImage = ImageFileManager.loadImageFromDocuments(filename: thumbFilename) {
//                                            Image(uiImage: thumbImage)
//                                                .resizable()
//                                                .scaledToFill()
//                                                .cornerRadius(16)
//                                                .clipped()
//                                                .frame(height: 200)
//                                        }
//                                    }
//                                    .contentShape(Rectangle()) // タップ領域
//                                    .onTapGesture {
//                                        // タップしたらARViewへ
//                                        if let loadedMap = store.loadWorldMapFromFile(filename: record.worldMapFilename) {
//                                            selectedMap = loadedMap
//                                            isShowingARView = true
//                                        }
//                                    }
//                                    
//                                    
//                                    // ↓ 画像の下に テキストを置く
//                                    Text(record.title)
//                                        .font(.headline)
//                                    Text(record.dateString)
//                                        .font(.subheadline)
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                            .onDelete(perform: deleteRecords)
//                        }
//                        .listStyle(PlainListStyle())
//                        
//                        Spacer()
//                        
//                        // タブバー風
//                        ZStack {
//                            Rectangle()
//                                .foregroundColor(Color(red: 0.82, green: 0.89, blue: 1))
//                                .frame(width: geometry.size.width, height: 77)
//                            
//                            HStack {
//                                Image(systemName: "house.fill")
//                                    .resizable()
//                                    .frame(width: 24, height: 24)
//                                    .foregroundColor(.blue)
//                                
//                                Spacer()
//                                
//                                Image(systemName: "calendar")
//                                    .resizable()
//                                    .frame(width: 24, height: 24)
//                                    .foregroundColor(.green)
//                                
//                                Spacer()
//                                
//                                Image(systemName: "heart.fill")
//                                    .resizable()
//                                    .frame(width: 24, height: 24)
//                                    .foregroundColor(.red)
//                            }
//                            .padding(.horizontal, 40)
//                        }
//                        .frame(width: geometry.size.width, height: 77)
//                        .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
//                    }
//                    
//                    // 右下のプラスボタン
//                    VStack {
//                        Spacer()
//                        HStack {
//                            Spacer()
//                            NavigationLink(
//                                destination: ARView(restoreWorldMap: nil).environmentObject(store)
//                            ) {
//                                ZStack {
//                                    Circle()
//                                        .fill(Color.blue.opacity(0.6))
//                                        .frame(width: 66, height: 66)
//                                        .shadow(radius: 5)
//                                    Image(systemName: "plus")
//                                        .resizable()
//                                        .frame(width: 24, height: 24)
//                                        .foregroundColor(.white)
//                                }
//                            }
//                            .padding(.trailing, 16)
//                            .padding(.bottom, 16)
//                            .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
//                        }
//                    }
//                    
//                    // ★ 自動遷移用 NavigationLink
//                    NavigationLink(
//                        destination: ARView(restoreWorldMap: selectedMap).environmentObject(store),
//                        isActive: $isShowingARView
//                    ) {
//                        EmptyView()
//                    }
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarHidden(true)
//            .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
//        }
//        .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
//    }
//    
//    
//    // スワイプ削除
//    private func deleteRecords(at offsets: IndexSet) {
//        for index in offsets {
//            let record = store.records[index]
//            store.removeWorldMapRecord(record)
//        }
//    }
//    
//}


import SwiftUI
import ARKit

struct SelectionView: View {
    @EnvironmentObject var store: WorldMapStore
    
    @State private var selectedMap: ARWorldMap?
    @State private var isShowingARView = false
    @State private var searchQuery = ""  // Add search query state
    
    var filteredRecords: [WorldMapRecord] {
        // Filter records based on the search query
        if searchQuery.isEmpty {
            return store.records
        } else {
            return store.records.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        // タイトル
                        Text("おもいで")
                            .font(.largeTitle)
                            .padding(.top, 16)
                        
                        // 検索バー
                        HStack(spacing: 0) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: geometry.size.width * 0.8, height: 45)
                                .background(Color(red: 0.92, green: 0.93, blue: 0.94))
                                .cornerRadius(10)
                                .overlay(
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.gray)
                                            .padding(3.6)
                                        TextField("検索", text: $searchQuery) // Bind search text
                                            .padding(7)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .padding(.horizontal, 10)
                                    }
                                    .padding(.horizontal, 10)
                                )
                        }
                        .frame(width: geometry.size.width * 0.8, height: 45)
                        .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
                        
                        // --- Listを使ってスワイプ削除 & タップ復元 ---
                        List {
                            ForEach(filteredRecords) { record in  // Use filteredRecords for the list
                                
                                // 1つのセル
                                VStack(alignment: .leading, spacing: 8) {
                                    // 画像部分
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(.gray.opacity(0.2))
                                            .cornerRadius(16)
                                            .frame(height: 200)
                                        
                                        if let thumbFilename = record.thumbnailFilename,
                                           let thumbImage = ImageFileManager.loadImageFromDocuments(filename: thumbFilename) {
                                            Image(uiImage: thumbImage)
                                                .resizable()
                                                .scaledToFill()
                                                .cornerRadius(16)
                                                .clipped()
                                                .frame(height: 200)
                                        }
                                    }
                                    .contentShape(Rectangle()) // タップ領域
                                    .onTapGesture {
                                        // タップしたらARViewへ
                                        if let loadedMap = store.loadWorldMapFromFile(filename: record.worldMapFilename) {
                                            selectedMap = loadedMap
                                            isShowingARView = true
                                        }
                                    }
                                    
                                    
                                    // ↓ 画像の下に テキストを置く
                                    Text(record.title)
                                        .font(.headline)
                                    Text(record.dateString)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .onDelete(perform: deleteRecords)
                        }
                        .listStyle(PlainListStyle())
                        
                        Spacer()
                        
                        // タブバー風
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color(red: 0.82, green: 0.89, blue: 1))
                                .frame(width: geometry.size.width, height: 77)
                            
                            HStack {
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.green)
                                
                                Spacer()
                                
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 40)
                        }
                        .frame(width: geometry.size.width, height: 77)
                        .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
                    }
                    
                    // 右下のプラスボタン
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationLink(
                                destination: ARView(restoreWorldMap: nil).environmentObject(store)
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.6))
                                        .frame(width: 66, height: 66)
                                        .shadow(radius: 5)
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                            .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
                        }
                    }
                    
                    // ★ 自動遷移用 NavigationLink
                    NavigationLink(
                        destination: ARView(restoreWorldMap: selectedMap).environmentObject(store),
                        isActive: $isShowingARView
                    ) {
                        EmptyView()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
        }
        .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
    }
    
    // スワイプ削除
    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            let record = store.records[index]
            store.removeWorldMapRecord(record)
        }
    }
}
