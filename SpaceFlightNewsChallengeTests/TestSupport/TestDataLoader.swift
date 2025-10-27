//
//  TestDataLoader.swift
//  SpaceFlightNewsChallengeTests
//
//  Created by Ivan Cardenas on 26/10/2025.
//

import Foundation
import XCTest

enum TestDataLoader {
    static func data(
        forResource name: String,
        withExtension ext: String = "json",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Data {
        let bundle = Bundle(for: BundleMarker.self)
        
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            XCTFail("Missing fixture \(name).\(ext)", file: file, line: line)
            return Data()
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            XCTFail("Unable to load fixture \(name).\(ext): \(error)", file: file, line: line)
            return Data()
        }
    }
}

private final class BundleMarker: NSObject {}
