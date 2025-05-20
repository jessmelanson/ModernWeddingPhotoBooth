//
//  PermissionsManager.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import AVFoundation
import Photos

class PermissionsManager: ObservableObject {
  
  // MARK: - Properties
  
  var cameraPermissionGranted: Bool {
    AVCaptureDevice.authorizationStatus(for: .video) == .authorized
  }
  
  var photoLibraryPermissionGranted: Bool {
    PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
  }
  
  var allPermissionsGranted: Bool {
    cameraPermissionGranted && photoLibraryPermissionGranted
  }
  
  // MARK: - Public
  
  func checkCameraPermission(completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      completion(true)
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    default:
      completion(false)
    }
  }
  
  func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
    switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
    case .authorized, .limited:
      completion(true)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          completion(self.photoLibraryPermissionGranted)
        }
      }
    default:
      completion(false)
    }
  }
}
