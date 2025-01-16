import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore

struct DetailView: View {
    var email: String
    var courseId: String
    var courseName: String
    var db = Firestore.firestore()
    @State var units: [Unit1A] = []
    @State private var navigateBack = false
    @State var dataLoaded = false
    @State var prereqs: [String] = []

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink(destination: CourseDetailsView(email: email).navigationBarBackButtonHidden(true)) {
                    Text("< Back")
                        .foregroundColor(.blue)
                        .padding()
                }

                Text("Course Details")
                    .foregroundColor(.red)
                    .font(.title)
                    .padding(.horizontal, 80)

                VStack(alignment: .leading, spacing: 8) {
                    Text("    Prerequisites")
                        .font(.headline)
                    Text("    " + prereqs.joined(separator: ", "))
                }

                ScrollView {
                    ForEach(units.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unit: \(index + 1)")
                                .font(.headline)

                            Text("\(units[index].title)")
                                .font(.body)

                            // Display the URL text and make it clickable
                            if !units[index].link.isEmpty {
                                Button(action: {
                                    openURL(units[index].link)
                                }) {
                                    Text(units[index].link)
                                        .foregroundColor(.blue) // Make the URL text blue to indicate it's clickable
                                }
                            }

                            Text("\(units[index].description)")
                                .font(.body)
                                .padding(.vertical, 4)

                            Divider()
                        }
                        .padding(.horizontal)
                    }
                }
                .onAppear {
                    self.getUnits()
                }

                NavigationLink(destination: CourseDetailsView(email: email).navigationBarBackButtonHidden(true), isActive: $navigateBack) {
                    EmptyView()
                }
            }
        }
    }

    func getUnits() {
        Task {
            do {
                let querySnapshot = try await db.collection("CourseDetail")
                    .whereField("Course Id", isEqualTo: courseId)
                    .getDocuments()
                for document in querySnapshot.documents {
                    units.append(Unit1A(
                        title: document.data()["Title"] as? String ?? "No Title",
                        link: document.data()["Link"] as? String ?? "",
                        description: document.data()["Description"] as? String ?? "No Description"
                    ))
                }
            } catch {
                print("Error getting documents: \(error)")
            }

            let docRef = db.collection("Courses").document(courseName)
            do {
                let document = try await docRef.getDocument()
                if document.exists {
                    prereqs = document.data()?["Prereq"] as? [String] ?? []
                    print(prereqs)
                } else {
                    print("Document does not exist")
                }
            } catch {
                print("Error getting document: \(error)")
            }
        }
    }

    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    print("Failed to open URL: \(urlString)")
                }
            }
        } else {
            print("Cannot open URL: \(urlString)")
        }
    }
}

struct Unit1A {
    var title: String
    var link: String
    var description: String
}

#Preview {
    DetailView(email: "Test3@gmail.com", courseId: "36C48D95-E0EA-4784-9A67-AC02F78292AC", courseName: "Math 10")
}
