//
//  ResultTableViewCell.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/10.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    @IBOutlet weak var lblName   : UILabel!
    @IBOutlet weak var lblAddr   : UILabel!
    @IBOutlet weak var lblStock  : UILabel!
    @IBOutlet weak var lblType   : UILabel!
    @IBOutlet weak var lblRemain : UILabel!
    @IBOutlet weak var typeBgView: UIView!
    
    var item: ResultStore? {
        didSet {
            self.applyItemToView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func applyItemToView() {
        guard let result = item else {
            return
        }
        
        var stockText = ""
        var storeType = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        if let date = dateFormatter.date(from: result.stockAt ?? "") {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            let hour = calendar.component(.day, from: date)
            let min = calendar.component(.minute, from: date)
            
            stockText = "입고 일시 : \(year)년 \(month)월 \(day)일 \(hour)시 \(min)분"
        }
        
        switch(item?.remainStatus) {
        case .plenty:
            self.lblRemain.text = "100개 이상"
            self.lblRemain.textColor = UIColor(hex: "#00B140", alpha: 1.0)
        case .someThing:
            //30개 이상
            self.lblRemain.text = "100개 미만"
            self.lblRemain.textColor = UIColor(hex: "#C7622D", alpha: 1.0)
        case .few:
            //2개 이상
            self.lblRemain.text = "30개 미만"
            self.lblRemain.textColor = UIColor(hex: "#C72B4F", alpha: 1.0)
        case .empty:
            self.lblRemain.text = "2개 미만"
            self.lblRemain.textColor = UIColor(hex: "#DADADA", alpha: 1.0)
        default:
            self.lblRemain.text = "알 수 없음"
            self.lblRemain.textColor = UIColor(hex: "#343434", alpha: 1.0)
        }
        
        switch(item?.storeType) {
        case .pharmacy:
            storeType = "약국"
            self.typeBgView.backgroundColor = UIColor(hex: "#1B3B86", alpha: 1.0)
        case .post:
            storeType = "우체국"
            self.typeBgView.backgroundColor = UIColor(hex: "#DA291C", alpha: 1.0)
        case .nonghyup:
            storeType = "농협"
            self.typeBgView.backgroundColor = UIColor(hex: "#00B140", alpha: 1.0)
        case .none:
            break
        }
        
        self.typeBgView.layer.cornerRadius = 4
        self.typeBgView.clipsToBounds = true
        
        self.lblType.text  = storeType
        self.lblName.text  = result.pharmacyName
        self.lblAddr.text  = result.address
        self.lblStock.text = stockText
    }
    
}
