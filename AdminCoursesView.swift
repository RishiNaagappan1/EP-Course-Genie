import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore

struct CourseSelectionView1: View {
    var db = Firestore.firestore()
    @StateObject var viewModel = CourseSelectionViewModel()
    @State private var showSavedMessage = false // State variable to control the visibility of the saved message
    var email: String
    @State var getCourses: [MyCourse] = []
    @State var myCourses: [String] = []
    @State var courseName = "test"
    @State var courseId = "test"
    @State var plusMinus = "+"
    @State var navigateAdd = false
    @State var navigateEdit = false
    @State var navigateStudentCourses = false // State variable for Student Courses navigation
    @State private var showDeleteAlert = false
    @State private var courseToDelete: MyCourse?
    var screenWidth = UIScreen.main.bounds.size.width

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // HStack for "Logout" and "Student Courses" buttons
                HStack {
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                        Text("< Logout")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    Spacer()
                    NavigationLink(destination: StudentListView().navigationBarBackButtonHidden(true)) {
                        Text("Student Courses")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding(.horizontal)

                // Form content
                Form {
                    Section {
                        Picker("Grade", selection: $viewModel.formAnswers.grade) {
                            Text("Grade 9").tag("Grade 9")
                            Text("Grade 10").tag("Grade 10")
                            Text("Grade 11").tag("Grade 11")
                            Text("Grade 12").tag("Grade 12")
                        }
                        Picker("Subject", selection: $viewModel.formAnswers.subject) {
                            Text("Math").tag("Math")
                            Text("Social Studies").tag("Social Studies")
                            Text("Science").tag("Science")
                            Text("English").tag("English")
                            Text("Business").tag("Business")
                            Text("World Language").tag("World Language")
                            Text("Art").tag("Art")
                            Text("Electives").tag("Electives")
                        }
                        Picker("Level", selection: $viewModel.formAnswers.level) {
                            Text("Regular").tag("Regular")
                            Text("Honors").tag("Honors")
                            Text("AP").tag("AP")
                            Text("CIS").tag("CIS")
                        }
                        Button(action: {
                            viewModel.showCourses()
                            showSavedMessage = true // Set the state variable to show the saved message
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSavedMessage = false // Hide the message after 2 seconds
                            }
                        }) {
                            Text("Show Courses")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                Text("Course List")
                    .font(.title)
                    .padding()

                List(viewModel.getSelectedCourses()) { course in
                    
                    VStack(alignment: .leading) {
                        Text(course.name)
                            .font(.headline)
                            .padding(.horizontal, 40)
                        HStack(alignment: .center) {
                            Button(action: {
                                courseName = course.name
                                courseEdit()
                                viewModel.showCourses()
                            }) {
                                Text("Edit")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .frame(width: screenWidth/2, height: 20, alignment: .center)
                            .background(Color.blue)
                            .buttonStyle(.plain)

                            Button(action: {
                                courseToDelete = course
                                showDeleteAlert = true
                            }) {
                                Text("Delete")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .frame(width: screenWidth/2, height: 20, alignment: .center)
                            .background(Color.red)
                            .buttonStyle(.plain)
                        }
                    }
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Delete Course"),
                        message: Text("Are you sure you want to delete this course: \(courseToDelete?.name ?? "")?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let courseToDelete = courseToDelete {
                                courseName = courseToDelete.name
                                courseId = courseToDelete.id
                                courseDelete()
                                viewModel.showCourses()
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }

                Spacer()

                // Add Course button
                Button(action: courseAdd) {
                    Text("Add Course")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                }

                // Navigation link for Student Courses
                NavigationLink(destination: StudentListView().navigationBarBackButtonHidden(true), isActive: $navigateStudentCourses) {
                    EmptyView()
                }

                NavigationLink(destination: AddCourseView(email: email).navigationBarBackButtonHidden(true), isActive: $navigateAdd) {
                    EmptyView()
                }
                NavigationLink(destination: EditCourseView(email: email, courseName: courseName).navigationBarBackButtonHidden(true), isActive: $navigateEdit) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }

    func courseEdit() {
        navigateEdit.toggle()
    }

    func courseDelete() {
        db.collection("Courses").document(courseName).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        Task {
            do {
                let querySnapshot = try await db.collection("CourseDetail")
                    .whereField("Course Id", isEqualTo: courseId)
                    .getDocuments()
                for document in querySnapshot.documents {
                    try await document.reference.delete()
                }
            } catch {
                print("Error getting documents: \(error)")
            }
        }
    }

    func courseAdd() {
        navigateAdd.toggle()
    }
}


struct AdminCoursesView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSelectionView1(email: "")
    }
}




