//
//  UIColor+Extensions.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/12.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    open class var MAIN: UIColor {
        get {
            return UIColor(hex: "#1B3B86", alpha: 1.0)
        }
    }
    
    open class var GREEN: UIColor {
        get {
            return UIColor(hex: "#00B140", alpha: 1.0)
        }
    }
    
    open class var YELLOW: UIColor {
        get {
            return UIColor(hex: "#C7622D", alpha: 1.0)
        }
    }
    
    open class var RED: UIColor {
        get {
            return UIColor(hex: "#C72B4F", alpha: 1.0)
        }
    }
    
    open class var GRAY: UIColor {
        get {
            return UIColor(hex: "#DADADA", alpha: 1.0)
        }
    }
    
    open class var UNKNOWN: UIColor {
        get {
            return UIColor(hex: "#343434", alpha: 1.0)
        }
    }
}
