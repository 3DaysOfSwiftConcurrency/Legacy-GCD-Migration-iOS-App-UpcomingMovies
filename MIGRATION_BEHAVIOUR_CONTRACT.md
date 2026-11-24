# UpcomingMovies Migration Behaviour Contract

## Migration failure log — 26 October 2026

**Status: failed pilot; not a completed CFA migration.**

The work changed one callback route inside the existing legacy scene layout.
When Matthew Thomas opened the project, the Xcode navigator still presented the
same legacy `DependencyInjection`, `ViewComponents`, `Scenes`, `Storyboards`
and `Helpers` structure. That means the project did not visibly communicate CFA
feature ownership, and the work had not met the migration goal.

The earlier statement that the migration was complete was incorrect. Source
parsing and a pre-change test baseline are not evidence of a completed
architecture migration. This pilot must not be used as a CFA example, training
case, or precedent. Any restart must begin with an approved visible target
structure, feature-by-feature migration milestones, post-change test evidence,
and a final navigator review before completion can be claimed.

This contract describes observed and inferred product behaviour at upstream
baseline commit `d07c8853630c853d4d4cb8f3defb783bb664e48a`. A Simulator build
and the 308-test suite passed before the route change. The first scope is the
**Upcoming Movies** tab's list-loading route.

| ID | Plain-English requirement | Legacy evidence | Evidence status | Baseline | Replacement protection | Post-migration result | Manual regression | Difference and approval |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | When the Upcoming Movies screen first appears, it requests the current page of upcoming movies and presents an initial loading indicator. | `UpcomingMoviesViewController.viewDidLoad`; `UpcomingMoviesViewModel.getMovies` | Inferred | Simulator build and 308-test suite passed; runtime not yet exercised | Focused ViewModel test plus pending normal-Terminal suite | Implemented; verification pending | Launch tab and observe initial load | None |
| BEH-002 | When the user pulls to refresh Upcoming Movies, the screen requests page one and ends the refresh control after reloading the collection. | `UpcomingMoviesViewController.setupRefreshControl`; `reloadCollectionView`; `UpcomingMoviesViewModel.refreshMovies` | Inferred | Simulator build and 308-test suite passed; runtime not yet exercised | Owned request task; pending normal-Terminal suite | Implemented; verification pending | Pull to refresh with populated and failed responses | None |
| BEH-003 | When the existing list state permits prefetching, displaying further collection items requests the next movies page. | `UpcomingMoviesViewController.reloadCollectionView`; `CollectionViewDataSourcePrefetching` | Inferred | Simulator build and 308-test suite passed; runtime not yet exercised | Feature-level latest-request policy; pending normal-Terminal suite | Implemented; verification pending | Scroll through a multi-page result | A newer page-one refresh suppresses an older prefetch result so stale data cannot redraw the list. |
| BEH-004 | When movie loading fails, the screen presents the existing retry UI and retry requests the first page. | `UpcomingMoviesViewController.configureView`; `UpcomingMoviesViewModel.fetchMovies` | Inferred | Simulator build and 308-test suite passed; runtime not yet exercised | Controlled failing-provider test plus pending normal-Terminal suite | Implemented; verification pending | Simulate failure and tap retry | A successful network response with no payload now reports `APIError.invalidData`; it no longer leaves the callback route unresolved. |

## Baseline limitations

The upstream project requires CocoaPods. Its dependencies were installed on
25 October 2026. A device build still requires the upstream project's private
Apple development profiles. A normal-Terminal Simulator workspace build passed
after the SwiftLint development dependency was updated; that establishes
compilation and linking. The `UpcomingMoviesTests` scheme then passed 308 tests
with zero failures. A manual app journey has not yet run.

The initial normal-Terminal workspace build reached the app target but stopped
in the SwiftLint script phase: locked SwiftLint 0.41.0 contained an x86_64-only
binary, while this Apple Silicon machine has no Rosetta translation. Updating
only that development dependency to SwiftLint 0.65.1 preserved linting and
allowed the Simulator build to pass. This was a tooling compatibility update,
not an application-behaviour change.

## Route inventory

The observed initial route is:

```text
UpcomingMoviesViewController
  → UpcomingMoviesViewModel
  → UpcomingMoviesFeature
  → MovieRepository
  → MovieRemoteDataSource
  → MovieClient / URLSession
```

`UpcomingMoviesFeature` now bridges the legacy use-case completion exactly once
through a checked throwing continuation. It coalesces duplicate page loads and
uses a latest-request-wins policy across different pages: a user-initiated
refresh is more current than an earlier prefetch, so the stale prefetch result
is cancelled before it can publish. The ViewModel owns the corresponding named
page tasks and deliberately ignores that cancellation rather than presenting it
as an error.

