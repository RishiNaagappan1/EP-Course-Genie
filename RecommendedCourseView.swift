import SwiftUI

struct RecommendedCourseView: View {
    // Course data for each grid based on the provided images
    let freshmanCourses = [
            "English", "English", "Social Studies", "Social Studies",
            "Math", "Math", "Science", "Science",
            "World Language(not required)", "World Language(not required)", "Arts Credit(can be taken in a different year)", "Arts Credit(can be taken in a different year)",
            "PE(can be taken in a different year)", "Tech Credit", "Elective", "Elective"
        ]
        
        let sophomoreCourses = [
            "English", "English", "Social Studies", "Social Studies",
            "Math", "Math", "Science", "Science",
            "World Language(not required)", "World Language(not required)", "Health(can be taken in a different year)", "Business Credit(can be taken in a different year)",
            "PE(can be taken in a different year)", "Elective", "Elective", "Elective"
        ]
    
    let juniorCourses = [
        "English", "English", "Social Studies", "Social Studies",
        "Math", "Math", "Science", "Science",
        "Elective", "Elective", "Elective", "Elective",
        "Elective", "Elective", "Elective", "Elective"
    ]
    
    let seniorCourses = [
        "English", "English", "Social Studies", "Social Studies",
        "Elective", "Elective", "Elective", "Elective",
        "Elective", "Elective", "Elective", "Elective",
        "Elective", "Elective", "Elective", "Elective"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header for the entire view
                    Text("Recommended Course Plan")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.red)
                        .padding(.top, 20)
                        .padding(.leading, 10)
                    
                    // Freshman Year Grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Freshman Year")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color.blue)
                        createCourseGrid(courses: freshmanCourses)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)

                    // Sophomore Year Grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sophomore Year")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color.blue)
                        createCourseGrid(courses: sophomoreCourses)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)

                    // Junior Year Grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Junior Year")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color.blue)
                        createCourseGrid(courses: juniorCourses)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)

                    // Senior Year Grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Senior Year")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color.blue)
                        createCourseGrid(courses: seniorCourses)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)

                    // Back button
                    NavigationLink(destination: CourseDetailsView(email: "").navigationBarBackButtonHidden(true)) {
                        Text("Course Details")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
    }
    
    // Function to create the course grid in horizontal order
    private func createCourseGrid(courses: [String]) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<4) { row in
                HStack(spacing: 0) {
                    ForEach(0..<4) { column in
                        let index = row * 4 + column  // This arranges courses in horizontal order
                        if index < courses.count {
                            Text(courses[index])
                                .font(.footnote)
                                .fontWeight(.bold)
                                .frame(width: 80, height: 50, alignment: .center)
                                .background(Color(.systemGray5))
                                .foregroundColor(.black)
                                .border(Color.gray, width: 1)
                        }
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    RecommendedCourseView()
}
