//
//  ProgressBar.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var progress: Double
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(progress < 5.0 ? Color.red : Color.green)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress / 10, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(progress < 5.0 ? Color.red : Color.green)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: 0.0...progress)
            Text(String(format: "%.1f%", min(self.progress, 10.0)))
                .font(.system(size: 18, weight: .light, design: .rounded))
                .bold()
                .foregroundColor(.white)

        }
    }
}

extension Color {
    static var white: Color {
        return Color("Text")
    }
}
