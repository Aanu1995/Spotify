//
//  Dialog.swift
//  Spotify
//
//  Created by user on 26/03/2021.
//

import Foundation
import UIKit

protocol Dialog {
    
}

extension Dialog {
    
    func showErrorDialog(title: String = "Error", message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        return alert
    }
}
