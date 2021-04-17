//
//  TabBar.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-09.
//

import SwiftUI

enum TabBarStyle: CGFloat {
    case height = 35
    case paddingBottom = 40
    case cornerRadius = 25
}

struct TabBar: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @Binding var selectedTab: String
    @State var tabPoints: [CGFloat] = []
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(image: "mic", type: .list, selectedTab: $selectedTab, tabPoints: $tabPoints)
            TabBarButton(image: "heart", type: .favourites, selectedTab: $selectedTab, tabPoints: $tabPoints)
            TabBarButton(image: "message", type: .news, selectedTab: $selectedTab, tabPoints: $tabPoints)
            TabBarButton(image: "gearshape", type: .settings, selectedTab: $selectedTab, tabPoints: $tabPoints)
        }
        .padding()
        .background(
            Color.tabBarBackground
        )
        .cornerRadius(TabBarStyle.cornerRadius.rawValue)
        .padding(.horizontal)
        .padding(.bottom, TabBarStyle.paddingBottom.rawValue)
    }
    
//    func getCurvePoint() -> CGFloat {
//        if tabPoints.isEmpty {
//            return 10
//        } else {
//            switch selectedTab {
//            case "star":
//                return tabPoints[1]
//            case "gearshape":
//                return tabPoints[2]
//            default:
//                return tabPoints[0]
//            }
//        }
//    }
}

struct TabBarButton: View {
    var image: String
    var type: Page

    @EnvironmentObject var viewRouter: ViewRouter
    @Binding var selectedTab: String
    @Binding var tabPoints: [CGFloat]
        
    var body: some View {
        GeometryReader { geometry -> AnyView in
            let midX = geometry.frame(in: .global).midX
            
            DispatchQueue.main.async {
                if tabPoints.count <= 3 {
                    tabPoints.append(midX)
                }
            }
            
            let tabBarButtonImage = "\(image)\(selectedTab == image ? ".fill" : "")"
            
            return AnyView(
                Button(action: {
                    withAnimation {
                        selectedTab = image
                    }
                        
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                                        
                    viewRouter.currentPage = type
                }, label: {
                    Image(systemName: tabBarButtonImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                })
                .buttonStyle(ScaleButtonStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        }
        .frame(height: TabBarStyle.height.rawValue)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.3 : 1)
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewRouter: ViewRouter())
    }
}
