//
//  WeatherFetchable.swift
//  CombineWeatherApp
//
//  Created by Alina Protsiuk on 2/8/20.
//  Copyright © 2020 CoreValue. All rights reserved.
//

import Foundation
import Combine
import RxCocoa
import RxSwift

class WeatherFetcher {
    private let session: URLSession
    fileprivate lazy var jsonDecoder = JSONDecoder()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}


// MARK: - OpenWeatherMap API
extension WeatherFetcher {
    struct OpenWeatherAPI {
        static let scheme = "https"
        static let host = "api.openweathermap.org"
        static let path = "/data/2.5"
        static let key = "1e838668ac1b0a52e51b5364dd4b82bd"
    }
    
    func makeWeeklyForecastComponents(
        withCity city: String
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = OpenWeatherAPI.scheme
        components.host = OpenWeatherAPI.host
        components.path = OpenWeatherAPI.path + "/forecast/daily"
        
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "cnt", value: "7"),
            URLQueryItem(name: "APPID", value: OpenWeatherAPI.key)
        ]
        
        return components
    }
    
    func makeCurrentDayForecastComponents(
        withCity city: String
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = OpenWeatherAPI.scheme
        components.host = OpenWeatherAPI.host
        components.path = OpenWeatherAPI.path + "/weather"
        
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "mode", value: "json"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "APPID", value: OpenWeatherAPI.key)
        ]
        
        return components
    }
}

// MARK: - WeatherFetchable
extension WeatherFetcher {
    func fetchWithCombine(city: String) -> AnyPublisher<[WeatherRowViewModel], APIError>? {
        let components = makeWeeklyForecastComponents(withCity: city)
        guard let url = components.url else { return nil }
        return session.dataTaskPublisher(for: url)
            .map({$0.data})
            .decode(type: Base.self, decoder: JSONDecoder())
            .mapError({ return APIError.apiError(reason: $0.localizedDescription) })
            .compactMap({ (base) -> [WeatherRowViewModel] in
                return (base.list?.compactMap({ WeatherRowViewModel(item: $0, id: UUID())}) ?? [WeatherRowViewModel]())
            })
            .eraseToAnyPublisher()
    }
    
    func fetchWithRx(city: String) -> Observable<[WeatherRowViewModel]?> {
        guard let fullURL = makeWeeklyForecastComponents(withCity: city).url else {
            return Observable.error(APIError.wrongURL)
        }
        
        return Observable<[WeatherRowViewModel]?>.create { observer in
            let request = URLRequest(url: fullURL)
            let response = URLSession.shared.rx.response(request: request)
                .debug("test api request")
            
            return response.subscribe(onNext: { response, data in
                if 200..<300 ~= response.statusCode {
                    guard let responseItems = try? self.jsonDecoder.decode(Base.self, from: data) else {
                        return observer.onError(APIError.unknown)
                    }
                    let newModel = responseItems.list?.compactMap({WeatherRowViewModel(item: $0, id: UUID())})
                    observer.onNext(newModel)
                    observer.onCompleted()
                } else {
                    observer.onError(APIError.apiError(reason: "Data is not available"))
                }
            }, onError: { error in
                observer.onError(APIError.apiError(reason: error.localizedDescription))
            }, onCompleted: nil,
               onDisposed: nil)
        }
    }
}

