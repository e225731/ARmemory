import SwiftUI

struct SelectionView: View {
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    // 画面全体
                    VStack {
                        // 1. タイトルと検索バー（固定）
                        VStack(spacing: 16) {
                            // タイトル
                            Text("おもいで")
                                .font(Font.custom("Inria Sans", size: 30).weight(.bold))
                                .foregroundColor(.black)
                                .padding(.top, 16)
                            
                            // 検索バー
                            HStack(spacing: 0) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: geometry.size.width * 0.8, height: 45) // 相対的な幅
                                    .background(Color(red: 0.92, green: 0.93, blue: 0.94))
                                    .cornerRadius(10)
                                    .overlay(
                                        HStack {
                                            // 検索アイコン
                                            Image(systemName: "magnifyingglass")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.gray)
                                                .padding(3.6)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 10)
                                    )
                            }
                            .frame(width: geometry.size.width * 0.8, height: 45) // 相対的な幅
                        }
                        .padding(.horizontal, 16)
                        
                        // 2. シーン部分（スクロール可能）
                        ScrollView {
                            VStack(spacing: 16) {
                                // シーンの内容
                                ForEach(0..<10, id: \.self) { _ in
                                    // シーン（Rectangle 2）
                                    VStack(alignment: .leading, spacing: 8) {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: geometry.size.width * 0.9, height: 200) // 相対的な幅
                                            .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                                            .cornerRadius(29)
                                            .shadow(
                                                color: Color(red: 0, green: 0, blue: 0, opacity: 0.25),
                                                radius: 4,
                                                y: 4
                                            )
                                        
                                        // テキスト
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("卒業式")
                                                .font(Font.custom("Inria Sans", size: 16).weight(.bold))
                                                .lineSpacing(20)
                                                .foregroundColor(.black)
                                            
                                            Text("2024年11月12日")
                                                .font(Font.custom("Inria Sans", size: 16).weight(.bold))
                                                .lineSpacing(20)
                                                .foregroundColor(.black)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                        .padding(.top, 16)
                        
                        Spacer()
                        
                        // 3. タブボタン（固定）
                        ZStack {
                            HStack(spacing: 0) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: geometry.size.width, height: 77) // 相対的な幅
                                    .background(Color(red: 0.82, green: 0.89, blue: 1))
                            }
                            .frame(width: geometry.size.width, height: 77) // 相対的な幅
                            
                            // タブボタン（アイコン群）
                            HStack {
                                // ホームボタン
                                HStack(spacing: 0) {
                                    Image(systemName: "house.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                }
                                .padding(5)
                                .frame(width: 40, height: 40)
                                
                                Spacer()
                                
                                // カレンダーアイコン
                                HStack(spacing: 0) {
                                    Image(systemName: "calendar")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.green)
                                }
                                .padding(EdgeInsets(top: 5, leading: 6.25, bottom: 5, trailing: 7.08))
                                .frame(width: 40, height: 40)
                                
                                Spacer()
                                
                                // ハートアイコン
                                VStack(spacing: 0) {
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.red)
                                }
                                .padding(
                                    EdgeInsets(top: 7.90, leading: 3.77, bottom: 4.69, trailing: 3.67)
                                )
                                .frame(width: 37.65, height: 40)
                            }
                            .padding(.horizontal, 16)
                            .frame(width: geometry.size.width, height: 77) // 相対的な幅
                        }
                    }
                    
                    // プラスボタンを右下に配置
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationLink(destination: ARView()) {
                                ZStack {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.white)
                                        .padding(20)
                                }
                                .frame(width: 81, height: 82)
                                .background(Color(red: 0.67, green: 0.89, blue: 0.99))
                                .cornerRadius(500)
                                .shadow(radius: 5)
                                .padding(.trailing, 16) // 右側の余白
                                .padding(.bottom, 100) // 下側の余白
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SelectView_Previews: PreviewProvider {
    static var previews: some View {
        SelectionView()
            .previewDevice("iPhone 14") // 特定のデバイスでのプレビュー
    }
}
