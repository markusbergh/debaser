//
//  ListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import SwiftUI

struct ListView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true

    @StateObject var viewModel = ListViewViewModel()
    
    @State private var didAppear: Bool = false
    @State private var currentIndexToday: Int = 0
    @State private var currentIndexWeek: Int = 0
    @State private var totalPadding: CGFloat = 20
    @State private var currentSearch: String = ""
    
    @Binding var isShowingTabBar: Bool
    
    var headline: String
    var label: String
    var gridLayout: [GridItem] = []
    
    init(headline: String, label: String, isShowingTabBar: Binding<Bool>) {
        self.headline = headline
        self.label = label
        self._isShowingTabBar = isShowingTabBar
        
        var numColumns = 2
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            numColumns = 2
        }
        
        gridLayout = Array(
            repeating: .init(.flexible(), spacing: 30),
            count: numColumns
        )
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ListHeaderView(
                    headline: headline,
                    label: label,
                    isDarkMode: $isDarkMode,
                    currentSearch: $currentSearch
                )
                
                PagerView()
                    .frame(height: 175)
                    .cornerRadius(15)
                    .transition(.opacity)

                Spacer().frame(height: 30)
                    
                VStack(spacing: 10) {
                    HStack {
                        Text("Veckans konserter")
                            .font(.system(size: 17))
                        Spacer()
                    }
                }
                
                Divider()
                    .background(Color.listDivider)
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                
                VStack(spacing: 10) {
                    HStack {
                        Text("Alla konserter")
                            .font(.system(size: 17))
                        Spacer()
                    }
                    
                    LazyVGrid(columns: gridLayout, spacing: 30) {
                        ForEach(0..<viewModel.events.count, id:\.self) { idx in
                            let event = self.viewModel.events[idx]

                            RowCompactView(
                                event: event,
                                imageHeight: 150,
                                isShowingTabBar: $isShowingTabBar
                            )
                            .frame(maxHeight: .infinity, alignment: .top)
                        }
                    }
                }
            }
            .padding(totalPadding)
        }
        .background(
            ListViewTopRectangle(),
            alignment: .top
        )
        .background(Color.listBackground)
            .edgesIgnoringSafeArea(.bottom)
        .alert(isPresented: $viewModel.isShowingErrorAlert) {
            Alert(title: Text("Error"),
                  message: Text("There was an error while fetching events"),
                  dismissButton: .default(Text("OK")))
        }
        .onAppear {
            onAppear()
            
            self.isShowingTabBar = true
        }
    }
    
    func onAppear() {
        viewModel.fetchAll()
    }
}

struct ListViewTopRectangle: View {
    let colorStart = Color.listTopGradientStart
    let colorEnd = Color.listTopGradientEnd
    
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

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(
            headline: "Stockholm",
            label: "Dagens konserter",
            isShowingTabBar: .constant(false)
        )
        .preferredColorScheme(.dark)
    }
}

