//
//  ScannerViewModel.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/7.
//

import Foundation

class ScannerViewModel {

    enum PhotoRatio {
        case auto // depends on resolution
        case photo // 4:3
        case square // 1:1
    }

    // MARK: - Publishers

    // MARK: -

    let photoRatio: PhotoRatio

    init(photoRatio: PhotoRatio) {
        self.photoRatio = photoRatio
    }

}
