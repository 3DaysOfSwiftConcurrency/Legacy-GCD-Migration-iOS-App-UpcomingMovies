//
//  URLGenerationTests.swift
//  NetworkInfrastructureTests
//
//  Created by Alonso on 5/25/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import XCTest
@testable import NetworkInfrastructure

final class URLGenerationTests: XCTestCase {

    func testSettingJSONContentTypeAddsHeader() throws {
        // Arrange
        var urlRequest = URLRequest(url: try XCTUnwrap(URL(string: "https://api.themoviedb.org")))
        // Act
        urlRequest.setJSONContentType()
        // Assert
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")
    }

    func testNewRequestHasNoHeaders() throws {
        // Arrange
        let urlRequest = URLRequest(url: try XCTUnwrap(URL(string: "https://api.themoviedb.org")))
        // Act
        let allHeaderFields = urlRequest.allHTTPHeaderFields
        // Assert
        XCTAssertNil(allHeaderFields)
    }

    func testPercentEscapedEmptyParameters() {
        // Arrange
        let parameters: [String: Any] = [:]
        // Act
        let percentEscapedParameters = parameters.percentEscaped()
        // Assert
        XCTAssertTrue(percentEscapedParameters.isEmpty)
    }

    func testPercentEscapedSingleParameter() {
        // Arrange
        let parameters: [String: Any] = ["Param1": "A"]
        // Act
        let percentEscapedParameters = parameters.percentEscaped()
        // Assert
        XCTAssertEqual(percentEscapedParameters, "Param1=A")
    }

    func testPercentEscapedMultipleParameters() {
        // Arrange
        let parameters: [String: Any] = ["Param1": "A", "Param2": "B"]
        // Act
        let percentEscapedParameters = parameters.percentEscaped()
        let possibleEscapedParameters = ["Param1=A&Param2=B", "Param2=B&Param1=A"]
        // Assert
        XCTAssertTrue(possibleEscapedParameters.contains(percentEscapedParameters))
    }

}
