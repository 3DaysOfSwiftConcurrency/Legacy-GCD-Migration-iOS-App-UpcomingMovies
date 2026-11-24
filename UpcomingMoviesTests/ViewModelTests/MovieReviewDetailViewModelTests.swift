import XCTest
@testable import UpcomingMovies

@MainActor
final class MovieReviewDetailViewModelTests: XCTestCase {
    func testDisplaysUnabridgedReview() {
        let model = MovieReviewDetailViewModel(review: MockReviewProtocol(authorName: "Lee", content: "First line\nSecond line"))
        XCTAssertEqual(model.author, "Lee")
        XCTAssertEqual(model.content, "First line\nSecond line")
    }
}
