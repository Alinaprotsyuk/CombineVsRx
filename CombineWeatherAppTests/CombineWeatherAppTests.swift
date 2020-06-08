//
//  CombineWeatherAppTests.swift
//  CombineWeatherAppTests
//
//  Created by Alina Protsiuk on 2/13/20.
//  Copyright © 2020 CoreValue. All rights reserved.
//

import XCTest
import Combine
//import RxSwift

class CombineWeatherAppTests: XCTestCase {
    private let input = stride(from: 0, to: 10_000_000, by: 1)
    
    override class var defaultPerformanceMetrics: [XCTPerformanceMetric] {
        return [
            XCTPerformanceMetric("com.apple.XCTPerformanceMetric_TransientHeapAllocationsKilobytes"),
            .wallClockTime
        ]
    }

    func testCombine() {
        self.measure {
            _ = Publishers.Sequence(sequence: input)
                .map { $0 * 2 }
                .filter { $0.isMultiple(of: 2) }
                //.flatMap { Publishers.Last { $0 }}
                .count()
                .sink(receiveValue: {
                    print($0)
                })
        }
    }
    
//    func testRxSwift() {
//        self.measure {
//            _ = Observable.from(input)
//                .map { $0 * 2 }
//                .filter { $0.isMultiple(of: 2) }
//                .flatMap { Observable.just($0) }
//                .toArray()
//                .map { $0.count }
//                .subscribe(onSuccess: { print($0) })
//        }
//    }
}
