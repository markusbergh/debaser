//
//  DetailBuyTicketButtonView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-25.
//

import SwiftUI

struct DetailBuyTicketButtonView: View {
    @State private var showTicketUrl = false
    
    private var ticketsLabel: LocalizedStringKey {
        return "Detail.Buy.Tickets"
    }
    
    let event: EventViewModel
    
    var body: some View {
        Button(action: {
            showTicketUrl = true
        }) {
            Text(ticketsLabel)
                .font(Font.Variant.body(weight: .regular).font)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule().stroke(
                        Color.primary
                    )
                )
        }
        .disabled(event.isCancelled)
        .opacity(event.isCancelled ? 0.5 : 1)
        .foregroundColor(.primary)
        .padding(.top, 15)
        .sheet(isPresented: $showTicketUrl) {
            WebView(url: URL(string: event.ticketUrl!)!)
                .ignoresSafeArea()
        }
    }
}

struct DetailBuyTicketButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let event = EventViewModel.mock

        DetailBuyTicketButtonView(event: event)
    }
}
