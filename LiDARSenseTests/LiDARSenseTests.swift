//
//  LiDARSenseTests.swift
//  LiDARSenseTests
//
//  Created by TM on 2023/05/04.
//

import XCTest
@testable import LiDARSense

final class LiDARSenseTests: XCTestCase {

    // MARK: - createPlyString tests

    func testCreatePlyStringHeader() throws {
        let points: [(position: SIMD3<Float>, color: UIColor)] = [
            (position: SIMD3<Float>(0, 0, 0), color: .red),
            (position: SIMD3<Float>(1, 1, 1), color: .green)
        ]

        let plyString = ContentView.createPlyString(from: points)

        XCTAssertTrue(plyString.hasPrefix("ply\n"))
        XCTAssertTrue(plyString.contains("format ascii 1.0"))
        XCTAssertTrue(plyString.contains("element vertex \(points.count)"))
        XCTAssertTrue(plyString.contains("property float x"))
        XCTAssertTrue(plyString.contains("property float y"))
        XCTAssertTrue(plyString.contains("property float z"))
        XCTAssertTrue(plyString.contains("property uchar red"))
        XCTAssertTrue(plyString.contains("property uchar green"))
        XCTAssertTrue(plyString.contains("property uchar blue"))
        XCTAssertTrue(plyString.contains("end_header"))
    }

    func testCreatePlyStringVertexData() throws {
        let points: [(position: SIMD3<Float>, color: UIColor)] = [
            (position: SIMD3<Float>(0, 0, 0), color: .red),
            (position: SIMD3<Float>(1, 1, 1), color: .green)
        ]

        let plyString = ContentView.createPlyString(from: points)

        XCTAssertTrue(plyString.contains("0.0 0.0 0.0 255 0 0"))
        XCTAssertTrue(plyString.contains("1.0 1.0 1.0 0 255 0"))
    }

    func testCreatePlyStringEmpty() throws {
        let points: [(position: SIMD3<Float>, color: UIColor)] = []
        let plyString = ContentView.createPlyString(from: points)

        XCTAssertTrue(plyString.contains("element vertex 0"))
        XCTAssertTrue(plyString.contains("end_header"))
        // After end_header there should be no vertex data
        let components = plyString.components(separatedBy: "end_header\n")
        XCTAssertEqual(components.count, 2)
        XCTAssertTrue(components[1].isEmpty)
    }

    func testCreatePlyStringSinglePoint() throws {
        let points: [(position: SIMD3<Float>, color: UIColor)] = [
            (position: SIMD3<Float>(2.5, -1.0, 3.7), color: .blue)
        ]

        let plyString = ContentView.createPlyString(from: points)

        XCTAssertTrue(plyString.contains("element vertex 1"))
        XCTAssertTrue(plyString.contains("2.5 -1.0 3.7 0 0 255"))
    }

    func testCreatePlyStringWhiteColor() throws {
        let points: [(position: SIMD3<Float>, color: UIColor)] = [
            (position: SIMD3<Float>(0, 0, 0), color: .white)
        ]

        let plyString = ContentView.createPlyString(from: points)

        XCTAssertTrue(plyString.contains("0.0 0.0 0.0 255 255 255"))
    }

    func testCreatePlyStringCustomColor() throws {
        let customColor = UIColor(red: 0.5, green: 0.25, blue: 0.75, alpha: 1.0)
        let points: [(position: SIMD3<Float>, color: UIColor)] = [
            (position: SIMD3<Float>(0, 0, 0), color: customColor)
        ]

        let plyString = ContentView.createPlyString(from: points)

        // 0.5*255=127, 0.25*255=63, 0.75*255=191
        XCTAssertTrue(plyString.contains("0.0 0.0 0.0 127 63 191"))
    }

    func testCreatePlyStringVertexCount() throws {
        let points: [(position: SIMD3<Float>, color: UIColor)] = (0..<100).map { i in
            (position: SIMD3<Float>(Float(i), 0, 0), color: .red)
        }

        let plyString = ContentView.createPlyString(from: points)

        XCTAssertTrue(plyString.contains("element vertex 100"))
        // Count data lines after header
        let components = plyString.components(separatedBy: "end_header\n")
        let dataLines = components[1].split(separator: "\n")
        XCTAssertEqual(dataLines.count, 100)
    }

    // MARK: - ContentViewModel tests

    func testContentViewModelInitialState() throws {
        let viewModel = ContentViewModel()
        XCTAssertTrue(viewModel.capturedPlyFileURLs.isEmpty)
        XCTAssertTrue(viewModel.capturedImageURLs.isEmpty)
    }

    // MARK: - Performance

    func testCreatePlyStringPerformance() throws {
        let points: [(position: SIMD3<Float>, color: UIColor)] = (0..<1000).map { i in
            (position: SIMD3<Float>(Float(i), Float(i), Float(i)), color: .red)
        }

        self.measure {
            _ = ContentView.createPlyString(from: points)
        }
    }

}
