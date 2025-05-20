//
//  ContentView.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import SwiftUI

struct WelcomeView: View {
  
  // MARK: - Properties
  
  @EnvironmentObject var permissionsManager: PermissionsManager
  @Binding var path: [DestinationScreen]
  @State private var showErrorAlert = false
  
  // MARK: - Views
  
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .center) {
        Color.background.ignoresSafeArea()
        
        Image(.welcomeScreenBackground)
          .resizable()
          .ignoresSafeArea()
          .aspectRatio(contentMode: .fill)
          .frame(width: geometry.size.width, height: geometry.size.height)
        
        VStack(alignment: .center) {
          Spacer()
          
          VStack {
            Text(Strings.WelcomeView.title)
              .font(.custom("SnellRoundhand-Bold", size: 72))
              .foregroundStyle(.text)
              .multilineTextAlignment(.center)
              .padding(.bottom, 28)
            
            Text(Strings.WelcomeView.description)
              .font(.system(size: 40))
              .foregroundStyle(.text)
              .multilineTextAlignment(.center)
          }
          .padding(36)
          .frame(width: geometry.size.width * 0.75)
          .background(.black.opacity(0.6))
          .clipShape(RoundedRectangle(cornerRadius: 10))
          
          Spacer()
          
          ScalingAnimationButton(
            title: Strings.WelcomeView.buttonText,
            useLargeFont: true,
            backgroundColor: .button
          ) {
            path.append(.activePhotoShoot)
          }
          .frame(width: geometry.size.width * 0.3)
          
          Spacer()
        }
        .frame(width: geometry.size.width * 0.7)
      }
    }
    .onAppear {
      checkPermissions()
    }
    .alert(Strings.WelcomeView.errorAlertText, isPresented: $showErrorAlert) {
      Button(Strings.Global.ok, role: .cancel) {
        showErrorAlert = false
      }
    }
  }
  
  // MARK: - Private
  
  private func checkPermissions() {
    permissionsManager.checkCameraPermission { cameraPermissionGranted in
      if cameraPermissionGranted {
        permissionsManager.checkPhotoLibraryPermission { photoLibraryPermissionGranted in
          if !photoLibraryPermissionGranted {
            showPermissionsError()
          }
        }
      } else {
        showPermissionsError()
      }
    }
  }
  
  private func showPermissionsError() {
    showErrorAlert = true
  }
}

// MARK: - Preview
#Preview {
  @Previewable @State var path = [DestinationScreen]()
  let permissionsManager = PermissionsManager()
  let photoStripManager = PhotoStripManager(permissionsManager: permissionsManager)
  NavigationStack {
    WelcomeView(path: $path)
  }
  .environmentObject(permissionsManager)
  .environmentObject(CameraManager(permissionsManager: permissionsManager, photoStripManager: photoStripManager))
  .environmentObject(photoStripManager)
}
