//
//  LoginViewController.swift
//  CombineWeatherApp
//
//  Created by Alina Protsiuk on 14.02.2020.
//  Copyright © 2020 CoreValue. All rights reserved.
//

import UIKit
import Combine
import RxSwift

class LoginViewController: UIViewController {
    //MARK: - IBOutlet
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordHintLabel: UILabel!
    
    //MARK: - Properties
    private let viewModel = LoginViewModel()
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            doCombineMethods()
        #else
            doRxMethods()
        #endif
    }
    
    fileprivate func pushToTheNextScreen() {
        performSegue(withIdentifier: "showWheatherScreen", sender: nil)
    }
    
}

//MARK: - Combine methods
extension LoginViewController {
    
    func doCombineMethods() {
        viewModel.$showLoginButton
            .print("buttonSubscriber")
            .assign(to: \.isHidden, on: loginButton)
            .store(in: &viewModel.cancellable)
        
        viewModel.$showPasswordHintLabel
            .assign(to: \.isHidden, on: passwordHintLabel)
            .store(in: &viewModel.cancellable)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification,
                                             object: loginTextField)
            .map({($0.object as? UITextField)?.text ?? ""})
            .receive(on: RunLoop.main)
            .sink { [weak self] (value) in
                self?.viewModel.usernamePublisher.send(value)
                self?.viewModel.passwordPublisher.send(self?.passwordTextField.text ?? "")
        }
        .store(in: &viewModel.cancellable)
        
        NotificationCenter.Publisher(center: .default,
                                     name: UITextField.textDidChangeNotification,
                                     object: passwordTextField)
            .map { ($0.object as? UITextField)?.text ?? ""}
            .print("Init")
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    break
                case .failure:
                    print("Fail")
                }
            }) { [weak self] (value) in
                self?.viewModel.usernamePublisher.send(self?.loginTextField.text ?? "")
                self?.viewModel.passwordPublisher.send(value)
        }
        .store(in: &viewModel.cancellable)
        
        loginButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] (button) in
                _ = NotificationCenter.Publisher(center: .default, name: .userName, object: self?.loginTextField)
                    .print("Name")
                    .map({ ($0.object as! UITextField).text ?? ""})
                
                self?.pushToTheNextScreen()
        }
        .store(in: &viewModel.cancellable)
    }
    
}

//MARK: - RxSwift methods
extension LoginViewController {
    
    func doRxMethods() {
        loginTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.userLogin)
            .disposed(by: viewModel.disposeBag)
        
        passwordTextField.rx.text
            .map({ $0 ?? ""})
            .bind(to: viewModel.userPassword)
            .disposed(by: viewModel.disposeBag)
        
        viewModel.canShowLoginButton
            .subscribe(onNext: { [weak self] (show) in
                self?.loginButton.isHidden = !show
                self?.passwordHintLabel.isHidden = show
            })
            .disposed(by: viewModel.disposeBag)
        
        loginButton.rx.tap
            .subscribe { [weak self] (_) in
            self?.pushToTheNextScreen() 
        }
        .disposed(by: viewModel.disposeBag)
    }
    
}
