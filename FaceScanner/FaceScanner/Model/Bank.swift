//
//  Bank.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/21.
//

import Foundation
import CoreGraphics

enum Bank: CaseIterable {
    case 兴业银行
    case 邮政银行
    case 中国银行
    case 中国工商银行
    case 中国农业银行

    var localizedString: String {
        switch self {
        case .兴业银行: return "兴业银行"
        case .邮政银行: return "邮政银行"
        case .中国银行: return "中国银行"
        case .中国工商银行: return "中国工商银行"
        case .中国农业银行: return "中国农业银行"
        }
    }

    var resolution: Resolution {
        switch self {
        case .邮政银行, .中国银行: return .auto
        case .兴业银行, .中国工商银行: return ._480x640
        case .中国农业银行: return ._256x256
        }
    }

    var imageFormat: ImageFormat {
        return .jpg
    }

}

extension Bank {
    
    enum Resolution {
        case auto
        case _480x640
        case _256x256

        var size: CGSize? {
            switch self {
            case .auto: return nil
            case ._480x640: return CGSize(width: 480, height: 640)
            case ._256x256: return CGSize(width: 256, height: 256)
            }
        }
    }

    enum ImageFormat {
        case jpg
    }
}

