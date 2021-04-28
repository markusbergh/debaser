//
//  SettingsView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import Combine
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore

    private var titleLabel: LocalizedStringKey {
        return "Settings"
    }
    private var themeLabel: LocalizedStringKey {
        return "Settings.Theme"
    }
    private var themeToggleLabel: LocalizedStringKey {
        return darkMode.wrappedValue ? "Settings.Theme.DarkMode" : "Settings.Theme.NormalMode"
    }
    private var imagesLabel: LocalizedStringKey {
        return "Settings.Layout.Images"
    }
    private var cancelledLabel: LocalizedStringKey {
        return "Settings.Layout.HideCancelled"
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
                    SettingsSectionAbout()
                    SettingsSectionSpotify()
                    
                    Section(header: Text(themeLabel)) {
                        Toggle("Standard", isOn: systemColorScheme)
                
                        Toggle(isOn: darkMode.animation(.easeInOut)) {
                            HStack {
                                Group {
                                    Text(themeToggleLabel)

                                    Image(systemName: darkMode.wrappedValue ? "moon.fill" : "sun.max")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                .opacity(systemColorScheme.wrappedValue ?  0.5 : 1.0)
                            }
                        }
                        .disabled(systemColorScheme.wrappedValue)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .toggleTint))

                    Section(header: Text("Layout")) {
                        Toggle(imagesLabel, isOn: showImages)
                        Toggle(cancelledLabel, isOn: hideCancelled)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .toggleTint))

                    Section(header: Text(onboardingLabel)) {
                        Button(onboardingShowLabel) {
                            store.dispatch(withAction: .onboarding(.showOnboarding))
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
        .accentColor(.settingsAccent)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var systemColorScheme: Binding<Bool> {
        return Binding<Bool>(
            get: {
                return store.state.settings.systemColorScheme.value
            },
            set: {
                store.dispatch(withAction:.settings(.setOverrideColorScheme($0)))
            }
        )
    }
    
    private var darkMode: Binding<Bool> {
        return Binding<Bool>(
            get: {
                return store.state.settings.darkMode.value
            },
            set: { newValue in
                withAnimation {
                    store.dispatch(withAction:.settings(.setDarkMode(newValue)))
                }
            }
        )
    }
    
    private var showImages: Binding<Bool> {
        return Binding<Bool>(
            get: {
                return store.state.settings.showImages.value
            },
            set: {
                store.dispatch(withAction: .settings(.setShowImages($0)))
            }
        )
    }
    
    private var hideCancelled: Binding<Bool> {
        return Binding<Bool>(
            get: {
                return store.state.settings.hideCancelled.value
            },
            set: {
                store.dispatch(withAction: .settings(.setHideCancelled($0)))
            }
        )
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

struct SettingsSectionAbout: View {
    private var debaserLabel: LocalizedStringKey {
        return "Settings.Debaser"
    }
    private var aboutLabel: LocalizedStringKey {
        return "Settings.Debaser.About"
    }

    var body: some View {
        Section(header: Text(debaserLabel)) {
            NavigationLink(destination: SettingsAboutView()) {
                Text(aboutLabel)
            }
        }
    }
}

struct SettingsSectionSpotify: View {
    @EnvironmentObject var store: AppStore

    private var servicesLabel: LocalizedStringKey {
        return "Settings.Services"
    }
    private var spotifyLabel: LocalizedStringKey {
        return store.state.spotify.isLoggedIn ? "Settings.Spotify.On" : "Settings.Spotify.Off"
    }

    var body: some View {
        Section(header: Text(servicesLabel)) {
            NavigationLink(destination: SettingsSpotifyView()) {
                HStack {
                    HStack {
                        Image("SpotifyIcon")
                        Text("Spotify")
                    }

                    Spacer()

                    Text(spotifyLabel)
                        .foregroundColor(store.state.spotify.isLoggedIn ? .green : .primary)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store

        SettingsView()
            .environment(\.locale, .init(identifier: "sv"))
            .environmentObject(store)
    }
}
