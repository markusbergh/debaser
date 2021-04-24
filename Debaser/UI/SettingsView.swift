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
    private var darkModeLabel: LocalizedStringKey {
        return "Settings.Layout.DarkMode"
    }
    private var imagesLabel: LocalizedStringKey {
        return "Settings.Layout.Images"
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
            VStack {
                Form {
                    Group {
                        SettingsSectionAbout()
                        SettingsSectionSpotify()

                        Section(header: Text("Layout")) {
                            Toggle(darkModeLabel, isOn: darkMode())
                            Toggle(imagesLabel, isOn: showImages())
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
                .navigationBarTitle(titleLabel, displayMode: .large)

                Spacer()

                Text("v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)")
                    .font(.system(size: 15))
                    .padding(.bottom, 90)
            }
            .background(
                Color.settingsBackground
                    .ignoresSafeArea()
            )
        }
        .accentColor(.settingsAccent)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func darkMode() -> Binding<Bool> {
        let darkMode = Binding<Bool>(
            get: {
                return store.state.settings.darkMode.value
            },
            set: {
                store.dispatch(withAction:.settings(.setDarkMode($0)))
            }
        )

        return darkMode
    }

    private func showImages() -> Binding<Bool> {
        let showImages = Binding<Bool>(
            get: {
                return store.state.settings.showImages.value
            },
            set: {
                store.dispatch(withAction: .settings(.setShowImages($0)))
            }
        )

        return showImages
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
    private var servicesLabel: LocalizedStringKey {
        return "Settings.Services"
    }
    private var spotifyOnLabel: LocalizedStringKey {
        return "Settings.Spotify.On"
    }
    private var spotifyOffLabel: LocalizedStringKey {
        return "Settings.Spotify.Off"
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

                    Text(spotifyOffLabel)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let store: Store<AppState, AppAction> = Store(
            initialState: AppState(
                list: ListState(),
                settings: SettingsState(),
                onboarding: OnboardingState()
            ),
            reducer: appReducer
        )

        SettingsView()
            .environment(\.locale, .init(identifier: "sv"))
            .environmentObject(store)
    }
}
