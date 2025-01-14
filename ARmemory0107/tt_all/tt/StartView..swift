import SwiftUI

struct StartView: View {
    @State private var navigateToSelectView = false // 遷移状態を管理
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景画像を画面いっぱいに表示
                Image("ARmemory")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all) // 安全領域を無視して画面全体に表示
                
                VStack {
                  // NavigationLinkでの遷移
                   NavigationLink(
                       destination: SelectionView()
                           .navigationBarBackButtonHidden(true), // バックボタン非表示
                       isActive: $navigateToSelectView
                   ) {
                       EmptyView()
                   }
               } 
            }
            .onAppear {
                // 2秒後に自動で遷移
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    navigateToSelectView = true
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // iPad対応で見た目を統一
    }
}


