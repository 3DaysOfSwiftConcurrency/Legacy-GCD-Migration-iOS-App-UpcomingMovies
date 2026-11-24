import UpcomingMoviesDomain
import UpcomingMoviesData
import CoreDataInfrastructure

@MainActor
final class AppModel {
    static let shared = AppModel.live()

    let upcomingMoviesFeature: UpcomingMoviesFeature
    let searchMoviesFeature: SearchMoviesFeature
    let accountFeature: AccountFeature
    let profileFeature: ProfileFeature
    let signInFeature: SignInFeature
    let savedMoviesFeature: SavedMoviesFeature
    let customListsFeature: CustomListsFeature
    let customListDetailFeature: CustomListDetailFeature
    let movieCreditsFeature: MovieCreditsFeature
    let movieReviewsFeature: MovieReviewsFeature
    private static var searchObservation: Task<Void, Never>?

    init(upcomingMoviesFeature: UpcomingMoviesFeature,
         searchMoviesFeature: SearchMoviesFeature,
         accountFeature: AccountFeature,
         profileFeature: ProfileFeature,
         signInFeature: SignInFeature,
         savedMoviesFeature: SavedMoviesFeature,
         customListsFeature: CustomListsFeature,
         customListDetailFeature: CustomListDetailFeature,
         movieCreditsFeature: MovieCreditsFeature,
         movieReviewsFeature: MovieReviewsFeature) {
        self.upcomingMoviesFeature = upcomingMoviesFeature
        self.searchMoviesFeature = searchMoviesFeature
        self.accountFeature = accountFeature
        self.profileFeature = profileFeature
        self.signInFeature = signInFeature
        self.savedMoviesFeature = savedMoviesFeature
        self.customListsFeature = customListsFeature
        self.customListDetailFeature = customListDetailFeature
        self.movieCreditsFeature = movieCreditsFeature
        self.movieReviewsFeature = movieReviewsFeature
    }

    // Retain a single startup task, including installation of the search/visit listeners.
    static func applicationDidFinishLaunching() {
        guard searchObservation == nil else { return }
        let preparation = Task {
            let dependencies = DIContainer.shared
            let configuration = await prepareLaunchDependencies()
            let remote: RemoteDataSourceProtocol = dependencies.resolve()
            remote.configure(with: configuration.keys.apiKey, readAccessToken: configuration.keys.readAccessToken)
        }
        searchObservation = SearchMoviesFeature.startObservingChanges(after: preparation) { shared.searchMoviesFeature }
    }

    private nonisolated static func prepareLaunchDependencies() async -> BaseConfiguration {
        CoreDataStack.prepareManagedObjectModel()
        return PropertyListHelper.decode()
    }

    static func waitForStartup() async {
        await searchObservation?.value
    }

    static func live() -> AppModel {
        // Legacy UIKit routes still resolve these same app-scoped dependencies.
        let dependencies = DIContainer.shared
        let provider: UseCaseProviderProtocol = dependencies.resolve()
        let authentication: AuthenticationHandlerProtocol = dependencies.resolve()
        let genres: GenreHandlerProtocol = dependencies.resolve()
        let movies = provider.movieUseCase()
        let account = provider.accountUseCase()
        let user = provider.userUseCase()
        let auth = provider.authUseCase()

        return AppModel(
            upcomingMoviesFeature: UpcomingMoviesFeature(movieUseCase: movies, genreHandler: genres,
                                                         preferences: DefaultsPresentationModeRepository()),
            searchMoviesFeature: SearchMoviesFeature(movieUseCase: movies,
                                                     movieSearchUseCase: provider.movieSearchUseCase(),
                                                     movieVisitUseCase: provider.movieVisitUseCase(),
                                                     genreUseCase: provider.genreUseCase(),
                                                     authenticationHandler: authentication),
            accountFeature: AccountFeature(authHandler: authentication),
            profileFeature: ProfileFeature(userUseCase: user, authUseCase: auth, accountUseCase: account),
            signInFeature: SignInFeature(authUseCase: auth, userUseCase: user),
            savedMoviesFeature: SavedMoviesFeature(accountUseCase: account),
            customListsFeature: CustomListsFeature(accountUseCase: account),
            customListDetailFeature: CustomListDetailFeature(accountUseCase: account),
            movieCreditsFeature: MovieCreditsFeature(movieUseCase: movies),
            movieReviewsFeature: MovieReviewsFeature(movieUseCase: movies)
        )
    }
}
