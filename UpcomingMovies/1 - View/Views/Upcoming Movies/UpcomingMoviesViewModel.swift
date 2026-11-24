//
//  UpcomingMoviesViewModel.swift
//  UpcomingMovies
//
//  Created by Alonso on 11/5/18.
//  Copyright © 2018 Alonso. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class UpcomingMoviesViewModel: UpcomingMoviesViewModelProtocol, SimpleViewStateProcessable {

    // MARK: - Dependencies

    private let upcomingMoviesFeature: UpcomingMoviesFeature
    private let factory: UpcomingMoviesFactoryProtocol
    private var currentLoad: (page: Int, task: Task<Void, Never>)?
    private var modeSubscription: AnyCancellable?
    private var loadGeneration = 0

    deinit { currentLoad?.task.cancel() }

    // MARK: - Reactive properties

    let viewState = BehaviorBindable(UpcomingMoviesViewState.initial).eraseToAnyBindable()
    let startLoading = BehaviorBindable(false).eraseToAnyBindable()
    let didUpdatePresentationMode = PublishBindable<UpcomingMoviesPresentationMode>().eraseToAnyBindable()

    // MARK: - Computed properties

    private var movies: [MovieProtocol] {
        viewState.value.currentEntities
    }

    var movieCells: [UpcomingMovieCellViewModelProtocol] {
        movies.compactMap { UpcomingMovieCellViewModel($0) }
    }

    var needsPrefetch: Bool {
        viewState.value.needsPrefetch
    }

    var currentPresentationMode: UpcomingMoviesPresentationMode {
        upcomingMoviesFeature.presentationMode
    }

    // MARK: - Initializers

    init(upcomingMoviesFeature: UpcomingMoviesFeature,
         factory: UpcomingMoviesFactoryProtocol) {
        self.upcomingMoviesFeature = upcomingMoviesFeature
        self.factory = factory
        modeSubscription = upcomingMoviesFeature.modeChanges.sink { [weak self] mode in
            self?.didUpdatePresentationMode.send(mode)
        }
    }

    // MARK: - UpcomingMoviesViewModelProtocol

    @discardableResult
    func getMovies() -> Task<Void, Never> {
        let showLoader = viewState.value.isInitialPage
        return loadMovies(page: viewState.value.currentPage, showLoader: showLoader)
    }

    @discardableResult
    func refreshMovies() -> Task<Void, Never> {
        loadMovies(page: 1, showLoader: false)
    }

    func movie(for index: Int) -> MovieProtocol {
        movies[index]
    }

    func getToggleBarButtonItemModel() -> ToggleBarButtonItemViewModelProtocol {
        let contents = factory.makeGridBarButtonItemContents(for: currentPresentationMode)
        return ToggleBarButtonItemViewModel(contents: contents)
    }

    func updatePresentationMode() {
        _ = upcomingMoviesFeature.togglePresentationMode()
    }

    // MARK: - Private

    private func loadMovies(page: Int, showLoader: Bool) -> Task<Void, Never> {
        if let currentLoad, currentLoad.page == page, !currentLoad.task.isCancelled {
            return currentLoad.task
        }

        currentLoad?.task.cancel()
        loadGeneration += 1
        let generation = loadGeneration
        let upcomingMoviesFeature = self.upcomingMoviesFeature
        let loadTask = Task { [weak self] in
            defer {
                if let self, self.loadGeneration == generation {
                    self.currentLoad = nil
                    self.startLoading.value = false
                }
            }
            do {
                let movies = try await upcomingMoviesFeature.loadMovies(page: page)
                guard let self, self.loadGeneration == generation, !Task.isCancelled else { return }
                self.viewState.value = self.processResult(movies,
                                                          currentPage: page,
                                                          currentEntities: self.movies)
            } catch is CancellationError {
                // A newer load is already responsible for publishing the screen state.
            } catch {
                guard let self, self.loadGeneration == generation, !Task.isCancelled else { return }
                self.viewState.value = .error(error)
            }
        }

        currentLoad = (page, loadTask)
        startLoading.value = showLoader
        return loadTask
    }

}
