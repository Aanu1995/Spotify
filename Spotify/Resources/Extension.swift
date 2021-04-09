//
//  Extension.swift
//  Spotify
//
//  Created by user on 24/03/2021.
//

import Foundation
import UIKit

// MARK: UIView

extension UIView {
    
    var width: CGFloat {
        return frame.size.width
    }
    
    var height: CGFloat {
        return frame.size.height
    }
    
    var left: CGFloat {
        return frame.origin.x
    }
    
    var right: CGFloat {
        return left + width
    }
    
    var top: CGFloat {
        return frame.origin.y
    }
    
    var bottom: CGFloat {
        return top + height
    }
}


// MARK: Date

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()
    
    static let displayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter
    }()
}


// MARK: String

extension String {
    static func formatDate(string: String) -> String {
        guard let date = DateFormatter.dateFormatter.date(from: string) else {
            return string
        }
        
        return DateFormatter.displayDateFormatter.string(from: date)
    }
}

// MARK: Notification.Name

extension Notification.Name {
    static let albumSaveNotification = Notification.Name("albumSaveNotification")
}
