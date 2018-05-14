//
//  WalletBalancePresenter.swift
//  SwiftLightning
//
//  Created by Howard Lee on 2018-05-13.
//  Copyright (c) 2018 BiscottiGelato. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol WalletBalancePresentationLogic {
  func presentRefresh(response: WalletBalance.Refresh.Response)
}

class WalletBalancePresenter: WalletBalancePresentationLogic {
  weak var viewController: WalletBalanceDisplayLogic?
  
  // MARK: Present Refresh
  
  func presentRefresh(response: WalletBalance.Refresh.Response) {

    let viewModel = WalletBalance.Refresh.ViewModel(totalBalance: (response.totalBalance ?? Bitcoin(inSatoshi: 0)).formattedInSatoshis(),
                                                    onChainTotal: (response.onChainTotal ?? Bitcoin(inSatoshi: 0)).formattedInSatoshis(),
                                                    onChainConfirmed: (response.onChainConfirmed ?? Bitcoin(inSatoshi: 0)).formattedInSatoshis(),
                                                    onChainUnconfirmed: (response.onChainUnconfirmed ?? Bitcoin(inSatoshi: 0)).formattedInSatoshis(),
                                                    channelConfirmed: (response.channelConfirmed ?? Bitcoin(inSatoshi: 0)).formattedInSatoshis(),
                                                    channelPending: (response.channelPending ?? Bitcoin(inSatoshi: 0)).formattedInSatoshis())
    viewController?.displayRefresh(viewModel: viewModel)
    
    if response.totalBalance == nil, response.onChainTotal == nil, response.onChainConfirmed == nil,
       response.onChainUnconfirmed == nil, response.channelConfirmed == nil, response.channelPending == nil {
      let viewModel = WalletBalance.ErrorVM(errTitle: "Balance Error", errMsg: "Not all balance details was retrieved. Please try again")
      viewController?.displayError(viewModel: viewModel)
      
    }
    
    if response.totalBalance == nil || response.onChainTotal == nil || response.onChainConfirmed == nil ||
      response.onChainUnconfirmed == nil || response.channelConfirmed == nil || response.channelPending == nil {
      let viewModel = WalletBalance.ErrorVM(errTitle: "Balance Error", errMsg: "Unable to retrieve balance. Please try again.")
      viewController?.displayError(viewModel: viewModel)
    }
  }
}
