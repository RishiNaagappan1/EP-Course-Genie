import SwiftUI
import FirebaseFirestore
import Combine
// Model for Student
struct Student: Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var courses: [String]
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

// ViewModel to handle Firestore fetching
class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var filteredStudents: [Student] = []
    @Published var searchText: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = true
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchAllStudents()
        setupSearchBinding()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchAllStudents() {
        listener = db.collection("Users").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching students: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let documents = snapshot?.documents else {
                DispatchQueue.main.async {
                    self.errorMessage = "No student documents found"
                    self.isLoading = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.students = documents.compactMap { document in
                    let data = document.data()
                    let firstName = data["First Name"] as? String
                    let lastName = data["Last Name"] as? String
                    let courses = data["Courses"] as? [String] ?? []
                    return Student(
                        id: document.documentID,
                        firstName: firstName ?? "",
                        lastName: lastName ?? "",
                        courses: courses
                    )
                }
                self.filteredStudents = self.students
                self.errorMessage = nil
                self.isLoading = false
                
            }
        }
    }
    private func setupSearchBinding() {
        $searchText
            .receive(on: RunLoop.main)
            .map { query in
                if query.isEmpty {
                    return self.students
                } else {
                    return self.students.filter {
                        $0.firstName.lowercased().contains(query.lowercased()) ||
                        $0.lastName.lowercased().contains(query.lowercased())
                    }
                }
            }
            .assign(to: &$filteredStudents)
    }
}
// Main View displaying list of student profiles with SearchBar
struct StudentListView: View {
    @StateObject private var viewModel = StudentViewModel()
    @State private var navigateStudentCourses = false
    @State private var selectedStudent: Student?
    @State private var navigateToAdminCourses = false
    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                if viewModel.isLoading {
                    ProgressView("Loading students...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    TextField("Search students...", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.top)
                    List(viewModel.filteredStudents) { student in
                        Button(action: {
                            selectedStudent = student
                            navigateStudentCourses = true
                        }) {
                            Text(student.fullName)
                                .font(.headline)
                        }
                    }
                    .navigationTitle("Student Profiles")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                navigateToAdminCourses = true
                            }) {
                                Text("<< Admin Courses")
                            }
                        }
                    }
                    .background(
                        NavigationLink(
                            destination: CourseSelectionView1(email: "") .navigationBarBackButtonHidden(true),
                                isActive: $navigateToAdminCourses
                            ) {
                                EmptyView()
                            }
                    )
                                
                    NavigationLink(
                        destination: Group {
                            if let student = selectedStudent {
                                StudentCoursesView(student: student)
                            } else {
                                Text("Error: No student selected.")
                                    .foregroundColor(.red)
                            }
                        },
                        isActive: $navigateStudentCourses
                    ) {
                        EmptyView()
                    }
                }
            }
        }
    }
}
struct StudentCoursesView: View {
    var db = Firestore.firestore()
    var student: Student
    @State var courses: [String: String] = [:]
    @State var studentCourses: [MyCourse] = []
    @State var ninthGradeCourses: [MyCourse] = []
    @State var tenthGradeCourses: [MyCourse] = []
    @State var eleventhGradeCourses: [MyCourse] = []
    @State var twelfthGradeCourses: [MyCourse] = []
    @State var otherCourses: [MyCourse] = []
    @State var extraCourses: [MyCourse] = []
    @State var dataLoaded = false
    @State var totalCredits = 0
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Display student profile
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(student.firstName) \(student.lastName)")
                            .font(.system(size: 35, weight: .bold)) // Adjust size and weight as needed
                    }
                    .padding()
                    // Courses sections
                    if !ninthGradeCourses.isEmpty {
                        GradeSectionView(title: "9th Grade", courses: ninthGradeCourses)
                    }
                    
                    if !tenthGradeCourses.isEmpty {
                        GradeSectionView(title: "10th Grade", courses: tenthGradeCourses)
                    }
                    
                    if !eleventhGradeCourses.isEmpty {
                        GradeSectionView(title: "11th Grade", courses: eleventhGradeCourses)
                    }
                    
                    if !twelfthGradeCourses.isEmpty {
                        GradeSectionView(title: "12th Grade", courses: twelfthGradeCourses)
                    }
                    
                    if !otherCourses.isEmpty {
                        GradeSectionView(title: "Other Courses", courses: otherCourses)
                    }
                    
                    if !extraCourses.isEmpty {
                        GradeSectionView(title: "Course Overflow", courses: extraCourses)
                    }
                    
                    HStack {
                        Spacer()
                            Text("Total Credits: \(totalCredits) /54")
                                .font(.headline)
                                .foregroundColor(totalCredits > 54 ? .black : .red)
                        Spacer()
                    }
                }
                .padding(.bottom, 10)
            }
            .onAppear {
                if !dataLoaded {
                    fetchStudentCourses()
                }
            }
        }
    }
    private func GradeSectionView(title: String, courses: [MyCourse]) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
                .font(.headline)
                .padding(.top)
                .foregroundColor(.blue)
            
            ForEach(courses) { course in
                courseRow(course: course)
            }
        }
        .padding(.horizontal)
    }
    private func courseRow(course: MyCourse) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(course.name)
                    .font(.headline)
                Text(course.level)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack {
                Text("\(course.credits)")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("credits")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.vertical, 5)
    }
    
    func fetchStudentCourses() {
        guard !student.id.isEmpty else {
            print("Error: student email is empty")
            return
        }
        Task {
            let docRef = db.collection("Users").document(student.id)
            do {
                let document = try await docRef.getDocument()
                if document.exists {
                    courses = document.data()?["Courses"] as? [String: String] ?? [:]
                } else {
                    print("Document does not exist")
                }
            } catch {
                print("Error getting document: \(error)")
            }
            
            for courseId in courses.keys {
                let courseRef = db.collection("Courses").document(courseId)
                let sGrade = courses[courseId]
                do {
                    let document = try await courseRef.getDocument()
                    if document.exists {
                        let course = MyCourse(
                            id: document.data()?["id"] as? String ?? "",
                            name: document.data()?["Name"] as? String ?? "",
                            level: document.data()?["Level"] as? String ?? "",
                            grade: document.data()?["Grades"] as? [String] ?? [],
                            subject: document.data()?["Subject"] as? String ?? "",
                            credits: document.data()?["Credits"] as? Int ?? 0,
                            prerequisites: document.data()?["Prereq"] as? [String] ?? []
                        )
                        
                        switch sGrade {
                        case "Grade 9":
                            ninthGradeCourses.append(course)
                        case "Grade 10":
                            tenthGradeCourses.append(course)
                        case "Grade 11":
                            eleventhGradeCourses.append(course)
                        case "Grade 12":
                            twelfthGradeCourses.append(course)
                        default:
                            otherCourses.append(course)
                        }
                        
                        totalCredits += course.credits
                    } else {
                        print("Document does not exist")
                    }
                } catch {
                    print("Error getting document: \(error)")
                }
            }
            
            dataLoaded = true
        }
    }
}
// Preview of the main student list view
struct StudentListView_Preview: PreviewProvider {
    static var previews: some View {
        StudentListView()
    }
}
