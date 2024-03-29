//
//  DownloadManager.swift
//  App
//
//  Created by dgsw8th71 on 3/5/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation
import SwiftUI

final class DownloadManager: ObservableObject {
    
    func saveImageToPhotos(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func saveFileToDocuments(data: Data, fileName: String) {
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentsPath.appendingPathComponent(fileName)
            
            do {
                try data.write(to: filePath)
                print("File saved successfully at \(filePath)")
            } catch {
                print("Failed to save file: \(error.localizedDescription)")
            }
        }
    }
}
