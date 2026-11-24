//
//  SearchMoviesResultViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 11/7/18.
//  Copyright © 2018 Alonso. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class SearchMoviesResultViewModel: SearchMoviesResultViewModelProtocol {

    // MARK: - Dependencies

    private var changesSubscription: AnyCancellable?
    private let searchMoviesFeature: SearchMoviesFeature
    private var recentSearchesTask: Task<Void, Never>?
    private var searchMoviesTask: Task<Void, Never>?

    private(set) var historyError: Error?
    private var currentQuery: String?

    deinit {
        recentSearchesTask?.cancel()
        searchMoviesTask?.cancel()
    }

    // MARK: - Reactive properties

    let viewState = BehaviorBindable(SearchMoviesResultViewState.recentSearches).eraseToAnyBindable()
    let needsRefresh = PublishBindable<Void>().eraseToAnyBindable()

    // MARK: - Computed properties

    private var movies: [MovieProtocol] {
        viewState.value.currentSearchedMovies
    }

    var recentSearchCells: [RecentSearchCellViewModelProtocol] {
        recentSearches.map { RecentSearchCellViewModel(searchText: $0.searchText) }
    }

    var movieCells: [MovieListCellViewModelProtocol] {
        movies.compactMap { MovieListCellViewModel($0)}
    }

    var emptySearchResultsTitle: String {
        LocalizedStrings.emptySearchResults()
    }

    var recentSearchesTitle: String {
        LocalizedStrings.recentSearches()
    }

    // MARK: - Stored properties

    private var recentSearches: [MovieSearchProtocol] = [] {
        didSet {
            if viewState.value == .recentSearches {
                needsRefresh.send()
            }
        }
    }

    // MARK: - Initilalizers

    init(searchMoviesFeature: SearchMoviesFeature) {
        self.searchMoviesFeature = searchMoviesFeature

        changesSubscription = searchMoviesFeature.movieSearchesDidChange.sink { [weak self] in
            _ = self?.loadRecentSearches()
        }
    }

    // MARK: - Movies handling

    func loadRecentSearches() -> Task<Void, Never> {
        if let recentSearchesTask {
            return recentSearchesTask
        }

        let loadTask = Task { [weak self, searchMoviesFeature] in
            defer { self?.recentSearchesTask = nil }
            guard !Task.isCancelled else { return }

            do {
                let searches = try await searchMoviesFeature.loadRecentSearches()
                try Task.checkCancellation()
                self?.historyError = nil
                self?.recentSearches = searches
            } catch {
                guard !Task.isCancelled else { return }
                self?.historyError = error
                self?.needsRefresh.send()
            }
        }

        recentSearchesTask = loadTask
        return loadTask
    }

    func searchMovies(withSearchText searchText: String) -> Task<Void, Never> {
        if currentQuery == searchText, let searchMoviesTask, !searchMoviesTask.isCancelled {
            return searchMoviesTask
        }

        searchMoviesTask?.cancel()
        currentQuery = searchText
        searchMoviesFeature.recordSearchText(searchText)

        let searchTask = Task { [weak self, searchMoviesFeature] in
            guard !Task.isCancelled else { return }
            defer {
                if !Task.isCancelled { self?.searchMoviesTask = nil }
            }

            do {
                let movies = try await searchMoviesFeature.searchMovies(searchText: searchText)
                guard !Task.isCancelled else { return }
                self?.viewState.value = movies.isEmpty ? .empty : .populated(movies)
            } catch {
                guard !Task.isCancelled else { return }
                self?.viewState.value = .error(error)
            }
        }

        searchMoviesTask = searchTask
        viewState.value = .searching
        return searchTask
    }

    func clearMovies() {
        searchMoviesTask?.cancel()
        searchMoviesTask = nil
        currentQuery = nil
        viewState.value = .recentSearches
    }

    // MARK: - Movie detail builder

    func searchedMovie(at index: Int) -> MovieProtocol {
        movies[index]
    }
}
