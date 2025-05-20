//
//  MailSheet.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/3/25.
//

import SwiftUI
import MessageUI

struct MailSheet: UIViewControllerRepresentable {
  
  // MARK: - Properties
  
  @Environment(\.dismiss) private var dismiss
  @Binding var isLoading: Bool
  let firstTimeShown: Bool
  let attachments: [(data: Data, fileName: String)]
  
  // MARK: - UIViewControllerRepresentable
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIViewController(context: Context) -> UIViewController {
    DispatchQueue.main.async {
      isLoading = true
    }
    
    if MFMailComposeViewController.canSendMail() {
      let vc = MFMailComposeViewController()
      vc.mailComposeDelegate = context.coordinator
      
      vc.setSubject(Strings.MailSheet.subjectText)
      vc.setMessageBody(Strings.MailSheet.bodyText, isHTML: false)
      attachments.enumerated().forEach { index, tuple in
        vc.addAttachmentData(
          tuple.data,
          mimeType: Strings.Global.mimeType,
          fileName: tuple.fileName
        )
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + (firstTimeShown ? 0.8 : 0.3)) {
        isLoading = false
      }
      
      return vc
    } else {
      let vc = UIViewController()
      DispatchQueue.main.async {
        vc.showErrorAlert(Strings.MailSheet.cannotSendMailError) {
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

// MARK: - MFMailComposeViewControllerDelegate
extension MailSheet {
  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    var parent: MailSheet
    
    init(_ parent: MailSheet) {
      self.parent = parent
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
      if let error {
        controller.showErrorAlert(error.localizedDescription) { [weak self] in
          self?.parent.dismiss()
        }
      } else if case .failed = result {
        controller.showErrorAlert(Strings.MailSheet.failedToSendMessageError) { [weak self] in
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
    MailSheet(isLoading: $isLoading, firstTimeShown: true, attachments: attachments)
  }
}
