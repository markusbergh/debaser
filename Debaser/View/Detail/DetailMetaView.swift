//
//  DetailMetaView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-14.
//

import SwiftUI

struct DetailMetaView: View {
    var image: String?
    var label: String
    var labelSize: CGFloat = 13
    var labelColor: Color = .primary
    var tintColor: Color = .primary
    var backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 2) {
            if let image = image {
                Image(systemName: image)
            }
            
            Text(label)
                .foregroundColor(labelColor)
                .font(.system(size: labelSize))
        }
        .foregroundColor(tintColor)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(backgroundColor)
        )

    }
}

struct DetailMetaView_Previews: PreviewProvider {
    static var previews: some View {
        DetailMetaView(image: "star", label: "Test", backgroundColor: .blue)
    }
}