The `MovieRemoteDataSource` had a successful-response path with no payload
that returned without calling its completion. That would leave a continuation
suspended indefinitely, so this one in-scope error behaviour is now explicit:
the route returns `APIError.invalidData` and retains the existing retry UI.

The migrated route must still pass the normal-Terminal test suite and receive a
manual UIKit regression before it can claim behavioural equivalence.

## Current migration status

**Continuing migration: moving the complete Upcoming Movies route into the
visible CFA folder map, then re-running its build, tests and manual regression.**

See `MIGRATION_PLAN.md` for the tab ownership map, visible destination and
remaining completion checkpoints. No final migration claim is permitted until
the plan's explicit application-level completion evidence exists.

### Step 7 verification — 24 November 2026

The host's iPhone 17 Pro build, tests and accepted launch command predate these
changes. Its later generic-device Release build stopped at a test-only Domain
import. The three Data mocks now use ordinary imports. Local arm64 iOS module
compilation succeeded for Domain, Data, CoreDataInfrastructure and
NetworkInfrastructure without enabling testability; this was not an app link.

The 219 outstanding app Swift paths were relocated. All source references
resolve (331 app, 113 app tests, 8 widget), with the same source membership as
before the moves. Two isolated macOS XCTest checks passed against the genre
cache code: refresh versus late restore/pending save, and SQLite write ordering
and rollback. These checks do not replace the iOS test plan.

The restricted Xcode process reported the workspace was not a workspace file
and could not connect to CoreSimulator. The Release app/widget builds and
five-target test plan did not run to completion here. BEH-001 through BEH-004
still require an interactive repeat: observe initial loading, refresh a
populated list, scroll into the next page, then trigger a failure and retry.
No post-change observation of those journeys or visual equivalence is claimed.

#### Focused concurrency and product verification

On the source immediately **before** this audit, the host passed the iPhone
17 Pro scheme build and tests and the generic-device Release build. The iPhone
orientation declarations were present. These results supersede the earlier
local build limitation for that revision, not for the edits below.

This audit isolated the Account feature owner and corrected superseded requests
in Upcoming Movies and Search. Two isolated macOS XCTest cases ran with the
Upcoming Movies production Feature, ViewModel and paging logic and stand-ins
for iOS dependencies: cancelling one waiter preserved the shared page, and late
prefetch success/failure could not replace refresh data or clear a pending
refresh handle. Both passed. A Foundation-only round trip of the shared widget
URL builder and destination enum passed for both upcoming and search.

The edited iOS scheme has not been verified here: the local workspace test
command rejected the workspace and reported no discoverable simulator runtime.
Host verification of these edits, BEH-001–004 on screen, widget taps, retained
user data on upgrade and rotation remain handoff checks.

#### Focused failure, ownership, identity and launch audit

The host passed the iPhone 17 Pro build and scheme tests and the generic-device
Release build **before** this batch. For the edited source, the local simulator
SDK compiler emitted modules for the app, widget, four first-party frameworks,
and all five test-plan targets using the project source memberships for the app,
widget and app tests. This was not an app link, install or iOS test run.

An offline macOS harness ran 42 XCTest cases from SignInFeatureTests,
AccountRemoteDataSourceTests, AuthRemoteDataSourceTests, GenreRepositoryTests
and UserRepositoryTests: all passed. These include retrying an injected local
save failure without reauthenticating, rejecting missing response bodies, and
retaining fresh genres despite a late restore or failed refresh. An independent
in-memory Core Data check using PersistenceStore observed committed inserts,
updates and deletes, filtered insert-only notifications, and received no
change after a rejected save and rollback. Disposable compiler, XCTest and
probe logs are in `/tmp/upcoming-focus.ilc8R2`.

Compared HEAD and working-tree Debug and Release configurations. In each,
the before and after bundle IDs are identical: app
`com.Alonso.UpcomingMovies.AppDev`, app tests `com.Alonso.UpcomingMoviesTests`,
widget `com.Alonso.UpcomingMovies.AppDev.Widget`. No new target or identifier
change. The four dependency test targets retain their CocoaPods identifiers.

The local Xcode test and Release commands rejected the workspace; CoreSimulator
refused the connection. Repeat BEH-001–004 (initial load, refresh, pagination,
failure and retry), sign-in save/retry and cold-launch navigation on the host.
Neither first-frame timing nor post-edit visual or interactive behaviour was
observed here.

