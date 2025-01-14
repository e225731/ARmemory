//
//  Untitled.swift
//  tt
//
//  Created by 川原龍成 on 2025/01/14.
//

import UIKit
import Vision

class ImageProcessing {
    // 画像を切り抜くメソッド
    static func cropImage(image: UIImage) async -> UIImage? {
        // iOS 18以上かどうかを確認
        guard #available(iOS 18.0, *) else {
            print("この機能はiOS 18.0以降でのみ利用可能です。")
            return nil
        }

        // 画像をCIImageに変換
        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        // ImageRequestHandlerの生成
        let imageRequestHandler = ImageRequestHandler(ciImage)

        // GenerateForegroundInstanceMaskRequestの生成
        let request = GenerateForegroundInstanceMaskRequest()

        // セッション開始
        if let result = try? await request.perform(on: ciImage) {
            // 切り抜き対象インスタンスを指定
            if let buffer = try? result.generateMaskedImage(
                for: result.allInstances,
                imageFrom: imageRequestHandler,
                croppedToInstancesExtent: true
            ) {
                // CVPixelBufferからUIImageに変換
                return UIImage.from(pixelBuffer: buffer)
            }
        }
        // 処理が失敗した場合はnilを返す
        return nil
    }
}

extension UIImage {
    // CVPixelBufferからUIImageを作成する拡張メソッド
    static func from(pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
