//
//  DetailMetaView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-14.
//

import SwiftUI

struct DetailMetaView: View {
    var image: String
    var label: String
    var tintColor: Color = .primary
    var backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: image)
            
            Text(label)
                .font(.system(size: 13))
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
