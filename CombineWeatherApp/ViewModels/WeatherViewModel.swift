//
//  WeatherViewModel.swift
//  CombineWeatherApp
//
//  Created by Alina Protsiuk on 14.02.2020.
//  Copyright © 2020 CoreValue. All rights reserved.
//

import Foundation
import Combine
import RxSwift
import RxCocoa

class WeatherViewModel {
    let weatherFetcher = WeatherFetcher()
    
    //MARK: - Combine properties
    @Published var data = [WeatherRowViewModel]()
    var cancellable = Set<AnyCancellable>()
    
    //MARK: - RxSwift properties
    let disposeBag = DisposeBag()
    var listData = BehaviorRelay<[WeatherRowViewModel]>(value: [WeatherRowViewModel]())
    
    //MARK: - Combine method
    func fetchData(for value: String) {
        weatherFetcher.fetchWithCombine(city: value)?
            .print("GetWeather")
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.data, on: self)
        .store(in: &cancellable)
    }
    
    //MARK: - RxSwift method
    func fetchRxData(for value: String) {
        weatherFetcher.fetchWithRx(city: value)
            .subscribe(onNext: { [weak self] (list) in
                if let list = list {
                    self?.listData.accept(list)
                } else {
                    self?.listData.accept([WeatherRowViewModel]())
                }
                
        }, onError: { [weak self] (error) in
            print(error)
            self?.listData.accept([WeatherRowViewModel]())
        }, onCompleted: {
            print("Complite!")
        }) {
            print("On disposed")
        }.disposed(by: disposeBag)
    }
}
