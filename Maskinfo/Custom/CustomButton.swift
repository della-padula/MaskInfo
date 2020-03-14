//
//  CustomButton.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/10.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import UIKit

class CustomButton: UIButton {

    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        self.titleLabel?.font = .AppleSDSemiBold17P
        
        self.adjustsImageWhenHighlighted = false
        
        self.setBackgroundColor(UIColor(hex: "#FFFFFF", alpha: 0.2), for: .disabled)
        self.setBackgroundColor(UIColor(hex: "#FFFFFF", alpha: 1.0), for: .normal)
        self.setBackgroundColor(UIColor(hex: "#FFFFFF", alpha: 1.0), for: .highlighted)
        
        self.setTitleColor(UIColor(hex: "#1B3B86", alpha: 1.0), for: .normal)
        self.setTitleColor(UIColor(hex: "#1B3B86", alpha: 0.2), for: .disabled)
        self.setTitleColor(UIColor(hex: "#1B3B86", alpha: 1.0), for: .highlighted)
    }
    
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        self.setBackgroundImage(backgroundImage, for: state)
    }
}

extension UIFont {
    
    open class var AppleSDSemiBold12P: UIFont {
        get {
            return UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12.0)!
        }
    }
    
    open class var AppleSDSemiBold15P: UIFont {
        get {
            return UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15.0)!
        }
    }
    
    open class var AppleSDSemiBold17P: UIFont {
        get {
            return UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17.0)!
        }
    }
    
    open class var AppleSDBold14P: UIFont {
        get {
            return UIFont(name: "AppleSDGothicNeo-Bold", size: 14.0)!
        }
    }
    
    open class var AppleSDBold20P: UIFont {
        get {
            return UIFont(name: "AppleSDGothicNeo-Bold", size: 20.0)!
        }
    }
}
