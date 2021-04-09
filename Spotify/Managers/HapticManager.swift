//
//  HapticManager.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    public func vibrateForSelection(){
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType){
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
}
