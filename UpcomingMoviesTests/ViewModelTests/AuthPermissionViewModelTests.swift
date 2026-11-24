import XCTest
@testable import UpcomingMovies

@MainActor
final class AuthPermissionViewModelTests: XCTestCase {
    func testRequestUsesSuppliedPermissionURL() throws {
        let url = try XCTUnwrap(URL(string: "https://example.invalid/permission?token=abc"))
        XCTAssertEqual(AuthPermissionViewModel(authPermissionURL: url).authPermissionURLRequest?.url, url)
    }
}
