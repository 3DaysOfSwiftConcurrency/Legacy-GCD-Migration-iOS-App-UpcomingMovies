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

    private let interactor: SplashInteractorProtocol
    private let genreHandler: GenreHandlerProtocol
    private let configurationHandler: ConfigurationHandlerProtocol

    // MARK: - Properties

    let initialDownloadsEnded: PublishBindable<Void> = PublishBindable()

    // MARK: - Initializers

    init(interactor: SplashInteractorProtocol,
         genreHandler: GenreHandlerProtocol,
         configurationHandler: ConfigurationHandlerProtocol) {
        self.interactor = interactor
        self.genreHandler = genreHandler
        self.configurationHandler = configurationHandler
    }

    // MARK: - SplashViewModelProtocol

    private var downloads: Task<Void, Never>?

    deinit { downloads?.cancel() }

    @MainActor
    func startInitialDownloads() {
        guard downloads == nil else { return }
        downloads = Task { @MainActor [weak self, interactor, configurationHandler, genreHandler] in
            async let configuration: Void = Self.loadConfiguration(interactor, into: configurationHandler)
            async let genres: Void = Self.loadGenres(interactor, into: genreHandler)
            _ = await (configuration, genres)
            guard !Task.isCancelled else { return }
            self?.downloads = nil
            self?.initialDownloadsEnded.send()
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
