//
//  MorePresenter.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/13.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation

class MorePresenter: MorePresenterProtocol {
    private var view: MoreViewProtocol!
    private var model = MoreModel()
    
    init(view: MoreViewProtocol) {
        self.view = view
    }
    
    func checkForUpdates() {
        var isRequired: Bool = false
        self.model.checkForUpdates(isUpdateRequired: &isRequired)
        self.view.showUpdateAlert(isRequired: isRequired)
    }
}
