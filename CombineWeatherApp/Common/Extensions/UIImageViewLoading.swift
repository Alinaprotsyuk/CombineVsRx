//
//  UIImageViewExtension.swift
//  CombineWeatherApp
//
//  Created by Alina Protsiuk on 18.02.2020.
//  Copyright © 2020 CoreValue. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIImageView {
    static func makeURL(from string: String) -> URL? {
        return URL(string: "http://openweathermap.org/img/w/" + string + ".png")
    }
   
    func loadWithCombine(icon name: String) {
        guard let url = UIImageView.makeURL(from: name) else { return }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
    func loadWithRx(icon name: String) -> Observable<Bool> {
        return Observable<Bool>.create { (observer)  in
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: UIImageView.makeURL(from: name)!) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                            observer.onNext(true)
                        }
                    }
                } else {
                    observer.onNext(false)
                }
            }
            return Disposables.create()
        }
    }
}
