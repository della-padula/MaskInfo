//
//  AddressSearchContract.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/12.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation

protocol ResultTableViewButtonDelegate {
    func didSelectPositionButton(item: ResultStore?)
}

protocol AddressSearchViewProtocol {
    func showAlertInputError()
    
    func applyListToTable()
    
    func alertErrorView()
}

protocol AddressSearchPresenterProtocol {
    func loadStoreFromAddress(address: String?)
    
    func getStoreFromList(index: Int) -> ResultStore?
    
    func getStoreCount() -> Int
}
