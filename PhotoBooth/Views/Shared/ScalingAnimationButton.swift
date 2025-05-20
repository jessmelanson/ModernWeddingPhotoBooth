//
//  ScalingAnimationButton.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import SwiftUI

struct ScalingAnimationButton: View {
  
  // MARK: - Properties
  
  enum Icon {
    case email, message, restart
    
    var imageView: Image {
      switch self {
      case .email: Image(systemName: "envelope")
      case .message: Image(systemName: "message")
      case .restart: Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
      }
    }
  }
  
  let title: String
  let useLargeFont: Bool
  let backgroundColor: Color
  var icon: Icon? = nil
  let action: (() -> Void)
  
  private var pointSize: CGFloat {
    let size = UIFont.preferredFont(forTextStyle: useLargeFont ? .title2 : .title2).pointSize
    return size * 0.8
  }
  
  // MARK: - Views
  
  var body: some View {
    Button(action: action) {
      HStack {
        if let icon {
          icon.imageView
            .resizable()
            .scaledToFit()
            .frame(maxHeight: pointSize)
            .padding(.trailing, 5)
        }
        
        Text(title)
          .font(useLargeFont ? .title : .title2)
          .fontWeight(.bold)
      }
      .padding(15)
      .frame(maxWidth: .infinity)
      .background(backgroundColor)
      .foregroundStyle(.white)
      .cornerRadius(10)
    }
    .buttonStyle(ScalingButtonStyle())
  }
}

// MARK: - Button Style
struct ScalingButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
  }
}

// MARK: - Preview
#Preview {
  @Previewable @State var path = [DestinationScreen]()
  
  NavigationStack(path: $path) {
    VStack(spacing: 10) {
      ScalingAnimationButton(
        title: "Start",
        useLargeFont: true,
        backgroundColor: .button,
        action: {
          print("Tapped button")
        }
      )
      
      ScalingAnimationButton(title: "Email", useLargeFont: false, backgroundColor: .button, icon: .email) {
        path.append(.photoStripViewer)
      }
      
      ScalingAnimationButton(title: "Restart", useLargeFont: false, backgroundColor: .secondary, icon: .restart) {
        path.append(.photoStripViewer)
      }
    }
  }
}

