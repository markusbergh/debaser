//
//  ListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import SwiftUI

enum ListType: String {
    case latest, all, favourites
}

struct ListView: View {
    @StateObject var viewModel = ListViewViewModel()
    @State private var didAppear: Bool = false
    
    var selectedDate: SelectedDay?
    var type: ListType?
    
    var body: some View {
        VStack {
            List(self.viewModel.events) { event in
                Text(event.name)
            }
            .onChange(of: selectedDate, perform: { date in
                guard let selectedDay = date else {
                    return
                }
                
                switch selectedDay {
                case .today:
                    getToday()
                case .tomorrow:
                    getTomorrow()
                }
            })
            .onAppear(perform: onLoad)
        }
    }
    
    func onLoad() {
        switch type {
        case .latest where selectedDate == .today:
            getToday()
        case .latest where selectedDate == .tomorrow:
            getTomorrow()
        case .all:
            getAll()
        default:
            ()
        }
    }
    
    func getToday() {
        viewModel.fetchToday()
    }
    
    func getTomorrow() {
        viewModel.fetchTomorrow()
    }
    
    func getAll() {
        viewModel.fetchAll()
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
