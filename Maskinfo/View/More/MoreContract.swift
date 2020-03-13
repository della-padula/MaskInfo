//
//  MoreContract.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/13.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation

protocol MoreTableViewButtonDelegate {
    func didClickUpdateButton(type: MoreCellType)
}

protocol MoreViewProtocol {
    func showUpdateAlert(isRequired: Bool)
}

protocol MorePresenterProtocol {
    func checkForUpdates()
}

protocol MoreModelProtocol {
    func checkForUpdates(isUpdateRequired: inout Bool)
}
