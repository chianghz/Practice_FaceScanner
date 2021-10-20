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

    enum PhotoRatio {
        case auto // depends on resolution
        case photo // 4:3
        case square // 1:1
    }

    enum PhotoLibraryError: Error {
        case notAuthorized

        var string: String {
            switch self {
            case .notAuthorized: return "invalid photo library permission"
            }
        }
    }

    // MARK: - Publishers

    private(set) var imagesSaved = PassthroughSubject<Void, Never>()
    private(set) var errorCaptured = PassthroughSubject<Error, Never>()

    // MARK: -

    let photoRatio: PhotoRatio

    init(photoRatio: PhotoRatio) {
        self.photoRatio = photoRatio
    }

    func saveImages(_ images: [UIImage]) {
        PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.addOnly) { [weak self] status in
            guard let self = self else { return }
            guard status == .authorized else {
                self.errorCaptured.send(PhotoLibraryError.notAuthorized)
                return
            }
            for image in images {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(Self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
}

private extension ScannerViewModel {

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.errorCaptured.send(error)
        } else {
            self.imagesSaved.send(())
        }
    }
}
