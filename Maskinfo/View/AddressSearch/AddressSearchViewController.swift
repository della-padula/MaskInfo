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

class ViewController: UIViewController, AddressSearchViewProtocol {
    
    @IBOutlet weak var textField: CustomTextField!
    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var btnSearch: CustomButton!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBAction func onClickSearchByAddr(sender: UIButton) {
        self.view.endEditing(true)
        self.presenter.loadStoreFromAddress(address: textField.text)
        
        self.indicatorView.isHidden = false
        self.indicator.isHidden = false
        self.indicator.startAnimating()
    }
    
    
    private var presenter: AddressSearchPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = AddressSearchPresenter(view: self)
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
        self.textField.attributedPlaceholder = NSAttributedString(string: "구/동 단위 주소 입력(ex:서울특별시 동작구)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.TFIELD])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // View Protocol
    func applyListToTable() {
        self.resultTable.isHidden = false
        self.resultTable.reloadData()
        self.stopActivityIndicator()
    }
    
    func stopActivityIndicator() {
        self.indicator.stopAnimating()
        self.indicator.isHidden = true
        self.indicatorView.isHidden = true
    }
    
    func alertErrorView() {
        self.resultTable.isHidden = true
        self.lblInfo.text = "[주소 입력 예시]\n서울특별시 동작구(O), 대전광역시 동구 가양동(O)\n서울특별시(X), 부산광역시(X)"
        self.stopActivityIndicator()
    }
    
    func showAlertInputError() {
        print("주소를 확인해주세요")
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected Code : \(self.presenter.getStoreFromList(index: indexPath.row)?.code ?? "")")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.getStoreCount()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultStoreCell", for: indexPath) as! ResultTableViewCell
        
        cell.item = self.presenter.getStoreFromList(index: indexPath.row)
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
