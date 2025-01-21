//
//  ttApp.swift
//  tt
//
//  Created by 伊佐のの on 2025/01/07.
//

import SwiftUI

@main
struct ttApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
    @StateObject var store = WorldMapStore()
    var body: some Scene {
            WindowGroup {
                // アプリ起動時は SelectionView を表示
                StartView()
                    .environmentObject(store)
            }
        }
}
