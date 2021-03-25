//
//  SelectDateView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

enum SelectedDay: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case today = "Idag"
    case tomorrow = "Imorgon"
}

struct SelectDateView: View {
    @Binding var selectedDate: SelectedDay
    
    var body: some View {
        Picker("Välj datum", selection: $selectedDate) {
            ForEach(SelectedDay.allCases) {
                Text($0.rawValue).tag($0)
            }
        }
        .labelsHidden()
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

struct SelectDateView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDateView(selectedDate: .constant(.today))
    }
}
