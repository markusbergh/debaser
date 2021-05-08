//
//  Theme.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-08.
//

import SwiftUI
import UIKit

// MARK: - Colors

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
    static let listRowOverlayGradient = Color("ListRowOverlayGradient")
        
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
    static let detailMapPinTint = Color("DetailMapPinTint")
    
    /// Favourite
    static let favouriteBackgroundIconTint = Color("FavouriteBackgroundIconTint")
    
    /// Settings
    static let settingsTopGradientStart = Color("SettingsTopGradientStart")
    static let settingsTopGradientEnd = Color("SettingsTopGradientEnd")
    static let settingsBackground = Color("SettingsBackground")
    static let settingsListRowBackground = Color("SettingsListRowBackground")
    static let settingsAccent = Color("SettingsAccent")
    
    /// Onboarding
    static let onboardingBackground = Color("OnboardingBackground")
    
    /// Widget
    static let widgetBackground = Color("WidgetBackground")
    static let widgetMetaData = Color("WidgetMetaData")
    static let widgetOverlay = Color("WidgetOverlay")
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


// MARK: - Fonts

extension UIFont {
    enum Family: String  {
        case title = "DelaGothicOne-Regular"
        
        func of(size: CGFloat) -> UIFont {
            guard let customFont = UIFont(name: self.rawValue, size: size) else {
                fatalError("""
                    Failed to load the font.
                    Make sure the font file is included in the project and the font name is spelled correctly.
                    """
                )
            }
            
            return customFont
        }
    }
}

extension Font {
    enum Family: String {
        case title = "DelaGothicOne-Regular"
        
        func of(size: CGFloat) -> Font {
            return Font.custom(self.rawValue, fixedSize: size)
        }
    }

    enum Variant {
        case large(weight: Font.Weight)
        case body(weight: Font.Weight)
        case small(weight: Font.Weight)
        case smaller(weight: Font.Weight)
        case tiny
        case micro(weight: Font.Weight)
        case mini(weight: Font.Weight)
        
        var font: Font? {
            switch self {
            case .large(let weight):
                return .system(size: 29, weight: weight)
            case .body(let weight):
                return .system(size: 19, weight: weight)
            case .small(let weight):
                return .system(size: 17, weight: weight)
            case .smaller(let weight):
                return .system(size: 16, weight: weight)
            case .tiny:
                return .system(size: 15)
            case .micro(let weight):
                return .system(size: 12, weight: weight)
            case .mini(let weight):
                return .system(size: 11, weight: weight)
            }
        }
    }
}
