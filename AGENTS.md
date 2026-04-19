# Repository Guidelines

## Project Structure & Module Organization
`KudaMoney/` contains the SwiftUI app source. The current entry point is `KudaMoneyApp.swift`, and `ContentView.swift` holds the initial view. App assets live in `KudaMoney/Assets.xcassets/`.

`KudaMoneyTests/` contains unit tests and currently uses Swift Testing (`import Testing`). `KudaMoneyUITests/` contains UI and launch tests built with XCTest.

`KudaMoney.xcodeproj/` stores project configuration, targets, and schemes. Keep code changes in the source and test folders unless a build setting or target change is required.

## Build, Test, and Development Commands
Open the project in Xcode:

```bash
open KudaMoney.xcodeproj
```

Build the app from the command line:

```bash
xcodebuild -project KudaMoney.xcodeproj -scheme KudaMoney build
```

Run all tests on a simulator:

```bash
xcodebuild -project KudaMoney.xcodeproj -scheme KudaMoney \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Use Xcode for previews while iterating on SwiftUI views.

## Coding Style & Naming Conventions
Follow standard Swift and Xcode conventions. Use descriptive `PascalCase` for types (`ContentView`) and `lowerCamelCase` for properties and functions (`testLaunchPerformance`).

Apply SOLID principles in new code and refactors. Follow current Swift best practices and prefer the latest appropriate Apple APIs over deprecated or legacy patterns.

Keep one primary type per file when practical. Match the existing formatting in the file you touch, and do not mix indentation styles within a file. Prefer small SwiftUI views and move reusable UI into separate files as the app grows.

Document all new code using standard DocC style comments. Use `///` summaries and DocC sections such as `- Parameters:` and `- Returns:` where they apply.

No source file should exceed 300 lines of code. Split responsibilities into additional files before a file grows past that limit.

No formatter or linter is configured yet, so review diffs carefully before committing.

## Testing Guidelines
Add or update tests for every behavior change. Place logic tests in `KudaMoneyTests/` and interaction or launch coverage in `KudaMoneyUITests/`.

Always write unit tests in Swift Testing for new changes and run them before finishing work. Name XCTest methods with the `test...` prefix. For Swift Testing, use clear `@Test` function names that describe the behavior under test. No coverage gate is configured yet, but new features should ship with meaningful test coverage.

After any source or project change, run an Xcode build or test pass appropriate to the affected targets and fix every Xcode warning before finishing. Do not leave warning cleanup for a later change.

## Commit & Pull Request Guidelines
Recent commits use short, imperative summaries such as `Add .gitignore file and update greeting in ContentView`. Follow that style and keep each commit focused.

Pull requests should include a brief description of the change, note any testing performed, and attach screenshots for UI changes. Link the relevant issue or task when one exists.
