//
//  Strings.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import Foundation

struct Strings {
  struct Global {
    static let ok = "OK"
    static let restart = "Restart"
    static let cancel = "Cancel"
    static let ios = "iOS"
    static let android = "Android"
    static let mimeType = "image/jpeg"
    static let error = "Error"
    static let headerOnPhotoStrip = "I & M"
    static let textOnPhotoStrip = """
    Spouse 1 & Spouse 2
    January 1, 2025
    City, State
    """
    
    static func fileName(index: Int) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd-HH-mm"
      let dateString = formatter.string(from: Date())
      return "wedding-photobooth-\(index + 1)-\(dateString).jpg"
    }
  }
  
  struct WelcomeView {
    static let title = "Spouse 1 & Spouse 2's Wedding Photo Booth"
    static let description = "Tap \"Start\" to start taking photos. You'll be prompted to take 3 photos."
    static let buttonText = "Start"
    static let errorAlertText = "Enable camera permissions in settings to use the photo booth."
  }
  
  struct PhotoStripView {
    static let shareButtonTitle = "Share"
    static let shareTitle = "Share Photostrip"
    static let email = "Email"
    static let iMessage = "iMessage (iOS Only)"
    static let photoStripCreationFailedError = "Failed to create photostrip. Please try again."
  }
  
  struct MailSheet {
    static let subjectText = "Spouce 1 & Spouse 2's wedding photobooth photostrip"
    static let bodyText = "Thanks for joining us at our wedding! Here's your photostrip from the photobooth."
    static let cannotSendMailError = "Cannot send mail. Please ask to take a look at the iPad."
    static let failedToSendMessageError = "Failed to send email. Please try again."
  }
  
  struct MessageSheet {
    static let bodyText = "Thanks for joining us! Here's your photostrip from the photobooth at Spouse 1 & Spouse 2's wedding."
    static let cannotSendMessageError = "Cannot send message. Please ask Jess to take a look at the iPad."
    static let failedToSendMessageError = "Failed to send message. Please try again."
  }
}
