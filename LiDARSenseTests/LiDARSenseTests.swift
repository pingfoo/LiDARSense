//
//  LiDARSenseTests.swift
//  LiDARSenseTests
//
//  Created by TM on 2023/05/04.
//

import XCTest
@testable import LiDARSense

final class LiDARSenseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testCreatePlyString() throws {
        let points: [(position: SIMD3<Float>, color: UIColor)] = [
            (position: SIMD3<Float>(0, 0, 0), color: .red),
            (position: SIMD3<Float>(1, 1, 1), color: .green)
        ]

        let plyString = ContentView().createPlyString(from: points)

        XCTAssertTrue(plyString.contains("element vertex \(points.count)"))
        XCTAssertTrue(plyString.contains("0.0 0.0 0.0 255 0 0"))
        XCTAssertTrue(plyString.contains("1.0 1.0 1.0 0 255 0"))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
