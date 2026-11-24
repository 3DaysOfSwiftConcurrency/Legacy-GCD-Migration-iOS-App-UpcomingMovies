import UpcomingMoviesDomain
import UpcomingMoviesData

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
    private var hasLaunched: Bool

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
        hasLaunched = false
    }

    // Configuration must finish before the splash route can issue a request.
    func applicationDidFinishLaunching(configuration: BaseConfiguration, remoteDataSource: RemoteDataSourceProtocol) {
        guard !hasLaunched else { return }
        remoteDataSource.configure(with: configuration.keys.apiKey, readAccessToken: configuration.keys.readAccessToken)
        hasLaunched = true
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
            upcomingMoviesFeature: UpcomingMoviesFeature(movieUseCase: movies, genreHandler: genres),
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
