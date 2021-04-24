//
//  DetailView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-04.
//

import SwiftUI

struct DetailView: View {
    @StateObject var viewModel = DetailViewViewModel()
    
    var event: EventViewModel
    
    init(event: EventViewModel) {
        self.event = event
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Top content
                    ZStack(alignment: .topLeading) {
                        DetailTopImageView()
                            .environmentObject(viewModel)
                        
                        // Back button navigation
                        // DetailBackButtonView()
                    }
                    
                    // Main content
                    DetailMainContentView(event: event)
                }
            }
            .background(Color.detailBackground)
            .ignoresSafeArea()
            .frame(height: geometry.size.height)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadImage(with: event.image)
            }
        }
    }
}

// MARK: Top image

struct DetailTopImageView: View {
    @EnvironmentObject var viewModel: DetailViewViewModel
    
    var body: some View {
        GeometryReader { geometry -> DetailImageView in
            var width =  geometry.size.width
            var height = geometry.size.height + geometry.frame(in: .global).minY
            var offsetY = -geometry.frame(in: .global).minY
            
            if geometry.frame(in: .global).minY <= 0 {
                width = geometry.size.width
                height = geometry.size.height
                offsetY = -geometry.frame(in: .global).minY / 3
            }
            
            return DetailImageView(
                image: viewModel.image,
                width: width,
                height: height,
                offsetY: offsetY
            )
        }
        .frame(height: 300)
    }
}

// MARK: Back button

struct DetailBackButtonView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                )
                .offset(x: 35, y: 60)
                .foregroundColor(.detailBackButtonTint)
        }
    }
}

// MARK: Main content

struct DetailMainContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var height: CGFloat = .zero

    var event: EventViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            /*
            Text(event.title)
                .font(Fonts.title.of(size: 53))
                .padding(.bottom, 5)
            */
            
            DetailMetaView(
                label: event.venue,
                labelSize: 15,
                labelColor: colorScheme == .dark ? .black : .white,
                backgroundColor: .primary
            )
            .padding(.bottom, 15)
            
            TitleView(title: event.title, dynamicHeight: $height)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 15)
                
            DetailMetaContainerView()

            SeparatorView()
                .frame(height: 10)
                .padding(.bottom, 15)
            
            DetailBuyTicketButtonView()
            
            Text(event.description)
                .font(.system(size: 19))
        }
        .padding(25)
        .background(Color.detailContentBackground)
        .cornerRadius(25)
        .shadow(
            color: Color.black.opacity(
                colorScheme == .light ? 0.25 : 0.1
            ),
            radius: 20,
            x: 0,
            y: -5
        )
        .padding(25)
    }
}

// MARK: Ticket button

struct DetailBuyTicketButtonView: View {
    private var ticketsLabel: LocalizedStringKey {
        return "Detail.Buy.Tickets"
    }
    
    var body: some View {
        Button(action: {
            // TODO: Open url
        }) {
            Text(ticketsLabel)
                .font(.system(size: 17))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .stroke(
                            Color.primary,
                            style: /*@START_MENU_TOKEN@*/StrokeStyle()/*@END_MENU_TOKEN@*/
                        )
                )
        }
        .foregroundColor(.primary)
        .padding(.bottom, 15)
    }
}

// MARK: Meta view

struct DetailMetaContainerView: View {
    var body: some View {
        HStack {
            DetailMetaView(
                image: "person",
                label: "Age 20",
                backgroundColor: .detailViewMetaPrimary
            )
            DetailMetaView(
                image: "dollarsign.circle",
                label: "250 kr",
                backgroundColor: .detailViewMetaSecondary
            )
            DetailMetaView(
                image: "clock",
                label: "21:00",
                backgroundColor: .detailViewMetaTertiary
            )
        }
        .padding(.bottom, 15)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let event = Event(
            id: "1234",
            name: "The Other Favourites",
            status: "Open",
            description: "The Other Favorites is the long time duo project of Carson McKee and Josh Turner. Perhaps best known for their performances on YouTube, which have garnered millions of views. The Other Favorites are now based out of Brooklyn, NY. Together, Turner and McKee bring their shared influences of folk, bluegrass and classic rock into a modern framework; one distinguished by incisive songwriting, virtuosic guitar work and tight two-part harmony.\n\nReina del Cid is a singer songwriter and leader of the eponymous folk rock band based in Los Angeles. Her song-a-week video series, Sunday Mornings with Reina del Cid, has amassed 40 million views on YouTube and collected a diverse following made up of everyone from jamheads to college students to white-haired intelligentsia. In 2011 she began collaborating with Toni Lindgren, who is the lead guitarist on all three of Del Cid’s albums, as well as a frequent and much beloved guest on the Sunday Morning videos. The two have adapted their sometimes hard-hitting rock ballads and catchy pop riffs into a special acoustic duo set.",

            ageLimit: "18 år",
            image: "https://debaser.se/img/10982.jpg",
            date: "2010-01-19",
            room: "Bar Brooklyn",
            venue: "Strand"
        )
        
        let model = EventViewModel(with: event)
        
        DetailView(event: model)
        
        DetailView(event: model)
            .preferredColorScheme(.dark)
    }
}
