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
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isShowingOnboarding = false
    @State private var isAlertPresented = false

    private var titleLabel: LocalizedStringKey {
        return "Settings"
    }
    
    private var themeLabel: LocalizedStringKey {
        return "Settings.Theme"
    }
    
    private var themeToggleLabel: LocalizedStringKey {
        return isDarkMode ? "Settings.Theme.DarkMode" : "Settings.Theme.NormalMode"
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
    
    private var isDarkMode: Bool {
        return darkMode.wrappedValue
    }
    
    private var systemColorScheme: Binding<Bool> {
        return Binding<Bool>(
            get: {
                return store.state.settings.systemColorScheme.value
            },
            set: { newValue in
                withAnimation {
                    store.dispatch(action:.settings(.setOverrideColorScheme(newValue)))
                }
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
                    store.dispatch(action:.settings(.setDarkMode(newValue)))
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
                store.dispatch(action: .settings(.setShowImages($0)))
            }
        )
    }
    
    private var hideCancelled: Binding<Bool> {
        return Binding<Bool>(
            get: {
                return store.state.settings.hideCancelled.value
            },
            set: {
                store.dispatch(action: .settings(.setHideCancelled($0)))
            }
        )
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
                        Toggle("System", isOn: systemColorScheme.animation(.easeInOut))
                            .accessibility(identifier: "ToggleSystemTheme")
                
                        if !systemColorScheme.wrappedValue {
                            let spacing = isDarkMode ? CGFloat(10.0) : CGFloat(5.0)
                            
                            Toggle(isOn: darkMode.animation(.easeInOut)) {
                                HStack(spacing: spacing) {
                                    Group {
                                        Text(themeToggleLabel)

                                        Image(systemName: darkMode.wrappedValue ? "moon.fill" : "sun.max")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                            .accessibility(identifier: "ToggleUserTheme")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .toggleTint))

                    Section(header: Text("Layout")) {
                        Toggle(cancelledLabel, isOn: hideCancelled)
                        Toggle(imagesLabel, isOn: showImages)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .toggleTint))

                    Section(header: Text(onboardingLabel)) {
                        Button(onboardingShowLabel) {
                            isShowingOnboarding = true
                        }
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
            .onChange(of: store.state.spotify.requestError) { error in
                guard let error = error else { return }
                
                switch error {
                case .premiumAccountRequired:
                    isAlertPresented = true
                default:
                    isAlertPresented = false
                }
            }
            .alert(isPresented: $isAlertPresented) {
                Alert(
                    title: Text("Settings.Spotify.Error.Title"),
                    message: Text("Settings.Spotify.Error.Message"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $isShowingOnboarding) {
                OnboardingView()
                    .background(Color.onboardingBackground)
                    .ignoresSafeArea()
                    .preferredColorScheme(colorScheme)
            }
        }
        .accentColor(.settingsAccent)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsViewTopRectangle: View {
    let colorStart = Color.settingsTopGradientStart
    let colorEnd = Color.settingsTopGradientEnd

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [colorStart, colorEnd]),
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

    @State private var showSpotifySettings = false
    
    private var servicesLabel: LocalizedStringKey {
        return "Settings.Services"
    }
    
    private var spotifyLabel: LocalizedStringKey {
        return store.state.spotify.isLoggedIn ? "Settings.Spotify.On" : "Settings.Spotify.Off"
    }
    
    private var spotifyLabelColor: Color {
        return store.state.spotify.isLoggedIn ? .green : .primary
    }
    
    var body: some View {
        Section(header: Text(servicesLabel)) {
            NavigationLink(destination: SettingsSpotifyView(), isActive: $showSpotifySettings) {
                Button(action: {
                    showSpotifySettings = true
                }) {
                    HStack {
                        HStack {
                            Image("SpotifyIcon")
                            Text("Spotify")
                        }

                        Spacer()

                        Text(spotifyLabel)
                            .foregroundColor(spotifyLabelColor)
                    }
                }
            }
        }
        .onReceive(store.state.settings.pushToSpotifySettings) { _ in
            handlePushToSpotifySettings()
        }
        .onDidAppear {
            handlePushToSpotifySettings()
        }
    }
    
    private func handlePushToSpotifySettings() {
        if store.state.settings.pushToSpotifySettings.value == true {
            showSpotifySettings = true
            
            store.dispatch(action: .settings(.resetPushToSpotifySettings))
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
