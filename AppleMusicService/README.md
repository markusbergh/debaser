# AppleMusicService

This package makes it possible to search for an artist and receive a preview audio stream, if available.

## Documenttion

To use this service, import the module and subscribe to the search request whenever you need to receive an audio preview.

```swift
import AppleMusicService
import SwiftUI

struct ContentView: View {
    @State private var serviceCancellable: AnyCancellable?
    @State private var audioPreview: String?
    
    let event: EventViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                // Handle play action
            }) {
                Text("Play preview")
            }
        }
        .onAppear {
            serviceCancellable = AppleMusicService.shared.search(for: event.title)
                .subscribe(on: DispatchQueue.main)
                .sink(receiveCompletion: { response in
                    switch response {
                    case .failure(let error):
                        // Handle error
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] preview in
                    if let preview = preview, let previewUrl = preview.url {
                        self?.audioPreview = previewUrl
                    }
                })
        }
    }
}
```
