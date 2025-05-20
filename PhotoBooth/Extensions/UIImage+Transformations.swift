//
//  UIImage+Conversion.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/3/25.
//

import UIKit

extension UIImage {
  var jpegData: Data {
    return jpegData(compressionQuality: 1.0) ?? Data()
  }
  
  /// See https://stackoverflow.com/questions/11667565/how-to-rotate-an-image-90-degrees-on-ios.
  func rotated(by degrees: CGFloat) -> UIImage {
    let radians = degrees * .pi / 180
    let rotatedSize = CGRect(origin: .zero, size: size)
      .applying(CGAffineTransform(rotationAngle: radians))
      .integral
      .size
    
    UIGraphicsBeginImageContext(rotatedSize)
    if let context = UIGraphicsGetCurrentContext() {
      let origin = CGPoint(
        x: rotatedSize.width / 2.0,
        y: rotatedSize.height / 2.0
      )
      context.translateBy(x: origin.x, y: origin.y)
      context.rotate(by: radians)
      draw(in: CGRect(
        x: -origin.y,
        y: -origin.x,
        width: size.width,
        height: size.height
      ))
      let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return rotatedImage ?? self
    }
    
    return self
  }
  
  func flippedHorizontally() -> UIImage {
    if let cgImage = self.cgImage {
      return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation.horizontallyFlipped)
    }
    return self
  }
}

extension UIImage.Orientation {
  var horizontallyFlipped: UIImage.Orientation {
    switch self {
    case .up: return .upMirrored
    case .upMirrored: return .up
    case .down: return .downMirrored
    case .downMirrored: return .down
    case .left: return .rightMirrored
    case .rightMirrored: return .left
    case .right: return .leftMirrored
    case .leftMirrored: return .right
    @unknown default: return self
    }
  }
}
