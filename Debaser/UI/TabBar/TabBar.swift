//
//  TabBar.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-09.
//

import SwiftUI

enum TabBarStyle: CGFloat {
    case height = 35
    case insetPadding = 15
    case paddingBottom = 40
    case cornerRadius = 25
}

struct TabBar: View {
    @EnvironmentObject var tabViewRouter: TabViewRouter
    
    @Binding var selectedTab: String
    
    @State private var tabPoints: [CGFloat] = []
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                selectedTab: $selectedTab,
                tabPoints: $tabPoints,
                image: "music.note.house",
                type: .list,
                identifier: .list
            )
            
            TabBarButton(
                selectedTab: $selectedTab,
                tabPoints: $tabPoints,
                image: "heart",
                type: .favourites,
                identifier: .favourites
            )
            
            TabBarButton(
                selectedTab: $selectedTab,
                tabPoints: $tabPoints,
                image: "gearshape",
                type: .settings,
                identifier: .settings
            )
        }
        .padding(TabBarStyle.insetPadding.rawValue)
        .background(Color.tabBarBackground)
        .cornerRadius(TabBarStyle.cornerRadius.rawValue)
        .padding(.horizontal)
        .padding(.bottom, TabBarStyle.paddingBottom.rawValue)
    }
}

struct TabBarButton: View {
    @EnvironmentObject var tabViewRouter: TabViewRouter

    @Binding var selectedTab: String
    @Binding var tabPoints: [CGFloat]

    var image: String
    var type: Tab
    var identifier: Tab.Identifier
        
    var body: some View {
        let tabBarButtonImage = "\(image)\(selectedTab == image ? ".fill" : "")"
        
        return AnyView(
            Button(action: {
                withAnimation {
                    selectedTab = image
                }
                    
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
                                    
                tabViewRouter.currentTab = type
            }, label: {
                Image(systemName: tabBarButtonImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            })
            .buttonStyle(ScaleButtonStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibility(identifier: identifier.rawValue)
        )
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
        ContentView()
            .environmentObject(TabViewRouter())
    }
}
