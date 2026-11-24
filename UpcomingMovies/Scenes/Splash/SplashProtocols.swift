//
//  SplashProtocols.swift
//  UpcomingMovies
//
//  Created by Alonso on 8/3/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import UpcomingMoviesDomain

protocol SplashViewModelProtocol {

    var initialDownloadsEnded: PublishBindable<Void> { get }

    @MainActor func startInitialDownloads()

}

protocol SplashInteractorProtocol {

    /**
     * Fetch API configurations.
     */
    @MainActor func appConfiguration() async -> Configuration?

    /**
     * Fetch all the available movie genres
     */
    @MainActor func allGenres() async -> [Genre]?

}
