# Learning Dashboard — Technical Assignment (iOS / Swift)

Swift / SwiftUI Learning Dashboard built within the assignment scope (login, course list, course details, offline cache).

## Demo credentials

- Email: `learner@intellipaat.com`
- Password: `learn123`

## How to run

1. Open `AssignmetTest/AssignmetTest.xcodeproj` in Xcode
2. Select an iPhone simulator
3. Press Run (⌘R)
4. Run unit tests with ⌘U

## Architecture

MVVM + Repository (lightweight Clean Architecture):

`UI (SwiftUI) → ViewModel → Repository → Mock API + Local JSON cache`

Chosen because it keeps UI thin, makes state/testability clear, and mirrors production mobile apps without over-engineering a 3-hour assignment.

## Offline Support

After the first successful course fetch, data is saved as JSON under Application Support (`CourseLocalStore`).  
If the mock API fails (or network is unavailable), the repository returns the cached courses and the dashboard shows an offline banner.

## Security

In production, authentication tokens should be stored in the **iOS Keychain** (not UserDefaults), ideally with access control suited to the session policy. Sensitive API calls should use HTTPS/TLS pinning where appropriate.

## Scale (1M users + hundreds of courses)

1. Paginate / virtualize course lists and use differential sync instead of full dumps  
2. Move cache to a real local DB (Core Data / SQLite / GRDB) with indexed queries  
3. Add CDN + API caching, background refresh, and conflict resolution for lesson progress  
4. Instrument crash/analytics and feature flags for gradual rollout  
5. Split modules (Auth / Courses / Progress) and add CI with UI + unit tests

## Second Platform (Android)

Mirror the same layers with Kotlin + Jetpack Compose: `ViewModel` + `Repository`, Retrofit/Ktor for API, Room/DataStore for offline cache, and Navigation Compose for Login → Dashboard → Details. Share the same JSON contracts and progress rules.

## Project structure

```
AssignmetTest/
  Domain/          Models + ProgressCalculator
  Data/            Mock API, local cache, repositories
  Presentation/    Login, Dashboard, Details (SwiftUI + ViewModels)
  Resources/       courses.json
AssignmetTestTests/
  ProgressCalculatorTests.swift
```
