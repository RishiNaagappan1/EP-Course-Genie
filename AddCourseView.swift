//
//  SwiftUIView.swift
//  EPHS Course Genie
//
//  Created by 64014111 on 5/18/24.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore

struct AddCourseView: View {
    var email: String
    var db = Firestore.firestore()
    @State var courseName = ""
    @State var level = " "
    @State var subject = "Maths"
    @State var credits = 0
    @State var grade9 = false
    @State var grade10 = false
    @State var grade11 = false
    @State var grade12 = false
    @State var grades: [String] = []
    @State var navigateBack = false
    @State var courseId = ""
    @State var newPre = ""
    @State var prereq: [String] = []
    @State var prereqId: [String] = []
    @State var error = ""
    @State var showAlert = false
    var leveloptions = ["Regular", "Honors", "AP", "CIS"]
    var subjects = ["Math", "English", "Social Studies", "Science", "Electives", "Business", "World Language", "Art", "FACS", "Health and Physical Education"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    NavigationLink(destination: CourseSelectionView1(email: email).navigationBarBackButtonHidden(true)) {
                        Text("< Back")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    
                    Text("Admin Course Addition")
                        .foregroundColor(.red)
                        .font(.title)
                        .padding(.horizontal, 50)
                    
                    Text("Course Name")
                        .padding()
                    TextField("", text: $courseName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Stepper("Credits: \(credits)", value: $credits, in: 0...4)
                        .padding()
                    
                    HStack {
                        Text("Level : ")
                            .padding()
                        Picker("Level", selection: $level) {
                            ForEach(leveloptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 80)
                    }
                    
                    HStack {
                        Text("Subject : ")
                            .padding()
                        Picker("Subject", selection: $subject) {
                            ForEach(subjects, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 60)
                    }
                    
                    Text("Grade : ")
                        .padding()
                    
                    HStack {
                        Toggle(isOn: $grade9) { Text("9").padding() }
                        Toggle(isOn: $grade10) { Text("10").padding() }
                    }
                    
                    HStack {
                        Toggle(isOn: $grade11) { Text("11").padding() }
                        Toggle(isOn: $grade12) { Text("12").padding() }
                    }
                    
                    Text("Prerequisites : ")
                        .padding()
                    
                    HStack {
                        TextField("Add Prerequisites", text: $newPre, onCommit: { addPre() })
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                            .onTapGesture { addPre() }
                    }
                    Text(prereq.joined(separator: ","))
                    
                    Button(action: resetPre) {
                        Text("Reset Prerequisites")
                            .padding()
                    }
                    
                    Button(action: addC) {
                        Text("Add Units")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                            .bold()
                    }
                    .padding()
                    
                    NavigationLink(destination: AddUnitView(email: email, courseId: courseId).navigationBarBackButtonHidden(true), isActive: $navigateBack) {
                        EmptyView()
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
    }
    
    func resetPre() {
        prereq = []
        prereqId = []
    }
    
    func addPre() {
        Task {
            do {
                let querySnapshot = try await db.collection("Courses")
                    .whereField("Name", isEqualTo: newPre)
                    .getDocuments()
                if querySnapshot.isEmpty {
                    error = "Such a course doesn't exist"
                    showAlert.toggle()
                } else {
                    prereq.append(newPre)
                    prereq = Array(Set(prereq))
                    for document in querySnapshot.documents {
                        prereqId.append(document.data()["id"] as! String)
                        prereqId = Array(Set(prereqId))
                    }
                    newPre = ""
                }
            }
        }
    }
    
    func addC() {
        Task {
            do {
                let querySnapshot = try await db.collection("Courses")
                    .whereField("Name", isEqualTo: courseName)
                    .getDocuments()
                if querySnapshot.isEmpty {
                    if grade9 || grade10 || grade11 || grade12 {
                        if courseName.count > 0 {
                            if grade9 { grades.append("Grade 9") }
                            if grade10 { grades.append("Grade 10") }
                            if grade11 { grades.append("Grade 11") }
                            if grade12 { grades.append("Grade 12") }
                            let coursesRef = db.collection("Courses")
                            let id = UUID().description
                            print(id)
                            courseId = id
                            try await coursesRef.document(courseName).setData([
                                "id": id,
                                "Name": courseName,
                                "Level": level,
                                "Subject": subject,
                                "Credits": credits,
                                "Grades": grades,
                                "Prereq": prereq
                            ])
                            
                            // Notify parent view to refresh
                            NotificationCenter.default.post(name: .courseAdded, object: nil)
                            navigateBack.toggle()
                        } else {
                            print("Course Name too small")
                        }
                    } else {
                        print("Select at least one grade")
                    }
                } else {
                    error = "Course already exists"
                    showAlert.toggle()
                }
            }
        }
    }
}

extension Notification.Name {
    static let courseAdded = Notification.Name("courseAdded")
}


#Preview {
    AddCourseView(email: "")
}
