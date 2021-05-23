//
//  ListProgressIndicatorView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-23.
//

import SwiftUI

struct ListProgressIndicatorView: View {
    let isShowingActivityIndicator: Bool
    
    var body: some View {
        if isShowingActivityIndicator {
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .progressIndicator))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(50)
                    .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.3))
            .ignoresSafeArea()
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
    }
}
