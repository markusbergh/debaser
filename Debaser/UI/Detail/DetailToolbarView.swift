//
//  DetailToolbarView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-14.
//

import SwiftUI

struct DetailToolbarView: View {
    
    private var statusBarHeight: CGFloat {
        return UIApplication.shared.windows.first(
            where: { $0.isKeyWindow }
        )?.windowScene?.statusBarManager?.statusBarFrame.height ?? 44
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: statusBarHeight + 25)
            
            HStack {
                DetailBackButtonView(isStreaming: .constant(false))
                
                Spacer()
            }

            Spacer().frame(height: 25)
        }
        .padding(.horizontal, 25)
        .background(Color.detailBackground)
        .frame(minWidth: 0, maxWidth: .infinity)
        .ignoresSafeArea()
    }
}

struct DetailToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        DetailToolbarView()
    }
}
