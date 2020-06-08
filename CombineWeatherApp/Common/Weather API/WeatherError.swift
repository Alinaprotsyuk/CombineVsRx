//
//  WeatherError.swift
//  CombineWeatherApp
//
//  Created by Alina Protsiuk on 2/8/20.
//  Copyright © 2020 CoreValue. All rights reserved.
//

import Foundation

enum APIError: Error, LocalizedError {
    case unknown, apiError(reason: String), wrongURL
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason):
            return reason
        case .wrongURL:
            return "Wrong URL address"
        }
    }
}
