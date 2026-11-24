import XCTest
@testable import UpcomingMovies

@MainActor
final class ToggleBarButtonItemViewModelTests: XCTestCase {
    func testPreservesModeAccessibilityOrder() {
        let contents = ["Grid", "List"].map { ToggleBarButtonItemContent(display: .left($0), accessibilityLabel: $0) }
        let model = ToggleBarButtonItemViewModel(contents: contents)
        XCTAssertEqual(model.contents.map { $0.accessibilityLabel }, ["Grid", "List"])
    }
}
