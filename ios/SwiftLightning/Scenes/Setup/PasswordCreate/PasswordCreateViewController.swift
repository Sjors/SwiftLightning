//
//  PasswordCreateViewController.swift
//  SwiftLightning
//
//  Created by Howard Lee on 2018-04-17.
//  Copyright (c) 2018 BiscottiGelato. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol PasswordCreateDisplayLogic: class {
  
  func updateSceneView(viewModel: PasswordCreate.ValidatePasswords.ViewModel)
  func seedWalletSuccess(viewModel: PasswordCreate.SeedWallet.ViewModel)
  func seedWalletFailure(viewModel: PasswordCreate.SeedWallet.ViewModel)
}

class PasswordCreateViewController: SLViewController, PasswordCreateDisplayLogic, UITextFieldDelegate {
  
  var interactor: PasswordCreateBusinessLogic?
  var router: (NSObjectProtocol & PasswordCreateRoutingLogic & PasswordCreateDataPassing)?

  
  // MARK: Common IBOutlets
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var passwordField: SLPasswordField!
  @IBOutlet weak var confirmField: SLPasswordField!
  @IBOutlet weak var proceedButton: SLBarButton!
  
  
  // MARK: Object lifecycle
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    
    super.init(coder: aDecoder)
    setup()
  }
  
  
  // MARK: Setup
  
  private func setup() {
    
    let viewController = self
    let interactor = PasswordCreateInteractor()
    let presenter = PasswordCreatePresenter()
    let router = PasswordCreateRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  
  // MARK: View lifecycle
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    keyboardScrollView = scrollView  // Hook the keyboard scroll adjust to the SLVC superclass
    
    passwordField.textField.delegate = self
    confirmField.textField.delegate = self
    
    passwordField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    confirmField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    confirmField.textField.returnKeyType = .done
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    validatePasswords()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    passwordField.textField.becomeFirstResponder()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
  }
  
  
  // MARK: Text fields
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    textField.resignFirstResponder()
    
    switch textField {
    case passwordField.textField:
      confirmField.textField.becomeFirstResponder()
    case confirmField.textField:
      if proceedButton.isEnabled {
        proceedTapped(proceedButton)
      }
    default:
      break
    }
    
    return true
  }
  
  
  // MARK: Validate passwords
  
  @objc private func textFieldDidChange(_ textField: UITextField) {
    validatePasswords()
  }
  
  func validatePasswords() {
    let passwordText = passwordField.textField.text ?? ""
    let confirmText = confirmField.textField.text ?? ""
    let request = PasswordCreate.ValidatePasswords.Request(passwordText: passwordText,
                                                           confirmText: confirmText)
    interactor?.validatePasswords(request: request)
  }
  
  func updateSceneView(viewModel: PasswordCreate.ValidatePasswords.ViewModel) {
    DispatchQueue.main.async {
      self.passwordField.infoLabel.text = viewModel.passwordFieldLabelText
      self.passwordField.infoLabel.textColor = viewModel.passwordFieldLabelColor
      self.confirmField.infoLabel.text = viewModel.confirmFieldLabelText
      self.confirmField.infoLabel.textColor = viewModel.confirmFieldLabelColor
      
      if viewModel.proceedButtonEnabled {
        self.proceedButton.setTitleColor(UIColor.normalText, for: .normal)
        self.proceedButton.backgroundColor = UIColor.medAquamarine
        self.proceedButton.shadowColor = UIColor.medAquamarineShadow
        self.proceedButton.isEnabled = true
        
      } else {
        self.proceedButton.setTitleColor(UIColor.disabledText, for: .normal)
        self.proceedButton.backgroundColor = UIColor.disabledGray
        self.proceedButton.shadowColor = UIColor.disabledGrayShadow
        self.proceedButton.isEnabled = false
      }
    }
  }
  
  
  // MARK: Proceed
  let activityIndicator = SLSpinnerDialogView()
  
  @IBAction func proceedTapped(_ sender: SLBarButton) {
    let passwordText = passwordField.textField.text ?? ""
    let confirmText = confirmField.textField.text ?? ""
    
    activityIndicator.show(on: view)
    let request = PasswordCreate.SeedWallet.Request(passwordText: passwordText,
                                                    confirmText: confirmText)
    interactor?.seedWallet(request: request)
  }
  
  func seedWalletSuccess(viewModel: PasswordCreate.SeedWallet.ViewModel) {
    SLLog.verbose("Seed Wallet Success!")
    DispatchQueue.main.async {
      self.activityIndicator.remove()
      self.router?.routeToMnemonicExplain()
    }
  }
  
  func seedWalletFailure(viewModel: PasswordCreate.SeedWallet.ViewModel) {
    SLLog.warning("Seed Wallet Failed")
    let alertDialog = UIAlertController(title: viewModel.errorTitle,
                                        message: viewModel.errorMsg,
                                        preferredStyle: .alert).addAction(title: "OK", style: .default)
    DispatchQueue.main.async {
      self.activityIndicator.remove()
      self.present(alertDialog, animated: true, completion: nil)
    }
  }
  
  
  // MARK: Back Button
  
  @IBAction func backTapped(_ sender: SLIcon30Button) {
    router?.routeToCreateRecover()
  }
  
}
