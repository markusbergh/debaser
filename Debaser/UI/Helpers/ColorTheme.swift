//
//  ColorTheme.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-08.
//

import SwiftUI
import UIKit

/*
public class ColorTheme {
    private struct Palette {
        static let listTopGradientStart = UIColor(named: "ListTopGradientStart")
    }
}
*/

extension Color {
    /// Generic
    static let toggleTint = Color("ToggleTint")
    static let progressIndicator = Color("ProgressIndicator")
    static let tabBarBackground = Color("TabBarBackground")
    static let tabBarBorder = Color("TabBarBorder")
    
    /// List
    static let listTopGradientStart = Color("ListTopGradientStart")
    static let listTopGradientEnd = Color("ListTopGradientEnd")
    static let listBackground = Color("ListBackground")
    static let listRowBackground = Color("ListRowBackground")
    static let listRowShadowBackground = Color("ListRowShadowBackground")
    static let listRowStrokeGradientStart = Color("ListRowStrokeGradientStart")
    static let listRowStrokeGradientEnd = Color("ListRowStrokeGradientEnd")
    static let listDivider = Color("ListDivider")
    static let listSearchBarBorder = Color("SearchBarBorder")
    
    /// Detail
    static let detailBackground = Color("DetailBackground")
    static let detailContentBackground = Color("DetailContentBackground")
    static let detailSeparatorGradientStart = Color("DetailSeparatorGradientStart")
    static let detailSeparatorGradientEnd = Color("DetailSeparatorGradientEnd")
    static let detailViewMetaPrimary = Color("DetailViewMetaPrimary")
    static let detailViewMetaSecondary = Color("DetailViewMetaSecondary")
    static let detailViewMetaTertiary = Color("DetailViewMetaTertiary")
    static let detailBackButtonTint = Color("DetailBackButtonTint")
    static let detailFavouriteRibbonBackground = Color("DetailFavouriteRibbonBackground")
    
    /// Settings
    static let settingsTopGradientStart = Color("SettingsTopGradientStart")
    static let settingsTopGradientEnd = Color("SettingsTopGradientEnd")
    static let settingsBackground = Color("SettingsBackground")
    static let settingsListRowBackground = Color("SettingsListRowBackground")
    static let settingsAccent = Color("SettingsAccent")
    
    /// Onboarding
    static let onboardingBackground = Color("OnboardingBackground")
}

extension UIColor {
    /// List
    static let listTopGradientStart = UIColor(named: "ListTopGradientStart")
    static let listTopGradientEnd = UIColor(named: "ListTopGradientEnd")
    static let listBackground = UIColor(named: "ListBackground")
    
    /// Tab Bar
    static let tabBarBackground = UIColor(named: "TabBarBackground")
    static let tabBarBorder = UIColor(named: "TabBarBorder")
    
    /// Onboarding
    static let onboardingBackground = UIColor(named: "OnboardingBackground")
    static let onboardingText = UIColor(named: "OnboardingText")
    static let onboardingSkipLabel = UIColor(named: "OnboardingSkipLabel")
    static let onboardingSkipLabelHighlight = UIColor(named: "OnboardingSkipHighlight")
    static let onboardingCloseButton = UIColor(named: "OnboardingCloseButton")
    static let onboardingCloseButtonHighlight = UIColor(named: "OnboardingCloseButtonHighlight")
    static let onboardingCloseButtonLabel = UIColor(named: "OnboardingCloseButtonLabel")
    static let onboardingCloseButtonLabelHighlight = UIColor(named: "OnboardingCloseButtonLabelHighlight")
    static let onboardingSpotifyButton = UIColor(named: "OnboardingSpotifyButton")
    static let onboardingSpotifyButtonHighlight = UIColor(named: "OnboardingSpotifyButtonHighlight")
    static let onboardingSpotifyButtonLabel = UIColor(named: "OnboardingSpotifyButtonLabel")
    static let onboardingSpotifyButtonLabelHighlight = UIColor(named: "OnboardingSpotifyButtonLabelHighlight")
    static let onboardingScreenBackground = UIColor(named: "OnboardingScreenBackground")
    static let onboardingPageControlColor = UIColor(named: "OnboardingPageControlColor")
    static let onboardingPageControlActiveColor = UIColor(named: "OnboardingPageControlActiveColor")
    
    /// iMessage Extension
    static let iMessageLabelBackground = UIColor(named: "iMessageLabelBackground")
}
