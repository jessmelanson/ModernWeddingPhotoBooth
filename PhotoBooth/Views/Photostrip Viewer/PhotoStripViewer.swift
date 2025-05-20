//
//  PhotoStripViewer.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import SwiftUI

struct PhotoStripViewer: View {
  
  // MARK: - Properties
  
  enum ShareOption: Identifiable {
    case mail, messages
    
    var id: String {
      switch self {
      case .mail: return "mail"
      case .messages: return "messages"
      }
    }
  }
  
  @EnvironmentObject var cameraManager: CameraManager
  @EnvironmentObject var photoStripManager: PhotoStripManager
  
  @Binding var path: [DestinationScreen]
  @State private var showingSheet = false
  @State private var isLoading = false
  @State private var processedAttachments = [(data: Data, fileName: String)]()
  @State private var firstTimeMailSheetShown = true
  @State private var firstTimeMessageSheetShown = true
  
  // MARK: - Views
  
  private var loadingView: some View {
    HStack {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle())
        .frame(width: 50, height: 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
  
  private var errorView: some View {
    VStack {
      Text(Strings.PhotoStripView.photoStripCreationFailedError)
        .font(.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Color.background.opacity(0.6).ignoresSafeArea()
        
        VStack {
          switch photoStripManager.processingStatus {
          case .notStarted, .inProgress:
            loadingView
          case .success(let photoStrip):
            if let photoStrip {
              Image(uiImage: photoStrip)
                .resizable()
                .scaledToFit()
                .padding(15)
              
            } else {
              errorView
            }
          case .failed:
            errorView
          }
          
          VStack(spacing: 0) {
            let buttonWidth: CGFloat = geometry.size.width * 0.3 - 20
            
            if photoStripManager.processingStatus.image != nil {
              ScalingAnimationButton(
                title: Strings.PhotoStripView.shareButtonTitle,
                useLargeFont: false,
                backgroundColor: .button,
                icon: .email
              ) {
                showingSheet = true
              }
              .frame(width: buttonWidth > 0 ? buttonWidth : nil)
              .padding(.bottom, 15)
            }
            
            ScalingAnimationButton(
              title: Strings.Global.restart,
              useLargeFont: false,
              backgroundColor: .black.opacity(0.55),
              icon: .restart
            ) {
              // clear out current images & photostrip
              cameraManager.resetData()
              photoStripManager.resetData()
              
              // go back to welcome screen
              path.removeAll()
            }
            .frame(width: buttonWidth > 0 ? buttonWidth : nil)
            .padding(.bottom, 15)
          }
        }
        .frame(maxWidth: geometry.size.width * 0.9, alignment: .center)
      }
    }
    .onAppear {
      processAttachments()
    }
    .sheet(isPresented: $showingSheet) {
      ShareSheetView(
        attachments: processedAttachments.map { $0.data }
      )
      .overlay {
        if isLoading {
          loadingView
        }
      }
    }
    .navigationBarBackButtonHidden()
  }
  
  // MARK: - Private
  
  private func processAttachments() {
    if showingSheet {
      isLoading = true
    }
    
    DispatchQueue.global(qos: .utility).async {
      let attachments = self.getAttachments()
      
      DispatchQueue.main.async {
        self.processedAttachments = attachments
        self.isLoading = false
      }
    }
  }
  
  private func getAttachments() -> [(data: Data, fileName: String)] {
    let images = if let photoStrip = photoStripManager.processingStatus.image {
      [photoStrip] + cameraManager.capturedImages
    } else {
      cameraManager.capturedImages
    }
    
    return images.enumerated().compactMap { index, image in
      guard let data = image.jpegData(compressionQuality: 1.0) else {
        return nil
      }
      return (data: data, fileName: Strings.Global.fileName(index: index))
    }
  }
}

// MARK: - Previews

fileprivate struct PreviewPhotoStripViewer: View {
  let processingStatus: PhotoStripManager.ProcessingStatus
  
  var body: some View {
    @State var path = [DestinationScreen]()
    let permissionsManager = PermissionsManager()
    let photoStripManager = PhotoStripManager(permissionsManager: permissionsManager)
    photoStripManager.processingStatus = processingStatus
    
    return PhotoStripViewer(path: $path)
      .environmentObject(CameraManager(permissionsManager: permissionsManager, photoStripManager: photoStripManager))
      .environmentObject(photoStripManager)
  }
}

#Preview {
  PreviewPhotoStripViewer(processingStatus: .success(UIImage.transparentSnowPhotostripBackground))
}

#Preview {
  PreviewPhotoStripViewer(processingStatus: .inProgress)
}

#Preview {
  PreviewPhotoStripViewer(processingStatus: .failed)
}

#Preview {
  PreviewPhotoStripViewer(processingStatus: .notStarted)
}

