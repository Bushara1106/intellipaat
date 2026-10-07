# Learning Dashboard (iOS)

Senior Mobile App Developer – Technical Assignment  
**Platform:** iOS · **UI:** UIKit + Storyboards · **Language:** Swift

## Demo credentials
- Email: `learner@intellipaat.com`
- Password: `learn123`  
(Any valid email + password ≥ 6 characters also works.)

## How to run
1. Open `AssignmetTest.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Press **Run**.
4. Unit tests: `Product → Test` (or `Cmd+U`).

## Architecture
**MVVM + Repository**

`UI (Storyboard / UIViewController) → ViewModel → Repository → Mock API + Local JSON cache`

Chosen because it keeps UIKit screens thin, isolates business rules (progress calculation, validation), and mirrors a production mobile stack without over-engineering for a 3-hour scope.

## Offline support
- First successful course fetch is saved as JSON in Application Support via `CourseLocalStore`.
- If the mock “API” fails (or network is unavailable), the repository returns the cached list and the dashboard shows an offline banner.
- Lesson completion updates are written back to the same local cache so progress survives relaunches.

## Security (production tokens)
Store auth tokens in the **iOS Keychain** (not `UserDefaults`). Prefer short-lived access tokens + refresh tokens, App Transport Security, certificate pinning for sensitive APIs, and biometric unlock where appropriate.

## Scale (1M users + hundreds of courses)
1. Paginated / incremental course APIs instead of one bulk payload.  
2. Background sync + conflict strategy for lesson progress.  
3. Image/CDN caching and list virtualization for large catalogs.  
4. Observability: crash reporting, analytics, performance traces.  
5. Feature modules / CI with UI + snapshot tests for critical flows.

## Second platform (Android)
Mirror the same layers with **Kotlin + Jetpack**: Activities/Fragments + XML (or Compose UI if preferred), ViewModel + StateFlow, Repository, Retrofit/local JSON for API, Room or DataStore for offline cache, and Espresso/JUnit for tests. Navigation Component replaces storyboard segues.

## Project structure
```
AssignmetTest/
  Domain/          Models + ProgressCalculator
  Data/            Mock API, local store, repositories
  Presentation/    Login, Dashboard, Details (UIKit)
  Resources/       courses.json
  Base.lproj/      Main.storyboard, LaunchScreen.storyboard
AssignmetTestTests/
  ProgressCalculatorTests.swift
```
