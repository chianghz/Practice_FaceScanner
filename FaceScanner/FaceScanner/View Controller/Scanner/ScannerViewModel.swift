//
//  ScannerViewModel.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/7.
//

import Foundation
import UIKit
import Combine
import Photos

class ScannerViewModel: NSObject {

    // MARK: - Publishers

    private(set) var imagesSaved = PassthroughSubject<Void, Never>()
    private(set) var errorCaptured = PassthroughSubject<Error, Never>()

    // MARK: -

    enum PhotoLibraryError: Error {
        case notAuthorized

        var string: String {
            switch self {
            case .notAuthorized: return "invalid photo library permission"
            }
        }
    }

    func saveImages(_ images: [UIImage], bounds: CGRect, bank: Bank) {
        PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.addOnly) { [weak self] status in
            guard let self = self else { return }
            guard status == .authorized else {
                self.errorCaptured.send(PhotoLibraryError.notAuthorized)
                return
            }

            let croppedImages = self.cropImages(images, bounds: bounds)
            let resizedImages = self.resizeImages(croppedImages, resolution: bank.resolution)
            self.saveImages(croppedImages)
            self.saveImages(resizedImages)
        }
    }
}

private extension ScannerViewModel {

    func cropImages(_ images: [UIImage], bounds: CGRect) -> [UIImage] {
        return images.compactMap { image in
            let scale = image.size.width / UIScreen.main.bounds.width
            return image.cropImage(rect: bounds, scale: scale)
        }
    }

    func resizeImages(_ images: [UIImage], resolution: Bank.Resolution) -> [UIImage] {
        guard let size = resolution.size ?? images.first?.size else { return [] }
        let targetSize = CGSize(width: size.width / 3.0, height: size.height / 3.0)
        return images.map { $0.imageResized(to: targetSize) }
    }

    func saveImages(_ images: [UIImage]) {
        for image in images {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(Self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.errorCaptured.send(error)
        } else {
            self.imagesSaved.send(())
        }
    }
}
