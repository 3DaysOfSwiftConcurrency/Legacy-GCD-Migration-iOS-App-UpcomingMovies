import XCTest
@testable import UpcomingMovies

@MainActor
final class CustomListDetailHeaderViewModelTests: XCTestCase {
    func testPresentsListDescriptionWithoutArtwork() {
        let model = CustomListDetailHeaderViewModel(list: MockListProtocol(name: "Classics", description: "Weekend picks"))
        XCTAssertEqual(model.description, "Weekend picks")
        XCTAssertNil(model.posterURL)
    }
}
