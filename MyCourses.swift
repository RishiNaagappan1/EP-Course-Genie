import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore

struct MyCourses: View {
    var db = Firestore.firestore()
    var email: String
    @State var courses: [String:String] = [:]
    @State var myCourses: [MyCourse] = []
    @State var ninthGradeCourses: [MyCourse] = []  // Array for 9th-grade courses
    @State var tenthGradeCourses: [MyCourse] = []  // Array for 10th-grade courses
    @State var eleventhGradeCourses: [MyCourse] = []  // Array for 11th-grade courses
    @State var twelfthGradeCourses: [MyCourse] = []  // Array for 12th-grade courses
    @State var otherCourses: [MyCourse] = []        // Array for unclassified courses
    @State var extraCourses: [MyCourse] = []         // Array for extra courses
    @State var dataLoaded = false
    @State var hasMultipleGrades = false 
    @State var totalCredits = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("My Courses")
                        .font(.title)
                        .padding()

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

                    Text("Total Credits: \(totalCredits) /54")
                        .font(.headline)
                        .foregroundColor(totalCredits > 54 ? .black : .red)
                        .padding(.top)

                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .onAppear {
                if !dataLoaded {
                    getCourses()
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        NavigationLink(destination: ProfileView(email: email).navigationBarBackButtonHidden(true)) {
                            Image(systemName: "person.fill")
                        }
                        Spacer()
                        NavigationLink(destination: CourseSelectionView(email: email).navigationBarBackButtonHidden(true)) {
                            Image(systemName: "book.fill")
                        }
                        Spacer()
                        NavigationLink(destination: MyCourses(email: email).navigationBarBackButtonHidden(true)) {
                            Image(systemName: "list.bullet.clipboard")
                                .resizable()
                                .frame(width: 24, height: 32)
                        }
                        Spacer()
                        NavigationLink(destination: CapstoneView(email: email).navigationBarBackButtonHidden(true)) {
                            Image(systemName: "graduationcap")
                        }
                        Spacer()
                    }
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

    func getCourses() {
        Task {
            let docRef = db.collection("Users").document(email)
            do {
                let document = try await docRef.getDocument()
                if document.exists {
                    courses = document.data()?["Courses"] as! [String:String]
                } else {
                    print("Document does not exist")
                }
            } catch {
                print("Error getting document: \(error)")
            }

            var ninthGradeCredits = 0
            var tenthGradeCredits = 0
            var eleventhGradeCredits = 0
            var twelfthGradeCredits = 0

            for courseId in courses.keys {
                let courseRef = db.collection("Courses").document(courseId)
                let sGrade = courses[courseId]
                do {
                    let document = try await courseRef.getDocument()
                    if document.exists {
                        let course = MyCourse(id: document.data()?["id"] as! String,
                                              name: document.data()?["Name"] as! String,
                                              level: document.data()?["Level"] as! String,
                                              grade: document.data()?["Grades"] as! [String],
                                              subject: document.data()?["Subject"] as! String,
                                              credits: document.data()?["Credits"] as! Int,
                                              prerequisites: document.data()?["Prereq"] as! [String])

                        if sGrade == "Grade 9" {
                            if ninthGradeCredits + course.credits <= 16 {
                                ninthGradeCourses.append(course)
                                ninthGradeCredits += course.credits
                            } else {
                                extraCourses.append(course)
                            }
                        } else if sGrade == "Grade 10" {
                            if tenthGradeCredits + course.credits <= 16 {
                                tenthGradeCourses.append(course)
                                tenthGradeCredits += course.credits
                            } else {
                                extraCourses.append(course)
                            }
                        } else if sGrade == "Grade 11" {
                            if eleventhGradeCredits + course.credits <= 16 {
                                eleventhGradeCourses.append(course)
                                eleventhGradeCredits += course.credits
                            } else {
                                extraCourses.append(course)
                            }
                        } else if sGrade == "Grade 12" {
                            if twelfthGradeCredits + course.credits <= 16 {
                                twelfthGradeCourses.append(course)
                                twelfthGradeCredits += course.credits
                            } else {
                                extraCourses.append(course)
                            }
                        } else {
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

            enforceMinimumCredits()
            dataLoaded = true
        }
    }
    func assignCourse(course: MyCourse, selectedGrade: String) {}

    func enforceMinimumCredits() {
        if ninthGradeCourses.map({ $0.credits }).reduce(0, +) < 14 {
            print("Warning: 9th Grade credits are below the minimum requirement of 14.")
        }
        if tenthGradeCourses.map({ $0.credits }).reduce(0, +) < 14 {
            print("Warning: 10th Grade credits are below the minimum requirement of 14.")
        }
        if eleventhGradeCourses.map({ $0.credits }).reduce(0, +) < 14 {
            print("Warning: 11th Grade credits are below the minimum requirement of 14.")
        }
        if twelfthGradeCourses.map({ $0.credits }).reduce(0, +) < 14 {
            print("Warning: 12th Grade credits are below the minimum requirement of 14.")
        }
    }
}

// Preview for MyCourses
struct MyCourses_Previews: PreviewProvider {
    static var previews: some View {
        MyCourses(email: "Test5@gmail.com")
    }
}
