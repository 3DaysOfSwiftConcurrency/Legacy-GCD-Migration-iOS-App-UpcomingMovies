//
//  SearchMoviesFeature.swift
//  UpcomingMovies
//
//  Created by Matthew Thomas on 26/10/26.
//

import Combine
import Foundation
import OSLog
import UpcomingMoviesDomain

/// Owns Search's domain operations and their shared in-flight work.
///
/// The UIKit screens retain their presentation state. This feature owns the
/// callback-to-async boundary, maps domain values into the existing presentation
/// models, and prevents equivalent searches or loads from running twice.
@MainActor
final class SearchMoviesFeature {

    private let movieUseCase: MovieUseCaseProtocol
    private var movieSearchUseCase: MovieSearchUseCaseProtocol
    private var movieVisitUseCase: MovieVisitUseCaseProtocol
    private let genreUseCase: GenreUseCaseProtocol
    private let authenticationHandler: AuthenticationHandlerProtocol

    private var searchTasksByRequest: [SearchRequest: Task<[MovieProtocol], Error>] = [:]
    private var recentSearchesTask: Task<[MovieSearchProtocol], Error>?
    private var genresTask: Task<[GenreProtocol], Error>?
    private var movieVisitsTask: Task<[MovieVisitProtocol], Error>?

    private var queuedSearchSaveTask: Task<Result<Void, Error>, Never>?
    private var searchSaveGeneration = 0

    private let movieSearchesDidChangeSubject = PassthroughSubject<Void, Never>()
    var movieSearchesDidChange: AnyPublisher<Void, Never> { movieSearchesDidChangeSubject.eraseToAnyPublisher() }
    private let movieVisitsDidChangeSubject = PassthroughSubject<Void, Never>()
    var movieVisitsDidChange: AnyPublisher<Void, Never> { movieVisitsDidChangeSubject.eraseToAnyPublisher() }

    init(movieUseCase: MovieUseCaseProtocol,
         movieSearchUseCase: MovieSearchUseCaseProtocol,
         movieVisitUseCase: MovieVisitUseCaseProtocol,
         genreUseCase: GenreUseCaseProtocol,
         authenticationHandler: AuthenticationHandlerProtocol) {
        self.movieUseCase = movieUseCase
        self.movieSearchUseCase = movieSearchUseCase
        self.movieVisitUseCase = movieVisitUseCase
        self.genreUseCase = genreUseCase
        self.authenticationHandler = authenticationHandler

    }

    /// The startup signal is synchronous; callbacks are attached without opening the store.
    static func startObservingChanges(after preparation: Task<Void, Never>,
                                      feature: @escaping @MainActor () -> SearchMoviesFeature) -> Task<Void, Never> {
        Task {
            await preparation.value
            feature().observeHistoryChanges()
        }
    }

    func observeHistoryChanges() {
        movieSearchUseCase.didUpdateMovieSearch = { [weak self] in
            Task { @MainActor [weak self] in
                self?.movieSearchesDidChangeSubject.send(())
            }
        }

        self.movieVisitUseCase.didUpdateMovieVisit = { [weak self] in
            Task { @MainActor [weak self] in
                self?.movieVisitsDidChangeSubject.send(())
            }
        }
    }

    func searchMovies(searchText: String) async throws -> [MovieProtocol] {
        let searchRequest = SearchRequest(
            searchText: searchText,
            includesAdultResults: try await authenticationHandler.loadCurrentUser()?.includeAdult ?? false
        )

        if let searchTask = searchTasksByRequest[searchRequest] {
            return try await searchTask.value
        }

        let searchTask = Task { [weak self] () throws -> [MovieProtocol] in
            guard let self else {
                throw CancellationError()
            }

            defer {
                self.searchTasksByRequest[searchRequest] = nil
            }

            return try await self.requestMovies(for: searchRequest)
        }

        searchTasksByRequest[searchRequest] = searchTask
        return try await searchTask.value
    }

    func loadRecentSearches() async throws -> [MovieSearchProtocol] {
        if let recentSearchesTask {
            return try await recentSearchesTask.value
        }

        let loadTask = Task { [weak self] () throws -> [MovieSearchProtocol] in
            guard let self else {
                throw CancellationError()
            }

            defer {
                self.recentSearchesTask = nil
            }

            return try await self.requestRecentSearches()
        }

        recentSearchesTask = loadTask
        return try await loadTask.value
    }

    func loadGenres() async throws -> [GenreProtocol] {
        if let genresTask {
            return try await genresTask.value
        }

        let loadTask = Task { [weak self] () throws -> [GenreProtocol] in
            guard let self else {
                throw CancellationError()
            }

            defer {
                self.genresTask = nil
            }

            return try await self.requestGenres()
        }

        genresTask = loadTask
        return try await loadTask.value
    }

    func loadMovieVisits() async throws -> [MovieVisitProtocol] {
        if let movieVisitsTask {
            return try await movieVisitsTask.value
        }

        let loadTask = Task { [weak self] () throws -> [MovieVisitProtocol] in
            guard let self else {
                throw CancellationError()
            }

            defer {
                self.movieVisitsTask = nil
            }

            return try await self.requestMovieVisits()
        }

        movieVisitsTask = loadTask
        return try await loadTask.value
    }

    /// Every admitted save, including an identical query, represents a history event.
    /// The screen need not wait: history failure must not interrupt movie search.
    @discardableResult
    func recordSearchText(_ searchText: String) -> Task<Result<Void, Error>, Never> {
        let predecessor = queuedSearchSaveTask
        searchSaveGeneration += 1
        let generation = searchSaveGeneration
        let task = Task { [weak self, movieSearchUseCase] in
            _ = await predecessor?.value
            let result: Result<Void, Error> = await withCheckedContinuation { continuation in
                movieSearchUseCase.save(with: searchText) { continuation.resume(returning: $0) }
            }
            if case .failure(let error) = result {
                Logger().error("Could not save search history: \(error.localizedDescription, privacy: .private)")
            }
            if self?.searchSaveGeneration == generation {
                self?.queuedSearchSaveTask = nil
            }
            return result
        }
        queuedSearchSaveTask = task
        return task
    }

    private func requestMovies(for request: SearchRequest) async throws -> [MovieProtocol] {
        try await withCheckedThrowingContinuation { continuation in
            movieUseCase.searchMovies(
                searchText: request.searchText,
                includeAdult: request.includesAdultResults,
                page: nil
            ) { result in
                continuation.resume(with: result.map { movies in
                    movies.map(MovieModel.init)
                })
            }
        }
    }

    private func requestRecentSearches() async throws -> [MovieSearchProtocol] {
        try await withCheckedThrowingContinuation { continuation in
            movieSearchUseCase.getMovieSearches { result in
                continuation.resume(with: result.map { movieSearches in
                    Array(movieSearches.prefix(5)).map(MovieSearchModel.init)
                })
            }
        }
    }

    private func requestGenres() async throws -> [GenreProtocol] {
        try await withCheckedThrowingContinuation { continuation in
            genreUseCase.fetchAll(completion: { result in
                continuation.resume(with: result.map { genres in
                    genres.map(GenreModel.init)
                })
            }, forceRefresh: false)
        }
    }

    private func requestMovieVisits() async throws -> [MovieVisitProtocol] {
        try await withCheckedThrowingContinuation { continuation in
            movieVisitUseCase.getMovieVisits { result in
                continuation.resume(with: result.map { movieVisits in
                    movieVisits.map(MovieVisitModel.init)
                })
            }
        }
    }

}

private struct SearchRequest: Hashable {
    let searchText: String
    let includesAdultResults: Bool
}
