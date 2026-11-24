//
//  ProfileAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/15/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class ProfileAssembly: Assembly {

    func assemble(container: Container) {
        container.register(ProfileFactoryProtocol.self) { _ in
            ProfileFactory()
        }

        container.register(ProfileViewModelProtocol.self) { (resolver, user: UserProtocol) in
            guard let factory = resolver.resolve(ProfileFactoryProtocol.self) else {
                fatalError("ProfileFactoryProtocol dependency could not be resolved")
            }
            return MainActor.assumeIsolated {
                ProfileViewModel(userAccount: user,
                                 profileFeature: AppModel.shared.profileFeature,
                                 factory: factory)
            }
        }
    }

}
