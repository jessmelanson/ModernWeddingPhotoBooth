//
//  ActivePhotoShootView.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import SwiftUI

struct ActivePhotoShootView: View {
  
  // MARK: - Properties
  
  @EnvironmentObject var cameraManager: CameraManager
  @EnvironmentObject var photoStripManager: PhotoStripManager
  @Binding var path: [DestinationScreen]
  
  @State private var showCountdownTimer = false
  @State private var countdownValue = CountdownTimer.totalCountdownTime
  @State private var currentCycle = 1
  @State private var isFlashing = false
  @State private var showLastPicture = false
  
  private let totalCycles = 3
  
  // MARK: - Views
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Color.background.ignoresSafeArea()
 
          ZStack {
            if cameraManager.isSessionRunning {
              CameraPreview(
                frame: .init(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
              )
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
              
              if showCountdownTimer {
                let timerSize = geometry.size.height * 0.25
                CountdownTimer(countdownValue: countdownValue)
                  .frame(width: timerSize, height: timerSize)
              }
            } else {
              Color.gray.ignoresSafeArea()
                .frame(maxWidth: .infinity)
              
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          
        VStack {
          Spacer()
          
          HStack(spacing: 15) {
            let imageHeight: CGFloat = geometry.size.height * 0.15
            let imageWidth: CGFloat = imageHeight * (4/3)
            
            Spacer()
            
            ForEach(0..<totalCycles, id: \.self) { index in
              if let image = cameraManager.capturedImages[safe: index] {
                Image(uiImage: image)
                  .resizable()
                  .scaledToFit()
                  .frame(width: imageWidth, height: imageHeight)
              } else {
                Color.black.opacity(0.4)
                  .frame(width: imageWidth, height: imageHeight)
              }
            }
            
            Spacer()
          }
          .frame(maxHeight: geometry.size.height * 0.17)
          .frame(width: geometry.size.width)
          .background(.background.opacity(0.7))
        }
          
        }
        
        if isFlashing {
          Color.black.ignoresSafeArea()
        }
        
        if showLastPicture,
           let last = cameraManager.capturedImages.last {
          Image(uiImage: last)
            .resizable()
            .ignoresSafeArea()
        }
      }
    .ignoresSafeArea()
    .onAppear {
      cameraManager.startSession()
    }
    .onChange(of: cameraManager.isSessionRunning) { _, newValue in
      if newValue {
        startCountdownCycle()
      }
    }
    .onDisappear() {
      cameraManager.stopSession()
    }
    .navigationBarBackButtonHidden()
  }
  
  // MARK: - Private
  
  private func startCountdownCycle() {
    guard currentCycle <= totalCycles else {
      showCountdownTimer = false
      return
    }
    
    showCountdownTimer = true
    countdownValue = CountdownTimer.totalCountdownTime
    
    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
      if countdownValue > 0 {
        countdownValue -= 1
      } else {
        showCountdownTimer = false
        timer.invalidate()
        takePicture()
      }
    }
  }
  
  private func takePicture() {
    cameraManager.takePicture()
    withAnimation(.linear(duration: 0.2)) {
      isFlashing = true
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      isFlashing = false
      showLastPicture = true
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        withAnimation(.easeInOut(duration: 0.5)) {
          showLastPicture = false
        }
        
        currentCycle += 1
        if currentCycle <= totalCycles {
          startCountdownCycle()
        } else {
          showCountdownTimer = false
          photoStripManager.createPhotoStrip(images: cameraManager.capturedImages)
          path.append(.photoStripViewer)
        }
      }
    }
  }
}

// MARK: - Preview
#Preview {
  @Previewable @State var path = [DestinationScreen]()
  let  permissionsManager = PermissionsManager()
  ActivePhotoShootView(path: $path)
    .environmentObject(CameraManager(permissionsManager: permissionsManager, photoStripManager: PhotoStripManager(permissionsManager: permissionsManager)))
}
