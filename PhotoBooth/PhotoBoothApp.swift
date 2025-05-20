//
//  PhotoBoothApp.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import SwiftUI

// MARK: - Navigation Helpers
enum DestinationScreen: Hashable {
  case activePhotoShoot
  case photoStripViewer
}

// MARK: - App
@main
struct PhotoBoothApp: App {
  
  // MARK: - Properties
  
  @State private var path = [DestinationScreen]()
  private let permissionsManager: PermissionsManager
  private let photoStripManager: PhotoStripManager
  private let cameraManager: CameraManager
  
  // MARK: - Lifecycle
  
  init() {
    let permissionsManager = PermissionsManager()
    let photoStripManager = PhotoStripManager(permissionsManager: permissionsManager)
    self.permissionsManager = permissionsManager
    self.photoStripManager = photoStripManager
    self.cameraManager = CameraManager(
      permissionsManager: permissionsManager,
      photoStripManager: photoStripManager
    )
  }
  
  // MARK: - Views
  
  var body: some Scene {
    WindowGroup {
      NavigationStack(path: $path) {
        WelcomeView(path: $path)
          .navigationDestination(for: DestinationScreen.self) { destination in
            switch destination {
            case .activePhotoShoot:
              ActivePhotoShootView(path: $path)
            case .photoStripViewer:
              PhotoStripViewer(path: $path)
            }
          }
      }
      .environmentObject(permissionsManager)
      .environmentObject(photoStripManager)
      .environmentObject(cameraManager)
    }
  }
}
