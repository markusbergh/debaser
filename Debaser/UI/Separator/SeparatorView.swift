//
//  SeparatorView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-14.
//

import SwiftUI

struct SeparatorView: View {
    
    // MARK: Private
    
    private var strokeGradient: LinearGradient {
        return LinearGradient(
            gradient: Gradient(
                colors: [
                    .detailSeparatorGradientStart,
                    .detailSeparatorGradientEnd
                ]
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: Public
    
    let size: Int = 10
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = max(geometry.size.width, geometry.size.height)
                let totalLines = Int(round(width / CGFloat(size)))
                
                var lines = [CGPoint]()
                
                for index in 0...totalLines {
                    let isEven = index % 2 == 0
                    
                    let point = CGPoint(x: index * size, y: isEven ? size : 0)
                    lines.append(point)
                }
                
                path.addLines(lines)
            }
            .stroke(strokeGradient)
        }
    }
}

struct SeparatorView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            SeparatorView()
                .previewLayout(.fixed(width: 500, height: 10))
                .preferredColorScheme($0)
        }
    }
}
