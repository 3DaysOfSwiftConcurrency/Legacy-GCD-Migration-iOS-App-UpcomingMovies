import XCTest
@testable import UpcomingMovies

@MainActor
final class MovieListViewModelTests: XCTestCase {
    func testRefreshPresentsFirstPage() {
        let source = MoviesStub()
        let model = MovieListViewModel(interactor: source)
        model.refreshMovies()
        XCTAssertEqual(source.pages, [1])
        XCTAssertEqual(model.movieCells.count, 1)
        XCTAssertEqual(model.selectedMovie(at: 0).id, 7)
    }
}

private final class MoviesStub: MoviesInteractorProtocol {
    var pages: [Int] = []

    func getMovies(page: Int, completion: @escaping (Result<[MovieProtocol], Error>) -> Void) {
        pages.append(page)
        completion(.success([MockMovieProtocol(id: 7)]))
    }
}
