//
//  Review.swift
//  UpcomingMoviesDomain
//
//  Created by Alonso on 2/11/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

public struct Review: Equatable, Sendable {

    public let id: String
    public let authorName: String
    public let content: String

    public init(id: String, authorName: String, content: String) {
        self.id = id
        self.authorName = authorName
        self.content = content
    }

}
