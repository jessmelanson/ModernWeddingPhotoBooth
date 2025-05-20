//
//  CameraManager.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import AVFoundation
import Photos
import SwiftUI

class CameraManager: NSObject, ObservableObject {
  
  // MARK: - Properties
  
  private let permissionsManager: PermissionsManager
  private let photoStripManager: PhotoStripManager
  
  let session = AVCaptureSession()
  let photoOutput = AVCapturePhotoOutput()
  
  @Published var isSessionRunning = false
  @Published var capturedImages = [UIImage]()
  
  // MARK: - Lifecycle
  
  init(
    permissionsManager: PermissionsManager,
    photoStripManager: PhotoStripManager
  ) {
    self.permissionsManager = permissionsManager
    self.photoStripManager = photoStripManager
    super.init()
    setUpObservers()
    configureSession()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Public
  
  func startSession() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self, !self.session.isRunning else {
        return
      }
      self.session.startRunning()
    }
  }
  
  func stopSession() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self, self.session.isRunning else { return }
      self.session.stopRunning()
    }
  }
  
  func takePicture() {
    let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    photoSettings.flashMode = .off
    photoOutput.capturePhoto(with: photoSettings, delegate: self)
  }
  
  func resetData() {
    capturedImages = []
  }
  
  // MARK: - Private
  
  private func configureSession() {
    guard permissionsManager.allPermissionsGranted else { return }
    
    session.beginConfiguration()
    
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
          let input = try? AVCaptureDeviceInput(device: device) else {
      print("Couldn't access camera")
      return
    }
    
    session.sessionPreset = .photo
    
    if session.canAddInput(input) {
      session.addInput(input)
    }
    
    if session.canAddOutput(photoOutput) {
      session.addOutput(photoOutput)
    } else {
      print("Couldn't add photo output")
    }
    
    session.commitConfiguration()
  }
  
  private func setUpObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleSessionNotification(_:)),
      name: AVCaptureSession.didStartRunningNotification,
      object: session
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleSessionNotification(_:)),
      name: AVCaptureSession.didStopRunningNotification,
      object: session
    )
  }
  
  @objc private func handleSessionNotification(_ notification: Notification) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      if notification.name == AVCaptureSession.didStartRunningNotification {
        self.isSessionRunning = true
      } else if notification.name == AVCaptureSession.didStopRunningNotification {
        self.isSessionRunning = false
      }
    }
  }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let error,
       let topVC = UIApplication.topViewController() {
      topVC.showErrorAlert(error.localizedDescription)
      return
    }
    
    if let data = photo.fileDataRepresentation(),
       let image = UIImage(data: data) {
      let currentOrientation = UIDevice.current.orientation
      let updatedImage = image
        .rotated(by: currentOrientation == .landscapeLeft ? 90 : -90)
        .flippedHorizontally()
      capturedImages.append(updatedImage)
    }
  }
}
