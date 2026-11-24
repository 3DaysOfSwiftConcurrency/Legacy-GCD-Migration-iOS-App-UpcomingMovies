//
//  SplashInteractor.swift
//  UpcomingMovies
//
//  Created by Alonso on 8/3/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import UpcomingMoviesDomain

struct SplashInteractor: SplashInteractorProtocol {

    private let genreUseCase: GenreUseCaseProtocol
    private let configurationUseCase: ConfigurationUseCaseProtocol

    init(genreUseCase: GenreUseCaseProtocol,
         configurationUseCase: ConfigurationUseCaseProtocol) {
        self.genreUseCase = genreUseCase
        self.configurationUseCase = configurationUseCase
    }

    // MARK: - SplashInteractorProtocol

    func appConfiguration() async -> Configuration? {
        await withCheckedContinuation { continuation in
            configurationUseCase.getConfiguration { continuation.resume(returning: $0.wrappedValue) }
        }
    }

    func allGenres() async -> [Genre]? {
        await withCheckedContinuation { continuation in
            genreUseCase.fetchAll(completion: { continuation.resume(returning: $0.wrappedValue) }, forceRefresh: false)
        }
    }
}
