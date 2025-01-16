import SwiftUI
import FirebaseCore

// AppDelegate for Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// AppState to manage and save the current screen
class AppState: ObservableObject {
    @Published var currentPage: String = "ContentView" // Default page

    // Save the current page to UserDefaults
    func saveCurrentPage() {
        UserDefaults.standard.set(currentPage, forKey: "LastPage")
    }

    // Load the last saved page from UserDefaults
    func loadCurrentPage() {
        currentPage = UserDefaults.standard.string(forKey: "LastPage") ?? "ContentView"
    }
}

@main
struct EPHS_Course_GenieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(appState)
                    .onAppear {
                        appState.loadCurrentPage() // Load last page when app launches
                    }
                    .onDisappear {
                        appState.saveCurrentPage() // Save current page when app goes into the background
                    }
            }
        }
    }
}

// Main ContentView to switch between screens
struct ContentView1: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            switch appState.currentPage {
            case "ContentView":
                ContentView()
            case "CapstoneView":
                CapstoneView(email: "Test3@gmail.com")
            case "CourseSelectionView":
                CourseSelectionView(email: "Test5@gmail.com")
            case "CourseDetailsView":
                CourseDetailsView(email: "Test3@gmail.com")
            case "RecommendedCourseView":
                RecommendedCourseView()
            case "AdminCoursesView":
                CourseSelectionView1(email: "")
            case "StudentListView":
                StudentListView()
            case "AddUnitView":
                AddUnitView(email: "", courseId: "test")
            case "EditUnitView":
                EditUnitView(email: "Test3@gmail.com", courseId: "3DF48266-B100-4BE7-968A-826AC5786277", units: [])
            case "MyCourses":
                MyCourses(email: "test5@gmail.com")
            case "DetailView":
                DetailView(email: "Test3@gmail.com", courseId: "36C48D95-E0EA-4784-9A67-AC02F78292AC", courseName: "Math 10")
            case "AddCourseView":
                AddCourseView(email: "")
            case "EditCourseView":
                EditCourseView(email: "", courseName: "English 11")
            case "AdminLoginView":
                AdminLoginView()
            case "ForgotPasswordView":
                ForgotPasswordView()
            case "LoginView":
                LoginView()
            case "ProfileView":
                ProfileView(email: " ")
            default:
                Text("Unknown page")
            }
        }
    }
}