#### Focused storage, scene navigation, networking and observation verification

The host's iPhone 17 Pro build and scheme tests and generic-device Release
build passed **before** these edits. For the edited source, the simulator SDK
compiler emitted modules for the app, widget, four first-party frameworks and
five test targets. This did not link or launch the app.

Offline checks on macOS (logs in `/tmp/upcoming-navigation.jWbMNE`):

- A real SQLite open failed with a file obstructing its parent directory.
  Removing the obstruction and retrying on the same stack created the parent
  and opened the configured URL. A subsequent request reused the store and
  fetched the saved row.
- With controlled dependencies, SplashViewModel signalled navigation while
  genre restoration was pending. SearchOptionsViewModel reported an initial
  history error, cleared it after retry, and retained its row after a failed
  refresh. These checks did not exercise UIKit or app-group entitlements.
- All 25 MovieClient tests passed, including two distinct mock transport tasks
  resumed with both responses held. Three isolated Upcoming Movies tests passed,
  including ordered presentation-mode changes received by another ViewModel
  sharing the Feature.
- The local Xcode workspace commands rejected the workspace and CoreSimulator
  was unavailable. The edited iOS suite, including the two-window routing
  test, was not run here. Repeat BEH-001–004, cold widget links and Search
  shortcuts in separate windows, and account/history error and retry on the
  host. Visual equivalence and installed-app data preservation remain unobserved.

#### Focused final audit: domain snapshots and shared state

On the edited source, Swift 6 type-checked the domain entities with checked
Sendable conformances. A macOS harness ran the production SignInFeature with
controlled use cases: a failed save did not replace the reader's user, and a
successful retry returned the updated user without changing the earlier value.
The scenario is also covered in SignInFeatureTests. Best-effort history write
errors are logged without recording the query or interrupting movie results.

The simulator SDK compiler emitted modules for the app, widget, four first-party
frameworks and five test targets. This was not an Xcode build or an XCTest run.
Local artifacts: `/tmp/upcoming-snapshot.LHzXRq` (check.log, modules-final.log,
test.log). CoreSimulator refused the connection and xcodebuild rejected the
workspace. The supplied successful simulator build/tests and device Release
build predate these edits. BEH-001–004, installed-data preservation, rotation
and visual/interactive comparisons remain host handoff checks.

#### Focused final audit: durable commands and project layout

The host built and tested the pre-audit revision on iPhone 17 Pro and built
generic-device Release. After reorganising the two app Utils groups, all
source/resource build-phase references resolved (360 app, 113 test and 10
widget entries); regenerated LocalizedStrings.swift was byte-identical.
The simulator SDK compiler emitted modules for the app, widget, four
first-party frameworks and five test targets. This is not a linked Xcode build.

Two offline macOS probes exercised production code. Holding SignInFeature's
save callback prevented publication; failing it returned the error and retained
the draft; releasing a successful retry returned the new user without another
authentication. Concurrent updates to two existing user IDs through the
production Core Data save path both survived reopening a temporary SQLite store
with the user uniqueness constraint. Logs: /tmp/movies-structure.txwerg.

Local Xcode rejected the workspace and CoreSimulator refused the connection.
The post-move scheme tests and Release build remain for the host. The manual
BEH-001–004 journeys, installed-data upgrade, rotation and iPad resizing were
not observed; neither module compilation nor plist inspection establishes them.

#### Step 7: focused verification of the remaining six CFA rules

The host passed the iPhone 17 Pro scheme build and tests and the generic-device
Release build **before** this batch. After the edits, simulator-SDK compilation
emitted modules for the app, widget, four first-party frameworks and five test
targets. All app, test and widget source/resource references resolve. The
updated test target includes named suites for 39 ViewModels, ten Features and
an isolated AppModel graph. Module compilation is not an XCTest run.

An offline macOS harness ran three repository XCTest cases against the production
Upcoming Movies and Search Features with presentation doubles: equivalent page
requests shared their result, cancelling one waiter preserved the shared load,
and an ordered history queue returned individual outcomes after a failed save,
including an identical second input. A separate Core Data probe advanced the
clock of one history store across UTC midnight; timestamps and newest-first
ordering matched in UTC, America/Los_Angeles and Asia/Bangkok.

Local Xcode rejected the workspace and CoreSimulator refused the device-set
connection. No post-edit linked iOS build, simulator XCTest pass, BEH-001–004
walkthrough, installed-data upgrade, rotation or iPad resizing was observed.
Those remain host/device checks. Local logs: `/tmp/movies-step7.ooyMUL/`.
