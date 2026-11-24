//
//  GenreRepository.swift
//  UpcomingMoviesData
//
//  Created by Alonso on 11/2/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UpcomingMoviesDomain

public final class GenreRepository: GenreUseCaseProtocol {

    private let localDataSource: GenreLocalDataSourceProtocol
    private let remoteDataSource: GenreRemoteDataSourceProtocol

    private typealias Reply = (Result<[Genre], Error>) -> Void
    @MainActor private var current: [Genre]?
    @MainActor private var waitingForFirst: [Reply] = []
    @MainActor private var waitingForRefresh: [Reply] = []
    @MainActor private var refreshing = false
    @MainActor private var restoring = false
    @MainActor private var refreshError: Error?

    init(localDataSource: GenreLocalDataSourceProtocol,
         remoteDataSource: GenreRemoteDataSourceProtocol) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    public var didUpdateGenre: (() -> Void)? {
        didSet {
            localDataSource.didUpdateGenre = didUpdateGenre
        }
    }

    public func find(with id: Int, completion: @escaping (Result<Genre?, Error>) -> Void) {
        Task { @MainActor in
            if let current {
                completion(.success(current.first { $0.id == id }))
            } else {
                completion(.success(localDataSource.find(with: id)))
            }
        }
    }

    public func fetchAll(completion: @escaping (Result<[Genre], Error>) -> Void, forceRefresh: Bool) {
        Task { @MainActor in
            if forceRefresh {
                waitingForRefresh.append(completion)
            } else if let current {
                completion(.success(current))
            } else {
                waitingForFirst.append(completion)
            }
            guard !refreshing else { return }
            refreshing = true
            refreshError = nil
            remoteDataSource.getAllGenres { result in
                Task { @MainActor in self.finishRefresh(result) }
            }
            if current == nil && !restoring {
                restoring = true
                localDataSource.restoreGenres { cached in
                    Task { @MainActor in self.finishRestore(cached) }
                }
            }
        }
    }

    @MainActor private func finishRestore(_ cached: [Genre]) {
        restoring = false
        guard current == nil else { return }
        if !cached.isEmpty {
            current = cached
            replyToFirst(.success(cached))
        } else if let refreshError {
            replyToFirst(.failure(refreshError))
        }
    }

    @MainActor private func finishRefresh(_ result: Result<[Genre], Error>) {
        refreshing = false
        let callers = waitingForRefresh
        waitingForRefresh.removeAll()
        switch result {
        case .success(let genres):
            current = genres
            replyToFirst(result)
            callers.forEach { $0(result) }
            localDataSource.saveGenres(genres)
        case .failure(let error):
            refreshError = error
            callers.forEach { $0(result) }
            if !restoring { replyToFirst(result) }
        }
    }

    @MainActor private func replyToFirst(_ result: Result<[Genre], Error>) {
        let callers = waitingForFirst
        waitingForFirst.removeAll()
        callers.forEach { $0(result) }
    }
}
