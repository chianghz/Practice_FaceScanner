//
//  UIImage+Extension.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/20.
//

import UIKit

extension UIImage {
    func cropImage(rect: CGRect, scale: CGFloat) -> UIImage? {
        var newRect = rect
        newRect.origin.y = (self.size.height - (rect.size.height * scale)) / scale / 2.0

        // Article: https://medium.com/@joehattori/cropping-images-in-swift-and-the-basics-of-uiimage-cgimage-and-ciimage-42608e4531bb
        // Github: https://github.com/joehattori/image-cropping-ios
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newRect.size.width * scale,
                                                      height: newRect.size.height * scale), true, 0.0)
        self.draw(at: CGPoint(x: -newRect.origin.x * scale, y: -newRect.origin.y * scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
}
