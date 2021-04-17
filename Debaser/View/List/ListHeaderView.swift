//
//  ListHeaderView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-16.
//

import SwiftUI

struct ListHeaderView: View {
    var headline: String
    var label: String
    
    @Binding var isDarkMode: Bool
    @Binding var currentSearch: String
    
    init(headline: String, label: String, isDarkMode: Binding<Bool>, currentSearch: Binding<String>) {
        self.headline = headline
        self.label = label
        self._isDarkMode = isDarkMode
        self._currentSearch = currentSearch
    }
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        
        return dateFormatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            Image("Logotype")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.primary)
                .frame(width: 50)
                .padding(.bottom, 10)
            
            TextField("Sök konsert", text: $currentSearch)
                .padding()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.listSearchBarBorder)
                )
                .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                HStack(alignment: .lastTextBaseline) {
                    Text(Date(), formatter: dateFormatter)
                        .font(.system(size: 17))
                    
                    Divider()
                        .background(Color.listDivider)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                        .frame(maxHeight: 50)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(label)
                            .font(.system(size: 15))
                        Text(headline)
                            .font(.system(size: 29, weight: .bold))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .transition(
                                .asymmetric(
                                    insertion: AnyTransition.offset(x: -10, y: 0)
                                        .combined(
                                            with: AnyTransition.opacity.animation(
                                                Animation.easeIn(duration: 0.25).delay(0.25)
                                            )
                                        ),
                                    removal: AnyTransition.offset(x: 10, y: 0)
                                        .combined(
                                            with: AnyTransition.opacity.animation(
                                                .easeOut(duration: 0.25)
                                            )
                                        )
                                )
                            )
                            .id("\(isDarkMode)")

                        Toggle("", isOn: $isDarkMode.animation())
                            .toggleStyle(SwitchToggleStyle(tint: .listSearchBarBorder))
                            .frame(width: 90)
                            .offset(y: 2)
                    }
                    
                }
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
