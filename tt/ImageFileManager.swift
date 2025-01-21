//
//  ImageFileManager.swift
//  tt
//
//  Created by 川原龍成 on 2025/01/13.
//

import Foundation
import UIKit

struct ImageFileManager {
    
    /// 画像をドキュメントディレクトリに保存し、ファイル名(パス)を返す
    static func saveImageToDocuments(_ image: UIImage) -> String? {
        // ユニークIDを作る（ファイル名の代わり）
        let filename = UUID().uuidString + ".png"
        
        guard let data = image.pngData() else { return nil }
        
        // DocumentsフォルダのURLを取得
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return filename // 保存に成功したらファイル名を返す
        } catch {
            print("Error saving image to documents:", error)
            return nil
        }
    }
    
    /// ドキュメントディレクトリから画像ファイルを読み込み、UIImageを返す
    static func loadImageFromDocuments(filename: String) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }
}
