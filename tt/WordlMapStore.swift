//
//  WordlMapStore.swift
//  tt
//
//  Created by 川原龍成 on 2025/01/17.
//

import SwiftUI
import ARKit



/// 複数ワールドマップを管理するクラス
class WorldMapStore: ObservableObject {
    @Published var records: [WorldMapRecord] = []
    
    private let recordsKey = "WorldMapRecords"  // UserDefaultsで配列を保存するキー
    
    init() {
        loadRecords()
    }
    
    // MARK: - 読み書き
    
    func loadRecords() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: recordsKey) {
            do {
                let decoded = try JSONDecoder().decode([WorldMapRecord].self, from: data)
                self.records = decoded
            } catch {
                print("Failed to decode WorldMapRecords: \(error)")
            }
        }
    }
    
    func saveRecords() {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(records)
            defaults.set(data, forKey: recordsKey)
        } catch {
            print("Failed to encode WorldMapRecords: \(error)")
        }
    }
    
    // MARK: - 新規レコード追加
    
    /// ARWorldMapをファイルに保存し、records に追加 (サムネイルファイル名も渡せる)
    func addWorldMapRecord(_ map: ARWorldMap,
                           title: String,
                           dateString: String,
                           thumbnailFilename: String? = nil)
    {
        guard let mapFilename = saveWorldMapToFile(map) else {
            print("Failed to save world map file.")
            return
        }
        
        let newRecord = WorldMapRecord(
            title: title,
            dateString: dateString,
            worldMapFilename: mapFilename,
            thumbnailFilename: thumbnailFilename
        )
        records.append(newRecord)
        saveRecords()
    }
    
    // MARK: - ワールドマップ保存
    
    func saveWorldMapToFile(_ worldMap: ARWorldMap) -> String? {
        let filename = "worldmap_\(UUID().uuidString).data"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(filename)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Error saving ARWorldMap to file: \(error)")
            return nil
        }
    }
    
    // MARK: - ワールドマップ読み込み
    
    func loadWorldMapFromFile(filename: String) -> ARWorldMap? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found: \(filename)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let map = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
            return map
        } catch {
            print("Error loading ARWorldMap from file: \(error)")
            return nil
        }
    }
    
    // MARK: - 削除 (オプション)
    func removeWorldMapRecord(_ record: WorldMapRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            let filename = records[index].worldMapFilename
            removeFile(filename: filename)
            
            // サムネファイルも削除
            if let thumbName = records[index].thumbnailFilename {
                removeFile(filename: thumbName)
            }
            
            records.remove(at: index)
            saveRecords()
        }
    }
    
    private func removeFile(filename: String) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted file: \(filename)")
            } catch {
                print("Error deleting file: \(error)")
            }
        }
    }
}
