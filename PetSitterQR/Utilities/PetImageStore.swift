//
//  PetImageStore.swift
//  PetSitterQR
//
//  Created by Codex on 2025-11-16.
//

import Foundation
import UIKit

struct PetImageStore {
    static let shared = PetImageStore()

    private let cache = NSCache<NSString, UIImage>()
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func saveImage(_ image: UIImage, for identifier: String) throws {
        guard let data = image.jpegData(compressionQuality: 0.85) ?? image.pngData() else {
            throw PetImageStoreError.encodingFailed
        }

        let url = try fileURL(for: identifier)
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        cache.setObject(image, forKey: identifier as NSString)
    }

    func loadImage(for identifier: String) -> UIImage? {
        if let cached = cache.object(forKey: identifier as NSString) {
            return cached
        }

        guard let url = try? fileURL(for: identifier), let data = try? Data(contentsOf: url) else {
            return nil
        }

        guard let image = UIImage(data: data) else {
            return nil
        }

        cache.setObject(image, forKey: identifier as NSString)
        return image
    }

    func deleteImage(for identifier: String) throws {
        cache.removeObject(forKey: identifier as NSString)
        let url = try fileURL(for: identifier)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    private func fileURL(for identifier: String) throws -> URL {
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw PetImageStoreError.unableToFindDocumentsDirectory
        }
        return documents.appendingPathComponent("PetImages", isDirectory: true)
            .appendingPathComponent(identifier)
    }
}

enum PetImageStoreError: Error {
    case encodingFailed
    case unableToFindDocumentsDirectory
}
