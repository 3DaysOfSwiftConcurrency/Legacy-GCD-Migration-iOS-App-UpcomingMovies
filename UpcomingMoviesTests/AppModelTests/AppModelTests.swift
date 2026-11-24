import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class AppModelTests: XCTestCase {
    func testScenePreferenceChangesStayWithinTheirAppGraph() {
        let first = makeGraph()
        let second = makeGraph()
        let screen = UpcomingMoviesViewModel(upcomingMoviesFeature: first.upcomingMoviesFeature,
                                             factory: MockUpcomingMoviesFactory())
        screen.updatePresentationMode()
        XCTAssertEqual(first.upcomingMoviesFeature.presentationMode, .detail)
        XCTAssertEqual(second.upcomingMoviesFeature.presentationMode, .preview)
    }

    private func makeGraph() -> AppModel {
        let account = AccountUseCaseProtocolMock()
        let user = UserUseCaseProtocolMock()
        let auth = AuthUseCaseProtocolMock()
        let search = SearchMoviesFeatureTestDependencies()
        return AppModel(
            upcomingMoviesFeature: UpcomingMoviesFeature(preferences: MockUserPreferencesHandler(),
                loadUpcomingMovies: { _, completion in completion(.success([])) },
                makeMoviePresentationModel: { MockMovieProtocol(id: $0.id) }),
            searchMoviesFeature: search.makeFeature(observeHistory: false),
            accountFeature: AccountFeature(authHandler: SearchAuthenticationHandlerMock()),
            profileFeature: ProfileFeature(userUseCase: user, authUseCase: auth, accountUseCase: account),
            signInFeature: SignInFeature(authUseCase: auth, userUseCase: user),
            savedMoviesFeature: SavedMoviesFeature(accountUseCase: account),
            customListsFeature: CustomListsFeature(accountUseCase: account),
            customListDetailFeature: CustomListDetailFeature(accountUseCase: account),
            movieCreditsFeature: MovieCreditsFeature(movieUseCase: search.movieUseCase),
            movieReviewsFeature: MovieReviewsFeature(movieUseCase: search.movieUseCase)
        )
    }
}
