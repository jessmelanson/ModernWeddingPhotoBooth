//
//  CameraPreview.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
  
  // MARK: - Properties
  
  @EnvironmentObject var cameraManager: CameraManager
  var frame: CGRect
  
  // MARK: - UIViewRepresentable
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear
    
    let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
    previewLayer.frame = frame
    previewLayer.videoGravity = .resizeAspectFill
    context.coordinator.previewLayer = previewLayer
    
    // listen for orientation changes
    NotificationCenter.default.addObserver(
      context.coordinator,
      selector: #selector(context.coordinator.updateVideoOrientation),
      name: UIDevice.orientationDidChangeNotification,
      object: nil
    )
    
    view.layer.addSublayer(previewLayer)
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
      previewLayer.frame = frame
      context.coordinator.updateVideoOrientation()
    }
  }
  
  func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
    NotificationCenter.default.removeObserver(coordinator)
  }
}

// MARK: - Coordinator for device orientation
extension CameraPreview {
  class Coordinator: NSObject {
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @objc func updateVideoOrientation() {
      guard let connection = previewLayer?.connection else { return }
      
      let rotationAngle: CGFloat = UIDevice.current.orientation == .landscapeLeft ? 180 : 0
      if connection.isVideoRotationAngleSupported(rotationAngle) {
        connection.videoRotationAngle = rotationAngle
      }
    }
  }
}
