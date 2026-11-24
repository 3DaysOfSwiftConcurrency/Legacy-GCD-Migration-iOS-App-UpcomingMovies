//
//  SplashViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 11/8/18.
//  Copyright © 2018 Alonso. All rights reserved.
//

import UpcomingMoviesDomain

final class SplashViewModel: SplashViewModelProtocol {

    // MARK: - Dependencies

    private let makeInteractor: () -> SplashInteractorProtocol
    private let genreHandler: GenreHandlerProtocol
    private let configurationHandler: ConfigurationHandlerProtocol

    // MARK: - Properties

    let initialDownloadsEnded: PublishBindable<Void> = PublishBindable()

    // MARK: - Initializers

    init(makeInteractor: @escaping () -> SplashInteractorProtocol,
         genreHandler: GenreHandlerProtocol,
         configurationHandler: ConfigurationHandlerProtocol) {
        self.makeInteractor = makeInteractor
        self.genreHandler = genreHandler
        self.configurationHandler = configurationHandler
    }

    // MARK: - SplashViewModelProtocol

    private var downloads: Task<Void, Never>?

    deinit { downloads?.cancel() }

    @MainActor
    func startInitialDownloads() {
        guard downloads == nil else { return }
        downloads = Task { @MainActor [weak self, makeInteractor, configurationHandler, genreHandler] in
            await AppModel.waitForStartup()
            guard !Task.isCancelled else { return }
            let interactor = makeInteractor()
            async let genres: Void = Self.loadGenres(interactor, into: genreHandler)
            await Self.loadConfiguration(interactor, into: configurationHandler)
            guard !Task.isCancelled else { return }
            guard let self else { return }
            self.initialDownloadsEnded.send()
            // Retain this scene’s warm-up until the cache finishes, without gating navigation.
            await genres
            self.downloads = nil
        }
    }

    @MainActor
    private static func loadConfiguration(_ interactor: SplashInteractorProtocol,
                                          into handler: ConfigurationHandlerProtocol) async {
        if let configuration = await interactor.appConfiguration(), !Task.isCancelled {
            handler.setConfiguration(configuration)
        }
    }

    @MainActor
    private static func loadGenres(_ interactor: SplashInteractorProtocol, into handler: GenreHandlerProtocol) async {
        if let genres = await interactor.allGenres(), !Task.isCancelled {
            handler.setGenres(genres)
        }
    }
}
