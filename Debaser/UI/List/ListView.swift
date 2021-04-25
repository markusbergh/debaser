//
//  ListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var store: AppStore
    
    @StateObject var viewModel = ListViewViewModel()
    
    @State private var isShowingErrorAlert = false
    @State private var isShowingActivityIndicator = false
    @State private var totalPadding: CGFloat = 20
    @State private var searchText = ""
    
    var listBottomPadding: CGFloat = .zero
    var headline: String
    var label: LocalizedStringKey
    var gridLayout: [GridItem] = []
    
    init(headline: String, label: LocalizedStringKey) {
        self.headline = headline
        self.label = label
        
        var numColumns = 2
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            numColumns = 2
        }
        
        gridLayout = Array(
            repeating: .init(.flexible(), spacing: 30),
            count: numColumns
        )
        
        listBottomPadding = TabBarStyle.paddingBottom.rawValue + TabBarStyle.height.rawValue + totalPadding + 15
    }
    
    var body: some View {
        let darkMode = self.darkMode(for: store.state.settings)
        
        let searchBinding = Binding(
            get: {
                return searchText
            },
            set: {
                searchText = $0
                
                // Update store
                store.dispatch(withAction: .list(.searchEvent(query: searchText)))
            }
        )
        
        return ScrollView {
            VStack {
                ListHeaderView(
                    headline: headline,
                    label: label,
                    isDarkMode: darkMode,
                    currentSearch: searchBinding
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
                        let events = getEvents()
                        
                        ForEach(0..<events.count, id:\.self) { idx in
                            let event = events[idx]
                            
                            RowCompactView(
                                event: event,
                                mediaHeight: 150
                            )
                            .frame(maxHeight: .infinity, alignment: .top)
                            .id(event.id)
                        }
                    }
                    .padding(.bottom, listBottomPadding)
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
        .alert(isPresented: $isShowingErrorAlert) {
            Alert(title: Text("List.Error.Title"),
                  message: Text("List.Error.Message"),
                  dismissButton: .default(Text("OK")))
        }
        .onReceive(store.state.list.isFetching, perform: { isFetching in
            isShowingActivityIndicator = isFetching
        })
        .onChange(of: store.state.list.fetchError, perform: { error in
            if let _ = error {
                isShowingErrorAlert = true
            }
        })
        .overlay(
            ListProgressIndicatorView(isShowingActivityIndicator: isShowingActivityIndicator)
        )
    }
    
    private func getEvents() -> [EventViewModel] {
        var events = store.state.list.events
        
        if store.state.settings.hideCancelled.value == true {
            events = events.filter({ event -> Bool in
                guard let slug = event.slug else {
                    return true
                }
                
                return !slug.contains("cancelled")
            })
        }

        return events
    }
    
    private func darkMode(for state: SettingsState) -> Binding<Bool> {
        let darkMode = Binding<Bool>(
            get: {
                return store.state.settings.darkMode.value
            },
            set: {
                store.dispatch(withAction: .settings(.setDarkMode($0)))
            }
        )
        
        return darkMode
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
        let store: Store<AppState, AppAction> = Store(
            initialState: AppState(
                list: ListState(),
                settings: SettingsState(),
                onboarding: OnboardingState()
            ),
            reducer: appReducer
        )
        
        ListView(
            headline: "Stockholm",
            label: "Dagens konserter"
        )
        .environmentObject(store)
    }
}

