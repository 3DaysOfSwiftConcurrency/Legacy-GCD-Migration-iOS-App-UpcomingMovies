//
//  MovieCredits.swift
//  UpcomingMoviesDomain
//
//  Created by Alonso on 11/17/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

public struct MovieCredits: Sendable {

    public let cast: [Cast]
    public let crew: [Crew]

    public init(cast: [Cast], crew: [Crew]) {
        self.cast = cast
        self.crew = crew
    }

}
