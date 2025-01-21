//
//  WorldMapRecord.swift
//  tt
//
//  Created by 川原龍成 on 2025/01/17.
//

import SwiftUI
import ARKit

struct WorldMapRecord: Identifiable, Codable {
    let id = UUID()
    let title: String
    let dateString: String
    let worldMapFilename: String
    
    /// サムネイル画像のファイル名（nil の場合はなし）
    let thumbnailFilename: String?
    
    init(title: String, dateString: String, worldMapFilename: String, thumbnailFilename: String? = nil) {
        self.title = title
        self.dateString = dateString
        self.worldMapFilename = worldMapFilename
        self.thumbnailFilename = thumbnailFilename
    }
}
