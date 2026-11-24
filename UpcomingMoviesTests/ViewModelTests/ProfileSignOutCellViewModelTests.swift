import XCTest
@testable import UpcomingMovies

@MainActor
final class ProfileSignOutCellViewModelTests: XCTestCase {
    func testDisplaysLocalizedSignOutAction() {
        XCTAssertEqual(ProfileSignOutCellViewModel().title, LocalizedStrings.signOut())
    }
}
