//
//  MessagesViewController.swift
//  iMessage
//
//  Created by Markus Bergh on 2017-12-19.
//  Copyright © 2017 Markus Bergh. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {

    // MARK: Private

    @IBOutlet private var searchField: UISearchBar! {
        didSet {
            searchField.placeholder = NSLocalizedString("iMessage.Search.Placeholder", comment: "Search placeholder text")
        }
    }
    @IBOutlet private var infoLabel: UILabel! {
        didSet {
            infoLabel.text = NSLocalizedString("iMessage.Entry.Label", comment: "Entry label text")
        }
    }

    private var tapExpandExtensionView: UIView!
    private var tapExpandExtension: UITapGestureRecognizer?
    private var tableViewController: UITableViewController?

    private var isExpanded = false
    private var searchActive = false
    private let viewModel = MessagesViewViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        searchField.delegate = self

        infoLabel.layer.cornerRadius = 20
        infoLabel.layer.masksToBounds = true

        tapExpandExtensionView = UIView(frame: view.frame)
        view.addSubview(tapExpandExtensionView)

        tapExpandExtension = UITapGestureRecognizer(target: self, action: #selector(expandViewForExtension))
        tapExpandExtensionView.addGestureRecognizer(tapExpandExtension!)

        let tapDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapDismissKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapDismissKeyboard)
    }

    // MARK: - Conversation Handling

    override func didBecomeActive(with conversation: MSConversation) {
        // If we have a selected message, we will open that event in the main application
        guard let currentMessage = conversation.selectedMessage else { return }
        guard let messageURL = currentMessage.url else { return }

        // Create url with custom scheme
        guard let url = URL(string: "debaser://\(messageURL)") else { return }

        // Open url
        extensionContext?.open(url, completionHandler: nil)
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.

        // Use this method to prepare for the change in presentation style.
        if presentationStyle == .compact {
            // Set state
            isExpanded = false

            // Show view
            tapExpandExtensionView.isHidden = false

            // Enable tap for now
            tapExpandExtension?.isEnabled = true
        } else if presentationStyle == .expanded {
            // Hide label
            UIView.animate(withDuration: 0.3, animations: {
                self.infoLabel.alpha = 0.0
            }, completion: { finished in
                self.infoLabel.isHidden = true
            })
        }
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.

        // Use this method to finalize any behaviors associated with the change in presentation style.
        if presentationStyle == .expanded {
            if tableViewController == nil {
                getData()
            }
        }
    }

    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        guard let messageURL = message.url else { return }
        guard let url = URL(string: "debaser-imessage://\(messageURL)") else { return }

        // Open url with custom scheme
        extensionContext?.open(url, completionHandler: nil)
    }

}

// MARK: - Data

extension MessagesViewController {
    func getData() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.center = view.center

        view.addSubview(activityIndicator)

        viewModel.getEvents { [weak self] in
            activityIndicator.stopAnimating()
            
            self?.addTableViewController()
        }
    }

    func addTableViewController() {
        tableViewController = UITableViewController(style: UITableView.Style.plain)
        tableViewController?.tableView.backgroundColor = UIColor.clear
        tableViewController?.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableViewController?.tableView.delegate = self
        tableViewController?.tableView.dataSource = self
        tableViewController?.tableView.register(UINib(nibName: "MessagesTableViewCell", bundle: nil), forCellReuseIdentifier: MessagesTableViewCell.identifier)
        tableViewController?.tableView.translatesAutoresizingMaskIntoConstraints = false

        guard let tableViewController = self.tableViewController else { return }

        addChild(tableViewController)
        view.addSubview((tableViewController.view)!)
        tableViewController.didMove(toParent: self)

        // Set constraints
        NSLayoutConstraint.activate([
            tableViewController.tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            tableViewController.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewController.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewController.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Bring tap view to front
        view.bringSubviewToFront(tapExpandExtensionView)
    }
}

// MARK: - Actions

extension MessagesViewController {
    @objc func expandViewForExtension() {
        if presentationStyle == .compact, isExpanded == false {
            requestPresentationStyle(.expanded)

            // Hide view
            tapExpandExtensionView.isHidden = true

            // Disable tap for now
            tapExpandExtension?.isEnabled = false

            isExpanded = true
        }
    }

    @objc func dismissKeyboard() {
        searchField.endEditing(true)
    }
}

extension MessagesViewController {
    func downloadAndCropImage(url: URL) -> UIImage? {
        var image: UIImage?

        do {
            let data = try Data(contentsOf: url)

            image = UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }

        return image
    }
}

// MARK: - UITableView Delegate

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if searchActive {
            return viewModel.filteredEvents.count
        }

        return viewModel.events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessagesTableViewCell.identifier, for: indexPath) as? MessagesTableViewCell else {
            fatalError("The dequeued cell is not an instance of MessagesTableViewCell.")
        }
        
        let event = !searchBarIsEmpty() ? viewModel.filteredEvents[indexPath.row] : viewModel.events[indexPath.row]
        
        cell.setup(withTitle: event.title,
                   date: viewModel.getEventDateFormat(date: event.date),
                   imagePath: event.image)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let conversation = activeConversation else { return }

        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        
        let event = !searchBarIsEmpty() ? viewModel.filteredEvents[indexPath.row] : viewModel.events[indexPath.row]

        // Set layout
        layout.caption = event.title
        layout.subcaption =  event.date
        layout.trailingSubcaption = "Debaser"

        if let imageURL = URL(string: event.image) {
            layout.image = downloadAndCropImage(url: imageURL)
        }

        // Set custom data for event
        var components = URLComponents()
        let queryItemEvent = URLQueryItem(name: "eventId", value: event.id)
        components.queryItems = [queryItemEvent]

        // Set message
        message.url = components.url
        message.layout = layout
        
        // Add to conversation
        conversation.insert(message)

        // Set compact style
        requestPresentationStyle(.compact)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

}

extension MessagesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Always set as active when typing
        searchActive = true

        // Input should not be case sensitive
        let searchText = searchText.lowercased()
        let events = viewModel.events

        // Find matches and save them in array
        viewModel.filteredEvents = events.filter({ event -> Bool in
            let eventTitle = event.title.lowercased()

            return eventTitle.contains(searchText)
        })

        // If no matches, we set search as inactive
        if viewModel.filteredEvents.isEmpty {
            searchActive = false
        }

        // Reload with new data
        tableViewController?.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchField.endEditing(true)
    }

    func searchBarIsEmpty() -> Bool {
        return searchField.text?.isEmpty ?? false
    }

    func userIsSearching() -> Bool {
        return searchActive && !searchBarIsEmpty()
    }
}
