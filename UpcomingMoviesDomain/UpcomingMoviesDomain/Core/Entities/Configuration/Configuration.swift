//
//  Configuration.swift
//  UpcomingMoviesDomain
//
//  Created by Alonso on 5/24/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

public struct Configuration: Sendable {

    public let imagesConfiguration: ImagesConfiguration
    public let sortConfiguration: SortConfiguration

    public init(imagesConfiguration: ImagesConfiguration, sortConfiguration: SortConfiguration) {
        self.imagesConfiguration = imagesConfiguration
        self.sortConfiguration = sortConfiguration
    }

}
