//
//  MoreTableViewCell.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/13.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import UIKit

class MoreNormalCell: UITableViewCell {
    @IBOutlet weak var titleLabel  : UILabel!
    @IBOutlet weak var updateView  : UIView!
    @IBOutlet weak var updateButton: UIButton!
    
    @IBAction func onClickUpdate(sender: UIButton) {
        self.delegate?.didClickUpdateButton(type: self.type)
    }
    
    var type: MoreCellType = .normal {
        didSet {
            self.setDataToView()
        }
    }
    var delegate: MoreTableViewButtonDelegate?
    var title: String? {
        didSet {
            self.setDataToView()
        }
    }
    
    private func setDataToView() {
        if type == .version {
            updateView.isHidden = true
//            updateView.isHidden = true
        } else {
            self.titleLabel.text = title
            updateView.isHidden = true
        }
        
        if type == MoreCellType.version {
            self.titleLabel.text = "현재 버전 : \(CommonProperty.currentVersion)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

class MoreDeveloperCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    
    var name: String? {
        didSet {
            self.nameLabel.text = name
        }
    }
    
    var from: String? {
        didSet {
            self.fromLabel.text = from
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
