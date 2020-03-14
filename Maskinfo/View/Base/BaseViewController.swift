//
//  BaseViewController.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/13.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    func showAlertOKWithHandler(title: String, msg: String, handler: ((UIAlertAction) -> Swift.Void)?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "확인", style: .default, handler: handler)
        alertController.addAction(okButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertOK(title: String) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(yesButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertYesNo(title: String, msg: String, handler: ((UIAlertAction) -> Swift.Void)?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "예", style: .default, handler: handler)
        alertController.addAction(yesButton)
        
        let noButton = UIAlertAction(title: "아니요", style:.destructive, handler: nil)
        alertController.addAction(noButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
