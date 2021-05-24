//
//  SettingsAboutView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import SwiftUI

struct SettingsAboutView: View {
    private var historyTitle: LocalizedStringKey {
        return "Settings.Debaser.History.Title"
    }
    
    private var historyLabel: LocalizedStringKey {
        return "Settings.Debaser.History.Label"
    }
    
    private var bottomPadding: CGFloat {
        return TabBarStyle.height.rawValue + (20 * 2)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text(historyLabel)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                
                VStack(alignment: .leading) {
                    MapContentView(
                        willAnimatePin: true,
                        pinSize: .small
                    )
                    .cornerRadius(10)
                    .frame(height: 300)
                    .padding(.bottom, 15)
                    
                    Text("Debaser")
                        .font(Font.Variant.large(weight: .medium).font)
                        .padding(.bottom, 5)
                    
                    Text("""
                    Debaser startade 2002 på Slussen. Sedan växte vi och startade år 2006 upp Debaser Medis på Medborgarplatsen. Året därpå expanderade vi utanför Stockholm till Malmö och startade i maj upp Debaser Malmö.

                    I april 2013 slog vi upp de första portarna till Debaser Hornstulls Strand vid Hornstull som förutom nattklubb med scen även innehåller mexikanska restaurangen Calexico’s och amerikanska baren Bar Brooklyn.

                    2013 var även året då både Debaser Malmö och Debaser Slussen gick i graven. Den sistnämnda inte utan strid dock, då över 20.000 personer skrev på för att rädda Debaser Slussen från Stockholms stads grävskopor.
                    """)
                }
                .padding(15)
                .padding(.bottom, bottomPadding)
                .background(Color.settingsListRowBackground)
                .cornerRadius(10)
            }
            .padding(
                .init(
                    top: 10,
                    leading: 20,
                    bottom: 20,
                    trailing: 20
                )
            )
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .background(
            SettingsViewTopRectangle(),
            alignment: .top
        )
        .background(
            Color.settingsBackground
                .ignoresSafeArea()
        )
        .navigationTitle(historyTitle)
    }
}

struct SettingsAboutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAboutView()
            .preferredColorScheme(.dark)
    }
}
