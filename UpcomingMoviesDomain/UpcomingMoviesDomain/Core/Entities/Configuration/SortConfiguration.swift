//
//  SortConfiguration.swift
//  UpcomingMoviesDomain
//
//  Created by Alonso on 8/22/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

public struct SortConfiguration: Sendable {

    public let movieSortKeys: [String]

    public init(movieSortKeys: [String]) {
        self.movieSortKeys = movieSortKeys
    }

}
