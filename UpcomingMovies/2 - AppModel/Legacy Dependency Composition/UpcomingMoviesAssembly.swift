//
//  UpcomingMoviesAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/15/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class UpcomingMoviesAssembly: Assembly {

    func assemble(container: Container) {
        // The UIKit screen resolves these synchronous factories on the main actor.
        container.register(UpcomingMoviesFeature.self) { resolver in
            guard let useCaseProvider = resolver.resolve(UseCaseProviderProtocol.self) else {
                fatalError("UseCaseProviderProtocol dependency could not be resolved")
            }
            guard let genreHandler = resolver.resolve(GenreHandlerProtocol.self) else {
                fatalError("GenreHandlerProtocol dependency could not be resolved")
            }
            return MainActor.assumeIsolated {
                UpcomingMoviesFeature(movieUseCase: useCaseProvider.movieUseCase(),
                                      genreHandler: genreHandler)
            }
        }.inObjectScope(.container)

        container.register(UpcomingMoviesFactoryProtocol.self) { _ in
            return UpcomingMoviesFactory()
        }

        container.register(UpcomingMoviesViewModelProtocol.self) { resolver in
            guard let upcomingMoviesFeature = resolver.resolve(UpcomingMoviesFeature.self) else {
                fatalError("UpcomingMoviesFeature dependency could not be resolved")
            }
            guard let factory = resolver.resolve(UpcomingMoviesFactoryProtocol.self) else {
                fatalError("UpcomingMoviesFactoryProtocol dependency could not be resolved")
            }
            guard let userPreferencesHandler = resolver.resolve(UserPreferencesHandlerProtocol.self) else {
                fatalError("UserPreferencesHandlerProtocol dependency could not be resolved")
            }
            return MainActor.assumeIsolated {
                UpcomingMoviesViewModel(upcomingMoviesFeature: upcomingMoviesFeature,
                                        factory: factory,
                                        userPreferencesHandler: userPreferencesHandler)
            }
        }

        container.register(UpcomingMoviesLayoutProviderProtocol.self) { _ in
            return UpcomingMoviesLayoutProvider()
        }
    }

}
