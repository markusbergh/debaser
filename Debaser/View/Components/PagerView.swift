//
//  PagerView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-08.
//

import SwiftUI

struct PagerView: View {
    let testing: [Color] = [.gray, .black, .gray, .black]
    
    @State var offset: CGFloat = 0
    
    var body: some View {
        ScrollView(.init()) {
            TabView {
                ForEach(testing.indices, id:\.self) { index in
                    if index == 0 {
                        testing[index]
                            .overlay(
                                GeometryReader { geometry -> Color in
                                    let minX = geometry.frame(in: .global).midX
                                    
                                    DispatchQueue.main.async {
                                        withAnimation(.default) {
                                            self.offset = -minX
                                        }
                                    }
                                    
                                    return Color.clear
                                }
                                .frame(width: 0, height: 0),
                                alignment: .leading
                            )
                    } else {
                        testing[index]
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .overlay(
                HStack(spacing: 25) {
                    ForEach(testing.indices, id:\.self) { index in
                        Capsule()
                            .fill(Color.white)
                            .frame(width: 7, height: 7)
                    }
                }
                .overlay(
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 18, height: 7)
                        .offset(x: getOffset())
                    ,
                    alignment: .leading
                )
                .padding(.bottom, 25),
                alignment: .bottom
            )
        }
        .ignoresSafeArea()
    }
    
    private func getIndex() -> Int {
        let width = UIScreen.main.bounds.width
        let index = Int(round(Double(offset / width)))
        
        return index
    }
    
    private func getOffset() -> CGFloat {
        let progress = offset / UIScreen.main.bounds.width
        
        // Spacing is 20, width is 7, == 27
        return 28 * progress
    }
}

struct PagerView_Previews: PreviewProvider {
    static var previews: some View {
        /*
        PagerView(pageCount: 3, currentIndex: $currentPage) {
            Color.red
            Color.blue
            Color.yellow
        }
        */
        
        PagerView()
    }
}
