//
//  photoStripManager.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/4/25.
//

import UIKit

class PhotoStripManager: ObservableObject {
  
  // MARK: - Properties
  
  enum ProcessingStatus {
    case notStarted
    case inProgress
    case success(UIImage?)
    case failed
    
    var image: UIImage? {
      if case let .success(image) = self {
        return image
      }
      
      return nil
    }
  }
  
  private let permissionsManager: PermissionsManager
  
  @Published var processingStatus: ProcessingStatus = .notStarted
  
  // MARK: - Lifecycle
  
  init(permissionsManager: PermissionsManager) {
    self.permissionsManager = permissionsManager
  }
  
  // MARK: - Public
  
  func createPhotoStrip(images: [UIImage]) {
    guard images.count == 3 else { return }
    processingStatus = .inProgress

    let dpi: CGFloat = 300
    let canvasSize = CGSize(width: 2 * dpi, height: 6 * dpi)
    let headerSectionHeight = canvasSize.height * (1/16)
    let totalImageSectionHeight = canvasSize.height * (3/4)
    let imageSectionHeight = totalImageSectionHeight / 3
    let bottomTextSectionHeight = canvasSize.height * (3/16)
    
    let topPadding: CGFloat = dpi * 0.08
    let verticalPaddingBetweenImages: CGFloat = dpi * 0.01
    let horizontalPadding: CGFloat = dpi * 0.05

    let renderer = UIGraphicsImageRenderer(size: canvasSize)

    let finalImage = renderer.image { context in
      UIColor.background.setFill()
      context.fill(CGRect(origin: .zero, size: canvasSize))

      let backgroundImage = UIImage.transparentSnowPhotostripBackground
      let backgroundRect = CGRect(origin: .zero, size: canvasSize)
      backgroundImage.draw(in: backgroundRect)

      let shadow = NSShadow()
      shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
      shadow.shadowBlurRadius = 4
      shadow.shadowOffset = CGSize(width: 2, height: 2)

      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .center

      let headerAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "SnellRoundhand-Bold", size: dpi / 4) ?? UIFont.systemFont(ofSize: dpi / 4),
        .foregroundColor: UIColor.white,
        .paragraphStyle: paragraphStyle,
        .shadow: shadow
      ]

      NSString(string: Strings.Global.headerOnPhotoStrip).draw(
        in: CGRect(
          x: horizontalPadding,
          y: topPadding,
          width: canvasSize.width - (2 * horizontalPadding),
          height: headerSectionHeight
        ),
        withAttributes: headerAttributes
      )

      for (index, image) in images.enumerated() {
        let yOffset = topPadding + headerSectionHeight + CGFloat(index) * imageSectionHeight + CGFloat(index) * verticalPaddingBetweenImages
        let containerRect = CGRect(
          x: horizontalPadding,
          y: yOffset,
          width: canvasSize.width - (2 * horizontalPadding),
          height: imageSectionHeight - verticalPaddingBetweenImages
        )
        let targetRect = calculateAspectFitRect(for: image.size, in: containerRect)
        image.draw(in: targetRect)
      }

      let bottomAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "SnellRoundhand-Bold", size: dpi / 7.5) ?? UIFont.systemFont(ofSize: dpi / 7.5),
        .foregroundColor: UIColor.white,
        .paragraphStyle: paragraphStyle,
        .shadow: shadow
      ]

      NSString(string: Strings.Global.textOnPhotoStrip).draw(
        in: CGRect(
          x: horizontalPadding,
          y: canvasSize.height - bottomTextSectionHeight + (bottomTextSectionHeight - dpi / 8) / 2 - dpi * 0.16,
          width: canvasSize.width - (2 * horizontalPadding),
          height: bottomTextSectionHeight
        ),
        withAttributes:
          bottomAttributes
      )
    }

    if finalImage.size != .zero {
      saveToPhotoLibrary(image: finalImage)
      processingStatus = .success(finalImage)
    } else {
      processingStatus = .failed
    }
  }

  func resetData() {
    processingStatus = .notStarted
  }
  
  // MARK: - Private

  private func calculateAspectFitRect(for imageSize: CGSize, in containerRect: CGRect) -> CGRect {
    let widthRatio = containerRect.width / imageSize.width
    let heightRatio = containerRect.height / imageSize.height
    let scale = min(widthRatio, heightRatio)

    let newWidth = imageSize.width * scale
    let newHeight = imageSize.height * scale

    let xOffset = (containerRect.width - newWidth) / 2 + containerRect.origin.x
    let yOffset = (containerRect.height - newHeight) / 2 + containerRect.origin.y

    return CGRect(x: xOffset, y: yOffset, width: newWidth, height: newHeight)
  }
  
  private func saveToPhotoLibrary(image: UIImage) -> Void {
    guard permissionsManager.photoLibraryPermissionGranted else { return }
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
  }
}
