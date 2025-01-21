//
//  UIImage_Extensions.swift
//  tt
//
//  Created by 川原龍成 on 2025/01/17.
//

import UIKit

extension UIImage {
    
    /// 指定した CGRect で切り抜いた UIImage を返す
    func cropped(to rect: CGRect) -> UIImage? {
        // 1) `cgImage` を取得
        guard let cgImage = self.cgImage else { return nil }
        
        // 2) 画像サイズと cropRect の兼ね合いを考慮して、実際にクロップする CGRect を計算
        //    （もし rect が大きすぎてオーバーしてたら min でクリップするなどの対策が必要）
        let scaledRect = CGRect(
            x: rect.origin.x * self.scale,
            y: rect.origin.y * self.scale,
            width: rect.size.width * self.scale,
            height: rect.size.height * self.scale
        )
        
        // 3) cgImage を cropping
        guard let croppedCGImage = cgImage.cropping(to: scaledRect) else {
            return nil
        }
        
        // 4) 新しい UIImage を生成（scale や orientation を元の画像に合わせる）
        return UIImage(cgImage: croppedCGImage,
                       scale: self.scale,
                       orientation: self.imageOrientation)
    }
    
    /// 指定したサイズにリサイズした UIImage を返す
    func resized(to targetSize: CGSize) -> UIImage? {
        // 1) グラフィックスコンテキストを生成
        UIGraphicsBeginImageContextWithOptions(targetSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        
        // 2) 描画
        let rect = CGRect(origin: .zero, size: targetSize)
        self.draw(in: rect)
        
        // 3) 新しく描画された UIImage を取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage
    }
}
