//
//  ShareSheetView.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/17/25.
//

import SwiftUI
import UIKit

struct ShareSheetView: UIViewControllerRepresentable {
  let attachments: [Data]
  
  // Required method to create the UIViewController
  func makeUIViewController(context: Context) -> UIActivityViewController {
    let vc = UIActivityViewController(activityItems: attachments + [EmailActivityItemSource()], applicationActivities: nil)
    
    // Exclude specific activities
    vc.excludedActivityTypes = [
      .addToHomeScreen, .addToReadingList, .postToWeibo, .assignToContact, .markupAsPDF,
      .postToFacebook, .message, .openInIBooks, .postToVimeo, .postToTwitter,
      .postToFlickr, .postToTencentWeibo, .saveToCameraRoll, .sharePlay, .print
    ]
    
    // Configure popover for iPad
    if let popover = vc.popoverPresentationController {
      popover.sourceView = context.coordinator.rootView // Use the Coordinator's rootView
      popover.sourceRect = CGRect(
        x: UIScreen.main.bounds.midX,
        y: UIScreen.main.bounds.midY,
        width: 0,
        height: 0
      )
      popover.permittedArrowDirections = []
    }
    
    return vc
  }
  
  // Required method to update the UIViewController (no-op in this case)
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
  
  // Required method to create a Coordinator
  func makeCoordinator() -> Coordinator {
    return Coordinator()
  }
  
  // Coordinator class for managing UIKit-specific tasks
  class Coordinator {
    let rootView = UIView() // A dummy view to act as the source view for the popover
  }
}

class EmailActivityItemSource: NSObject, UIActivityItemSource {
  let subject = Strings.MailSheet.subjectText
  let body = Strings.MailSheet.bodyText
  
  // Provide the body of the email (or other shared content)
  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return body
  }
  
  // Provide the actual content for specific activity types
  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
    return body
  }
  
  // Provide the subject for email sharing
  func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
    return activityType == .mail ? subject : ""
  }
}
