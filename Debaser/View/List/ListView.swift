//
//  ListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import SwiftUI

struct ListView: View {
    @AppStorage("darkMode") var isDarkMode: Bool = false
    @StateObject var viewModel = ListViewViewModel()
    
    @State private var isShowingActivityIndicator = false
    @State private var totalPadding: CGFloat = 20
    
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
                    currentSearch: $viewModel.currentSearch
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
                        ForEach(0..<viewModel.filteredEvents.count, id:\.self) { idx in
                            let event = self.viewModel.filteredEvents[idx]
                            
                            RowCompactView(
                                event: event,
                                mediaHeight: 150,
                                isShowingTabBar: $isShowingTabBar
                            )
                            .frame(maxHeight: .infinity, alignment: .top)
                            .id(event.id)
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
        .onReceive(ListViewViewModel.networkActivityPublisher, perform: { isFetching in
            isShowingActivityIndicator = isFetching
        })
        .overlay(
            ListProgressIndicatorView(isShowingActivityIndicator: isShowingActivityIndicator)
        )
        .onAppear {
            onAppear()
            
            self.isShowingTabBar = true
        }
    }
    
    func onAppear() {
        viewModel.fetchAll()
    }
}

struct ListProgressIndicatorView: View {
    let isShowingActivityIndicator: Bool
    
    var body: some View {
        if isShowingActivityIndicator {
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .progressIndicator))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(50)
                    .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.3))
            .ignoresSafeArea()
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
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

