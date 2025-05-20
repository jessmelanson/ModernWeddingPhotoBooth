//
//  MessageSheet.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/3/25.
//

import SwiftUI
import MessageUI

struct MessageSheet: UIViewControllerRepresentable {
  
  // MARK: - Properties
  
  @Environment(\.dismiss) private var dismiss
  @Binding var isLoading: Bool
  let firstTimeShown: Bool
  let attachments: [(data: Data, fileName: String)]
  
  // MARK: - UIViewControllerRepresentable
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  func makeUIViewController(context: Context) -> UIViewController {
    DispatchQueue.main.async {
      isLoading = true
    }
    
    if MFMessageComposeViewController.canSendText() {
      let vc = MFMessageComposeViewController()
      vc.messageComposeDelegate = context.coordinator
      
      vc.body = Strings.MessageSheet.bodyText
      attachments.enumerated().forEach { index, tuple in
        vc.addAttachmentData(
          tuple.data,
          typeIdentifier: Strings.Global.mimeType,
          filename: tuple.fileName
        )
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + (firstTimeShown ? 0.8 : 0.3)) {
        isLoading = false
      }
      
      return vc
    } else {
      let vc = UIViewController()
      DispatchQueue.main.async {
        isLoading = false
        vc.showErrorAlert(Strings.MessageSheet.cannotSendMessageError) {
          dismiss()
        }
      }
      
      return vc
    }
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    // no op
  }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension MessageSheet {
  class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
    var parent: MessageSheet
    
    init(_ parent: MessageSheet) {
      self.parent = parent
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
      if result == .failed {
        controller.showErrorAlert(Strings.MessageSheet.failedToSendMessageError) { [weak self] in
          self?.parent.dismiss()
        }
      } else {
        parent.dismiss()
      }
    }
  }
}

#Preview {
  @Previewable @State var showingSheet = false
  @Previewable @State var isLoading = false
  let attachments = [(
    data: UIImage(resource: .welcomeScreenBackground).jpegData(compressionQuality: 1.0)!,
    fileName: "file1"
  )]
  
  VStack {
    Button(showingSheet ? "Hide" : "Show") {
      showingSheet.toggle()
      print("showingSheet toggled to \(showingSheet)")
    }
  }
  .sheet(isPresented: $showingSheet) {
    MessageSheet(isLoading: $isLoading, firstTimeShown: true, attachments: attachments)
  }
}
