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

struct TabBarItem: Hashable {
    let image: String
    let type: Tab
    let identifier: Tab.Identifier
}

struct TabBar: View {
    @EnvironmentObject var tabViewRouter: TabViewRouter
    
    // MARK: Private
    
    private var items: [TabBarItem] {
        return [
            TabBarItem(image: "music.note.house", type: .list, identifier: .list),
            TabBarItem(image: "heart", type: .favourites, identifier: .favourites),
            TabBarItem(image: "gearshape", type: .settings, identifier: .settings),
        ]
    }
    
    // MARK: Public
    
    @Binding var selectedTab: String
    
    var body: some View {
        HStack(spacing: 0) {
            
            ForEach(items, id:\.self) { item in
                TabBarButton(
                    selectedTab: $selectedTab,
                    image: item.image,
                    type: item.type,
                    identifier: item.identifier
                )
            }
        }
        .padding(TabBarStyle.insetPadding.rawValue)
        .background(Color.tabBarBackground)
        .cornerRadius(TabBarStyle.cornerRadius.rawValue)
        .padding(.horizontal)
        .padding(.bottom, TabBarStyle.paddingBottom.rawValue)
    }
}

// MARK: Tab bar button

struct TabBarButton: View {
    @EnvironmentObject var tabViewRouter: TabViewRouter
    
    // MARK: Public

    @Binding var selectedTab: String

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

// MARK: Button style

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
