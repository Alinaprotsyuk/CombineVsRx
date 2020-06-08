//
//  LoginViewModel.swift
//  CombineWeatherApp
//
//  Created by Alina Protsiuk on 17.02.2020.
//  Copyright © 2020 CoreValue. All rights reserved.
//

import Foundation
import Combine
import RxSwift
import RxCocoa

class LoginViewModel {
    //MARK: - rx properties
    var userLogin = BehaviorRelay<String>(value: "")
    var userPassword = BehaviorRelay<String>(value: "")
    var canShowLoginButton = PublishSubject<Bool>()
    var disposeBag: DisposeBag = DisposeBag()
    
    //MARK: - combine properties
    var cancellable = Set<AnyCancellable>()
    let usernamePublisher = PassthroughSubject<String, Never>()
    let passwordPublisher = PassthroughSubject<String, Never>()
    
    @Published var showLoginButton = true
    @Published var showPasswordHintLabel = false
    
    init() {
        #if DEBUG
            initCombineObserver()
        #else
            initRxObserver()
        #endif
    }
    
}

//MARK: - Combine methods
extension LoginViewModel {
    fileprivate func initCombineObserver() {
        Publishers.CombineLatest(usernamePublisher, passwordPublisher)
            .map { (username, password) -> Bool in
                !username.isEmpty && !password.isEmpty && password.count >= 12
        }
        .replaceError(with: false)
        .sink { [weak self] (valid) in
            self?.showLoginButton = !valid
            self?.showPasswordHintLabel = valid
        }
        .store(in: &cancellable)
    }
}

//MARK: - RxSwift methods
extension LoginViewModel {
    private func initRxObserver() {
        Observable.combineLatest(userLogin.asObservable(), userPassword.asObservable()) {  login, password in
            return !login.isEmpty && !password.isEmpty && password.count >= 12
            
        }
        .subscribe(onNext: { [weak self] (result) in
            self?.canShowLoginButton.onNext(result)
        })
        .disposed(by: disposeBag)
    }
}
