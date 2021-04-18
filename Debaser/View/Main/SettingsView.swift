//
//  SettingsView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

struct SettingsView: View {
    @State private var showImages = true
    @State private var isDarkMode = false
    
    private var titleLabel: LocalizedStringKey {
        return "Settings"
    }
    private var debaserLabel: LocalizedStringKey {
        return "Settings.Debaser"
    }
    private var aboutLabel: LocalizedStringKey {
        return "Settings.Debaser.About"
    }
    private var servicesLabel: LocalizedStringKey {
        return "Settings.Services"
    }
    private var spotifyOnLabel: LocalizedStringKey {
        return "Settings.Spotify.On"
    }
    private var spotifyOffLabel: LocalizedStringKey {
        return "Settings.Spotify.Off"
    }
    private var imagesLabel: LocalizedStringKey {
        return "Settings.Layout.Images"
    }
    private var darkModeLabel: LocalizedStringKey {
        return "Settings.Layout.DarkMode"
    }
    private var onboardingLabel: LocalizedStringKey {
        return "Settings.Onboarding"
    }
    private var onboardingShowLabel: LocalizedStringKey {
        return "Settings.Onboarding.Show"
    }
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }

    var body: some View {
        NavigationView {
            Form {
                Group {
                    Section(header: Text(debaserLabel)) {
                        NavigationLink(destination: Text("Om")) {
                            Text(aboutLabel)
                        }
                    }
                    
                    Section(header: Text(servicesLabel)) {
                        NavigationLink(destination: Text("Spotify")) {
                            HStack {
                                Text("Spotify")
                                
                                Spacer()
                                
                                Text(spotifyOffLabel)
                            }
                        }
                    }
                    
                    Section(header: Text("Layout")) {
                        Toggle(imagesLabel, isOn: $showImages)
                        Toggle(darkModeLabel, isOn: $isDarkMode)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .toggleTint))
                    
                    Section(header: Text(onboardingLabel)) {
                        Button(onboardingShowLabel) {
                            
                        }
                        .foregroundColor(.primary)
                    }
                }
                .listRowBackground(Color.settingsListRowBackground)
            }
            .background(
                SettingsViewTopRectangle(),
                alignment: .top
            )
            .background(
                Color.settingsBackground
                    .ignoresSafeArea()
            )
            .navigationBarTitle(titleLabel, displayMode: .large)
        }
    }
}

struct SettingsViewTopRectangle: View {
    let colorStart = Color.settingsTopGradientStart
    let colorEnd = Color.settingsTopGradientEnd
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient:
                        Gradient(
                            colors: [colorStart, colorEnd]
                        ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .edgesIgnoringSafeArea(.top)
            .frame(height: 250)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.locale, .init(identifier: "sv"))
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    }
}
