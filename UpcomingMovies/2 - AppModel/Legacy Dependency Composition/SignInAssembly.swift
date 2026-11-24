//
//  SignInAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/07/23.
//  Copyright © 2023 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class SignInAssembly: Assembly {

    func assemble(container: Container) {
        container.register(SignInViewModelProtocol.self) { _ in
            return MainActor.assumeIsolated {
                SignInViewModel(signInFeature: AppModel.shared.signInFeature)
            }
        }
    }

}
