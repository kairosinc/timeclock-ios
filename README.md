# Kairos TimeClock for iOS
## Requirements
- Xcode 8.2+ (IDE)
- Fabric for Mac (Beta deployment and crash reporting)
- Carthage (Optional, Dependency Managment)

## Frameworks
The following external frameworks are used in the project.
- Fabric + Crashlytics (Crash Reporting)
- Moya (API Stack)
- Alamofire (Networking stack for Moya)
- Result (Error reporting for Moya)
- Heimdallr (OAuth Token Managment)
- Reachability (Network Status Reporting)
- Kairos SDK iSO (Facial Recognition)

Aside from Fabric and Crashlytics, all frameworks are bundled in the Repo and managed by Carthage should they ever need updating. Fabric and Crashlytics are installed on the development machine by the Fabric for Mac app and are already soft-linked in the project.

