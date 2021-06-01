//
//  DetailMetaView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-14.
//

import SwiftUI

struct DetailMetaView: View {
    
    enum DetailMeteType: String {
        case age = "person"
        case admission = "banknote"
        case open = "clock"
    }
    
    // MARK: Public
    
    var type: DetailMeteType? = nil
    var label: String
    var labelColor: Color = .primary
    var tintColor: Color = .primary
    var backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 2) {
            if let type = type {
                Image(systemName: type.rawValue)
            }
            
            Text(label)
                .foregroundColor(labelColor)
                .font(Font.Variant.tiny.font)
        }
        .frame(minHeight: 20)
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
        DetailMetaView(type: .age,
                       label: "Age 18",
                       labelColor: .white,
                       tintColor: .white,
                       backgroundColor: .blue)
    }
}
