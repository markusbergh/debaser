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
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text(historyLabel)) {
                    Text("""
                    Debaser startade 2002 på Slussen. Sedan växte vi och startade år 2006 upp Debaser Medis på Medborgarplatsen. Året därpå expanderade vi utanför Stockholm till Malmö och startade i maj upp Debaser Malmö.

                    I april 2013 slog vi upp de första portarna till Debaser Hornstulls Strand vid Hornstull som förutom nattklubb med scen även innehåller mexikanska restaurangen Calexico’s och amerikanska baren Bar Brooklyn.

                    2013 var även året då både Debaser Malmö och Debaser Slussen gick i graven. Den sistnämnda inte utan strid dock, då över 20.000 personer skrev på för att rädda Debaser Slussen från Stockholms stads grävskopor.
                    """)
                        .padding(.vertical, 10)
                }
            }
            .background(
                SettingsViewTopRectangle(),
                alignment: .top
            )
        }
        .navigationTitle(historyTitle)
    }
}

struct SettingsAboutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAboutView()
    }
}