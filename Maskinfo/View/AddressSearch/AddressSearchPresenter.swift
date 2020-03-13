//
//  AddressSearchPresenter.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/12.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AddressSearchPresenter: AddressSearchPresenterProtocol {
    private var view: AddressSearchViewProtocol!
    private var model = AddressSearchModel()
    
    init(view: AddressSearchViewProtocol) {
        self.view = view
    }
    
    func getStoreCount() -> Int {
        return self.model.resultList.count
    }
    
    func getStoreFromList(index: Int) -> ResultStore? {
        if index < self.model.resultList.count {
            return self.model.resultList[index]
        } else {
            return nil
        }
    }
    
    func loadStoreFromAddress(address: String?) {
        var inputValue = ""
        inputValue = address ?? ""
        
        if inputValue.last == " " {
            inputValue.removeLast()
        }
        
        FetchModule.fetchStoreListByAddress(address: inputValue, completion: { (result, list) in
            switch(result) {
            case .success:
                if list?.count ?? 0 > 0 {
                    self.model.resultList.removeAll()
                    self.model.resultList.append(contentsOf: list!)
                    self.view.applyListToTable()
                } else {
                    self.view.alertErrorView()
                }
            case .error:
                self.view.alertErrorView()
            case .addrError:
                self.view.showAlertInputError()
            }
        })
    }
}
