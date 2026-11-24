//
//  AccountAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/13/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class AccountAssembly: Assembly {

    func assemble(container: Container) {
        container.register(AccountViewModelProtocol.self) { _ in
            MainActor.assumeIsolated {
                AccountViewModel(accountFeature: AppModel.shared.accountFeature)
            }
        }
    }

}
