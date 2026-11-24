//
//  MovieDetailInteractor.swift
//  UpcomingMovies
//
//  Created by Alonso on 8/1/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import OSLog
import UpcomingMoviesDomain

final class MovieDetailInteractor: MovieDetailInteractorProtocol {

    private let movieUseCase: MovieUseCaseProtocol
    private let movieVisitUseCase: MovieVisitUseCaseProtocol
    private let genreUseCase: GenreUseCaseProtocol
    private let accountUseCase: AccountUseCaseProtocol

    private let authHandler: AuthenticationHandlerProtocol

    init(movieUseCase: MovieUseCaseProtocol,
         movieVisitUseCase: MovieVisitUseCaseProtocol,
         genreUseCase: GenreUseCaseProtocol,
         accountUseCase: AccountUseCaseProtocol,
         authHandler: AuthenticationHandlerProtocol) {
        self.movieUseCase = movieUseCase
        self.movieVisitUseCase = movieVisitUseCase
        self.genreUseCase = genreUseCase
        self.accountUseCase = accountUseCase
        self.authHandler = authHandler
    }

    func isUserSignedIn() -> Bool {
        authHandler.isUserSignedIn()
    }

    func findGenre(with id: Int, completion: @escaping (Result<Genre?, Error>) -> Void) {
        genreUseCase.find(with: id, completion: completion)
    }

    @MainActor
    func findGenres(for identifiers: [Int]) async -> [Genre] {
        var genres: [Genre] = []
        for id in identifiers {
            guard !Task.isCancelled else { break }
            let result = await withCheckedContinuation { continuation in
                findGenre(with: id) { continuation.resume(returning: $0) }
            }
            if let genre = try? result.get() { genres.append(genre) }
        }
        return genres
    }

    func getMovieDetail(for movieId: Int, completion: @escaping (Result<MovieProtocol, Error>) -> Void) {
        movieUseCase.getMovieDetail(for: movieId, completion: { result in
            switch result {
            case .success(let movie):
                completion(.success(MovieModel(movie)))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    func getMovieAccountState(for movieId: Int,
                              completion: @escaping (Result<Movie.AccountState, Error>) -> Void) {
        movieUseCase.getMovieAccountState(for: movieId, completion: completion)
    }

    func markMovieAsFavorite(movieId: Int, favorite: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        accountUseCase.markMovieAsFavorite(movieId: movieId, favorite: favorite, completion: completion)
    }

    func addToWatchlist(movieId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        accountUseCase.addToWatchlist(movieId: movieId, watchlist: true, completion: completion)
    }

    func removeFromWatchlist(movieId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        accountUseCase.addToWatchlist(movieId: movieId, watchlist: false, completion: completion)
    }

    func saveMovieVisit(with id: Int, title: String, posterPath: String?) {
        movieVisitUseCase.save(with: id, title: title, posterPath: posterPath) { result in
            if case .failure(let error) = result {
                Logger().error("Could not save movie visit: \(error.localizedDescription, privacy: .private)")
            }
        }
    }

}
