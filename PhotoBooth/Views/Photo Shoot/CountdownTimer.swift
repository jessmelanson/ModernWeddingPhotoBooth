//
//  CountdownTimer.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import SwiftUI

struct CountdownTimer: View {
  let countdownValue: Double
  
  static let totalCountdownTime: Double = 3
  
  var body: some View {
    ZStack {
      ProgressView(value: countdownValue, total: CountdownTimer.totalCountdownTime) {
        // no label
      } currentValueLabel: {
        Text("\(Int(countdownValue))")
      }
      .progressViewStyle(CircularCountdownProgressStyle())
    }
  }
}

struct CircularCountdownProgressStyle: ProgressViewStyle {
  private let strokeWidth: CGFloat = 15
  
  func makeBody(configuration: Configuration) -> some View {
    let fractionCompleted = configuration.fractionCompleted ?? 0
    
    ZStack {
      Circle()
        .stroke(lineWidth: strokeWidth)
        .foregroundStyle(.white.opacity(0.5))
      
      Circle()
        .trim(from: 0, to: fractionCompleted)
        .stroke(.white, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
        .rotationEffect(.degrees(-90))
        .animation(.linear, value: fractionCompleted)
      
      Circle()
        .fill(.white.opacity(0.2))
        .padding(strokeWidth/2)
      
      if let currentValueLabel = configuration.currentValueLabel {
        currentValueLabel
          .font(.system(size: 80))
          .fontWeight(.bold)
          .foregroundStyle(.white)
      }
    }
  }
}

#Preview {
  @Previewable @State var countdownValue = CountdownTimer.totalCountdownTime
  var timer: Timer?
  
  ZStack {
    Color.blue.ignoresSafeArea()
    CountdownTimer(countdownValue: countdownValue)
      .frame(width: 200, height: 200)
  }
  .onAppear {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
      if countdownValue > 0 {
        countdownValue -= 1
      } else {
        countdownValue = CountdownTimer.totalCountdownTime
      }
    }
  }
  .onDisappear {
    timer?.invalidate()
    timer = nil
  }
}
