import XCTest
@testable import UpcomingMovies

@MainActor
final class GenreSearchOptionCellViewModelTests: XCTestCase {
    func testPreservesGenreSelectionIdentity() {
        let model = GenreSearchOptionCellViewModel(genre: MockGenreProtocol(id: 12, name: "Adventure"))
        XCTAssertEqual(model.id, 12)
        XCTAssertEqual(model.name, "Adventure")
    }
}
