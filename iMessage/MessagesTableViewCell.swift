//
//  MessagesTableViewCell
//  iMessage
//
//  Created by Markus Bergh on 2017-12-19.
//  Copyright © 2017 Markus Bergh. All rights reserved.
//

import UIKit

private var imageCache: NSCache<NSString, UIImage> = NSCache()

class MessagesTableViewCell: UITableViewCell {

    // MARK: Static

    static let identifier = "MessagesTableViewCell"

    // MARK: Private

    @IBOutlet private var eventTitle: UILabel!
    @IBOutlet private var eventDate: UILabel!
    
    @IBOutlet private var eventImage: UIImageView!

    // Insets
    private let insetX: NSNumber = 10
    private let insetY: NSNumber = 10

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        eventImage.image = nil
    }

    override var frame: CGRect {
        get {
            return super.frame
        }

        set (newFrame) {
            var frame = newFrame

            frame.origin.x += CGFloat(insetX.floatValue)
            frame.size.width -= 2 * CGFloat(insetX.floatValue)

            frame.origin.y += CGFloat(insetY.floatValue)
            frame.size.height -= CGFloat(insetY.floatValue)

            super.frame = frame
        }
    }

    func setup(withTitle title: String, date: String?, imagePath: String) {
        eventTitle.text = title
        eventDate.text = date
        
        guard let imageURL = URL(string: imagePath) else {
            return
        }
        
        if let image = imageCache.object(forKey: imagePath as NSString) {
            eventImage.image = image
            
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data else {
                return
            }
            
            guard let image = UIImage(data: data) else {
                return
            }
            
            imageCache.setObject(image, forKey: imagePath as NSString)
            
            DispatchQueue.main.async {
                UIView.transition(with: self.eventImage, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.eventImage.image = image
                }, completion: nil)
            }
        }.resume()
    }
}
