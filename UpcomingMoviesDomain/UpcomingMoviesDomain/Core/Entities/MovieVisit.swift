//
//  MovieVisit.swift
//  UpcomingMoviesDomain
//
//  Created by Alonso on 1/15/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import Foundation

public struct MovieVisit: Equatable, Sendable {

    public let id: Int
    public let title: String
    public let posterPath: String
    public let createdAt: Date?

    public init(id: Int, title: String, posterPath: String, createdAt: Date?) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.createdAt = createdAt
    }

}
