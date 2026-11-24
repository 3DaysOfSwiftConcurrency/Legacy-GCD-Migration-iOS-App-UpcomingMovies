//
//  UpcomingMoviesFeature.swift
//  UpcomingMovies
//
//  Created by Alonso on 6/13/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import UpcomingMoviesDomain

@MainActor
final class UpcomingMoviesFeature {

    typealias UpcomingMoviesLoader = (Int, @escaping (Result<[Movie], Error>) -> Void) -> Void
    typealias MoviePresentationModel = (Movie) -> MovieProtocol

    private let preferences: PresentationModeRepository
    private let loadUpcomingMovies: UpcomingMoviesLoader
    private let makeMoviePresentationModel: MoviePresentationModel
    private var currentLoad: (page: Int, task: Task<[MovieProtocol], Error>)?
    private var latestRequestIdentifier = 0

    init(movieUseCase: MovieUseCaseProtocol, genreHandler: GenreHandlerProtocol, preferences: PresentationModeRepository) {
        self.preferences = preferences
        self.loadUpcomingMovies = { page, completion in
            movieUseCase.getUpcomingMovies(page: page, completion: completion)
        }
        self.makeMoviePresentationModel = { movie in
            MovieModel(movie, genreHandler: genreHandler)
        }
    }

    init(preferences: PresentationModeRepository,
         loadUpcomingMovies: @escaping UpcomingMoviesLoader,
         makeMoviePresentationModel: @escaping MoviePresentationModel) {
        self.preferences = preferences
        self.loadUpcomingMovies = loadUpcomingMovies
        self.makeMoviePresentationModel = makeMoviePresentationModel
    }

    var presentationMode: UpcomingMoviesPresentationMode {
        preferences.upcomingMoviesPresentationMode
    }

    func togglePresentationMode() -> UpcomingMoviesPresentationMode {
        let next: UpcomingMoviesPresentationMode
        switch presentationMode {
        case .preview: next = .detail
        case .detail: next = .preview
        }
        preferences.upcomingMoviesPresentationMode = next
        return next
    }

    func loadMovies(page: Int) async throws -> [MovieProtocol] {
        // A pull-to-refresh is more relevant than an earlier prefetch. The network
        // requests may finish in either order, but only the newest request is
        // allowed to publish a result to the screen.
        let loadTask: Task<[MovieProtocol], Error>
        if let currentLoad, currentLoad.page == page {
            loadTask = currentLoad.task
        } else {
            latestRequestIdentifier += 1
            let loadUpcomingMovies = self.loadUpcomingMovies
            let makeMoviePresentationModel = self.makeMoviePresentationModel
            loadTask = Task {
                let domainMovies: [Movie] = try await withCheckedThrowingContinuation { continuation in
                    loadUpcomingMovies(page) { result in
                        continuation.resume(with: result)
                    }
                }
                return domainMovies.map(makeMoviePresentationModel)
            }
            currentLoad = (page, loadTask)
        }

        let requestIdentifier = latestRequestIdentifier
        defer {
            if requestIdentifier == latestRequestIdentifier {
                currentLoad = nil
            }
        }

        let movies = try await loadTask.value
        guard requestIdentifier == latestRequestIdentifier else {
            throw CancellationError()
        }
        return movies
    }

}
