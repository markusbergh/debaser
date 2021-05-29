//
//  ListHeaderView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-16.
//

import SwiftUI

struct ListHeaderView: View {
    @EnvironmentObject var store: AppStore

    private var searchPlaceholder: LocalizedStringKey {
        return "List.Search"
    }
    
    @Binding private var isDarkMode: Bool
    @Binding private var currentSearch: String
    
    let headline: String
    let label: LocalizedStringKey
        
    init(headline: String, label: LocalizedStringKey, isDarkMode: Binding<Bool>, currentSearch: Binding<String>) {
        self.headline = headline
        self.label = label
        self._isDarkMode = isDarkMode
        self._currentSearch = currentSearch
        
        // For easier text handling...
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        
        return dateFormatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            Image("Icon")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .padding(.bottom, 10)
            
            TextField(searchPlaceholder, text: $currentSearch)
                .disableAutocorrection(true)
                .padding()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.listSearchBarBorder)
                )
                .padding(.bottom, 10)
            
            if currentSearch.isEmpty {
                VStack(spacing: 10) {
                    HStack(alignment: .lastTextBaseline) {
                        Text(Date(), formatter: dateFormatter)
                            .font(Font.Variant.small(weight: .regular).font)
                        
                        Divider()
                            .background(Color.listDivider)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .frame(maxHeight: 50)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(label)
                                .font(Font.Variant.tiny.font)
                            Text(headline)
                                .font(Font.Variant.large(weight: .bold).font)
                        }
                        
                        Spacer()
                        
                        if store.state.settings.systemColorScheme.value == false {
                            VStack(alignment: .trailing, spacing: 5) {
                                Image(systemName: isDarkMode ? "moon.fill" : "sun.max")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .opacity(store.state.settings.systemColorScheme.value ? 0.5 : 1.0)
                                    .transition(
                                        .asymmetric(
                                            insertion: .scale(scale: 0.5).combined(with: .opacity).animation(.easeOut(duration: 0.25).delay(0.25)),
                                            removal: .opacity.animation(.linear(duration: 0.25))
                                        )
                                    )
                                    .id("\(isDarkMode)")

                                Toggle("", isOn: $isDarkMode)
                                    .toggleStyle(SwitchToggleStyle(tint: .listSearchBarBorder))
                                    .frame(width: 90)
                                    .offset(y: 2)
                                    .disabled(store.state.settings.systemColorScheme.value)
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

struct ListHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id:\.self) {
            ListHeaderView(
                headline: "Stockholm",
                label: "Dagens konserter",
                isDarkMode: .constant(true),
                currentSearch: .constant("")
            )
            .previewLayout(.fixed(width: 390, height: 250))
            .preferredColorScheme($0)
        }
    }
}
