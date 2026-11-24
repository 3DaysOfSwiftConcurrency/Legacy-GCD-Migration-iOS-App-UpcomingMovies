//
//  MockURLSession.swift
//  NetworkInfrastructure-Unit-NetworkInfrastructureTests
//
//  Created by Alonso on 21/08/23.
//

import Foundation

final class MockURLSession: URLSession {

    // swiftlint:disable:next large_tuple
    var dataTaskWithRequestCompletionHandler: (Data?, URLResponse?, Error?) = (nil, nil, nil)
    var dataTaskWithRequestResult = MockURLSessionDataTask()
    var holdResponses = false
    private(set) var pendingTasks: [MockURLSessionDataTask] = []
    private(set) var dataTaskWithRequestCallCount = 0
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskWithRequestCallCount += 1
        if holdResponses {
            let task = MockURLSessionDataTask()
            pendingTasks.append(task)
            return task
        }
        completionHandler(dataTaskWithRequestCompletionHandler.0,
                          dataTaskWithRequestCompletionHandler.1,
                          dataTaskWithRequestCompletionHandler.2)
        return dataTaskWithRequestResult
    }

}
