//
//  SettingsView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    
    // MARK: Private
        
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
    
    private var isDarkMode: Bool {
        return darkMode.wrappedValue
    }
    
    private var bottomPadding: CGFloat {
        guard let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets, safeAreaInsets.bottom > 0 else {
            return 15
        }
        
        return safeAreaInsets.bottom
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
            
    init() {
        UITableView.appearance().backgroundColor = .clear
    }

    var body: some View {
        NavigationView {
            Form {
                Group {
                    SettingsSectionAbout()
                    SettingsSectionSpotify()
                    
                    // For some weird reason, this section crashes if being a subview like
                    // the rest, possibly due to an animated removal/insertion of the row.
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
                    
                    SettingsSectionLayout()
                    SettingsLayoutOnboarding()
                }
                .listRowBackground(Color.settingsListRowBackground)
                
                // Hacky hack to push list up a bit
                Spacer().frame(height: 15)
                    .listRowBackground(Color.settingsBackground)
            }
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
}

struct SettingsViewTopRectangle: View {
    
    // MARK: Public
    
    let colorStart: Color = .settingsTopGradientStart
    let colorEnd: Color = .settingsTopGradientEnd

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(
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

// MARK: - About

struct SettingsSectionAbout: View {
    
    // MARK: Private
    
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

// MARK: - Spotify

struct SettingsSectionSpotify: View {
    @EnvironmentObject var store: AppStore
    
    // MARK: Private

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

// MARK: - Layout

struct SettingsSectionLayout: View {
    @EnvironmentObject var store: AppStore
    
    private var imagesLabel: LocalizedStringKey {
        return "Settings.Layout.Images"
    }
    
    private var cancelledLabel: LocalizedStringKey {
        return "Settings.Layout.HideCancelled"
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
    
    var body: some View {
        Section(header: Text("Layout")) {
            Toggle(cancelledLabel, isOn: hideCancelled)
            Toggle(imagesLabel, isOn: showImages)
        }
        .toggleStyle(SwitchToggleStyle(tint: .toggleTint))
    }
}

// MARK: - Onboarding

struct SettingsLayoutOnboarding: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var isShowingOnboarding = false

    private var onboardingLabel: LocalizedStringKey {
        return "Settings.Onboarding"
    }
    
    private var onboardingShowLabel: LocalizedStringKey {
        return "Settings.Onboarding.Show"
    }
    
    var body: some View {
        Section(header: Text(onboardingLabel)) {
            Button(onboardingShowLabel) {
                isShowingOnboarding = true
            }
            .sheet(isPresented: $isShowingOnboarding) {
                OnboardingView()
                    .background(Color.onboardingBackground)
                    .preferredColorScheme(colorScheme)
                    .ignoresSafeArea()
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
