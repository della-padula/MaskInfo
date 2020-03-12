//
//  ViewController.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/10.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum RemainStatus {
    case plenty // 100개 이상
    case someThing // 30개 이상 100개 미만
    case few // 2개 이상 30개 미만
    case empty // 1개 이하
    case unknown // 알 수 없음 (nil)
}

enum StoreType {
    case pharmacy
    case post
    case nonghyup
}

struct ResultStore {
    var pharmacyName: String? // 약국이름
    var address: String? // 주소
    var stockAt: String? // 입고시간
    var latitude: Float? // 위도
    var longitude: Float? // 경도
    var storeType: StoreType? // 판매점 타입
    var code: String? // 식별 코드
    var remainStatus: RemainStatus? // 재고 타입
}

protocol ResultTableViewButtonDelegate {
    func didSelectPositionButton(item: ResultStore?)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: CustomTextField!
    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var btnSearch: CustomButton!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBAction func onClickSearchByAddr(sender: UIButton) {
        self.view.endEditing(true)
        var inputValue = ""
        inputValue = textField.text ?? ""
        
        if inputValue.last == " " {
            inputValue = textField.text ?? ""
            inputValue.removeLast()
        }
        self.fetchMashInfoByAddr(address: inputValue)
        
        self.indicatorView.isHidden = false
        self.indicator.isHidden = false
        self.indicator.startAnimating()
    }
    
    private var resultStoreList = [ResultStore]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnSearch.isEnabled = false
        self.btnSearch.isUserInteractionEnabled = true
        
        self.setLayout()
        self.indicator.isHidden = true
        
        self.resultTable.delegate = self
        self.resultTable.dataSource = self
       
        self.resultTable.separatorInset = .zero
        self.resultTable.tableFooterView = UIView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.isEnabled = true
        tapGestureRecognizer.cancelsTouchesInView = false
        resultTable.addGestureRecognizer(tapGestureRecognizer)
        
        self.textField.debounce(delay: 0.2, callback: { text in
            if (text ?? "").isEmpty {
                self.btnSearch.isEnabled = false
                self.btnSearch.isUserInteractionEnabled = false
            } else {
                self.btnSearch.isEnabled = true
                self.btnSearch.isUserInteractionEnabled = true
            }
        })
    }
    
    private func setLayout() {
        self.textField.layer.borderWidth = 1
        self.textField.layer.borderColor = UIColor.white.cgColor
        self.textField.tintColor = .white
        self.textField.attributedPlaceholder = NSAttributedString(string: "구/동 단위 주소 입력(ex:서울특별시 동작구)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "#FFFFFF", alpha: 0.7)])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("View Touch!")
        self.view.endEditing(true)
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        print("Scroll View Touch!")
        self.view.endEditing(true)
    }
    
    private func fetchMashInfoByAddr(address: String) {
        guard let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            self.showAlertOK(title: "주소를 입력해주세요.")
            return
        }
        
        let requestURL = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByAddr/json?address=\(encodedAddress)"
        
        AF.request(requestURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                print(JSON(value)["address"])
                print(JSON(value)["count"])
                
                self.indicatorView.isHidden = true
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
                
                if let jsonArray = JSON(value)["stores"].array {
                    self.resultStoreList.removeAll()
                    for jsonObject in jsonArray {
                        let pharmacyName       = jsonObject["name"].string
                        let stockAt            = jsonObject["stock_at"].string
                        let remainStatusString = jsonObject["remain_stat"].string
                        let storeType          = jsonObject["type"].string
                        let address            = jsonObject["addr"].string
                        let uniqueCode         = jsonObject["code"].string
                        let latitude           = jsonObject["lat"].float
                        let longitude          = jsonObject["lng"].float
                        
                        var type: StoreType?
                        var remainStatus: RemainStatus?
                        
                        switch(storeType) {
                        case "01":
                            type = .pharmacy
                        case "02":
                            type = .post
                        case "03":
                            type = .nonghyup
                        default:
                            break
                        }
                        
                        switch(remainStatusString) {
                        case "plenty":
                            remainStatus = .plenty
                        case "some":
                            remainStatus = .someThing
                        case "few":
                            remainStatus = .few
                        case "empty":
                            remainStatus = .empty
                        default:
                            break
                        }
                        
                        self.resultStoreList.append(ResultStore(pharmacyName: pharmacyName, address: address, stockAt: stockAt, latitude: latitude, longitude: longitude, storeType: type, code: uniqueCode, remainStatus: remainStatus))
                    }
                    
                    if JSON(value)["count"].int ?? 0 < 1 {
                        self.resultTable.isHidden = true
                        self.lblInfo.text = "[주소 입력 예시]\n서울특별시 동작구(O), 대전광역시 동구 가양동(O)\n서울특별시(X), 부산광역시(X)"
                    } else {
                        self.resultTable.isHidden = false
                    }
                    
                    self.resultTable.reloadData()
                }
            case .failure(_):
                self.indicatorView.isHidden = true
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
                
                self.resultTable.isHidden = true
            }
        }
    }
    
    private func showAlertOK(title: String) {
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected Code : \(self.resultStoreList[indexPath.row].code ?? "")")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultStoreList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultStoreCell", for: indexPath) as! ResultTableViewCell
        
        cell.item = self.resultStoreList[indexPath.row]
        cell.selectionStyle  = .none
        cell.delegate = self
        
        return cell
    }
    
    
}

extension ViewController: ResultTableViewButtonDelegate {
    func didSelectPositionButton(item: ResultStore?) {
        let storyboard = self.storyboard
        let positionVC = storyboard?.instantiateViewController(withIdentifier: "positionVC") as! PositionViewController
        positionVC.item = item
        self.navigationController?.pushViewController(positionVC, animated: true)
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}
