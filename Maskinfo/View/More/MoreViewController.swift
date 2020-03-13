//
//  MoreViewController.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/13.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import UIKit

class MoreViewController: BaseViewController, MoreViewProtocol {
    private var presenter: MorePresenterProtocol!
    private let storeURL = ""
    private var menuTitleList = ["버전 정보", "오픈소스 사용 정보", "문의하기"]
    private var menuTypeList: [MoreCellType] = [.version, .normal, .inquire]
    
    @IBOutlet weak var moreTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moreTable.delegate = self
        self.moreTable.dataSource = self
        
        self.moreTable.separatorInset = .zero
        self.moreTable.tableFooterView = UIView()
        
        self.presenter = MorePresenter(view: self)
//        self.presenter.checkForUpdates()
        
        self.navigationController?.navigationBar.barStyle = .black
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            if #available(iOS 13.0, *) {
                if traitCollection.userInterfaceStyle == .light {
    //                return .darkContent
                } else {
    //                return .lightContent
                }
                return .lightContent
            } else {
                return .lightContent
            }
        }
    
    func showUpdateAlert(isRequired: Bool) {
        if isRequired {
            self.showAlertOKWithHandler(title: "업데이트가 있습니다", msg: "새 버전으로 업데이트 합니다.", handler: onClickUpdateApp(_:))
        }
    }
    
    @objc func onClickUpdateApp(_ action: UIAlertAction) {
        // MARK: 주소 수정 필요
        if let url = URL(string: storeURL),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuTitleList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "developerCell") as! MoreDeveloperCell
            
            cell.name = CommonProperty.developerName
            cell.from = CommonProperty.developerFrom
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell") as! MoreNormalCell
            cell.type = self.menuTypeList[indexPath.row - 1]
            cell.title = self.menuTitleList[indexPath.row - 1]
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if menuTypeList[indexPath.row - 1] == .inquire {
            print("Send Mail To Developer")
            let email = "della.kimko@gmail.com"
            if let url = URL(string: "mailto:\(email)") {
                UIApplication.shared.open(url)
            }
        } else if menuTypeList[indexPath.row - 1 ] == .normal {
            self.showAlertOKWithHandler(title: "오픈소스 사용 목록", msg: "Alamofire - Network Library\nNMapsMap - Naver Map API\nSwiftyJSON - swift json", handler: nil)
        }
    }
    
}

extension MoreViewController: MoreTableViewButtonDelegate {
    func didClickUpdateButton(type: MoreCellType) {
        print("Update Button Clicked")
        if let url = URL(string: storeURL),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
