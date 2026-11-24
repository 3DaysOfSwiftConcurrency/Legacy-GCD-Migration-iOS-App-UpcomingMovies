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
        container.register(UpcomingMoviesFactoryProtocol.self) { _ in
            UpcomingMoviesFactory()
        }

        container.register(UpcomingMoviesViewModelProtocol.self) { resolver in
            guard let factory = resolver.resolve(UpcomingMoviesFactoryProtocol.self) else {
                fatalError("UpcomingMoviesFactoryProtocol dependency could not be resolved")
            }
            return MainActor.assumeIsolated {
                UpcomingMoviesViewModel(upcomingMoviesFeature: AppModel.shared.upcomingMoviesFeature,
                                        factory: factory)
            }
        }

        container.register(UpcomingMoviesLayoutProviderProtocol.self) { _ in
            UpcomingMoviesLayoutProvider()
        }
    }

}
