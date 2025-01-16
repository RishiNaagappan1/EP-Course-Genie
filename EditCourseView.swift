
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

struct EditCourseView: View {
    var email: String
    var db = Firestore.firestore()
    var courseName: String
    @State var units: [Unit1] = []
    @State var courseNewName = ""
    @State var level = "Regular"
    @State var subject = "Math"
    @State var credits = 0
    @State var grade9 = false
    @State var grade10 = false
    @State var grade11 = false
    @State var grade12 = false
    @State var grades:[String] = []
    @State var navigateBack = false
    @State var courseId = ""
    @State var newPre = ""
    @State var prereq: [String] = []
    @State var prereqId: [String] = []
    @State var error = ""
    @State var showAlert = false
    var leveloptions = ["Regular", "Honors","AP", "CIS"]
    var subjects = ["Math", "English", "Social Studies", "Science", "Electives","Foreign Language", "Business", "Art", "FACS", "Health and Physical Education"]
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                NavigationLink(destination: CourseSelectionView1(email: email).navigationBarBackButtonHidden(true)) {
                    Text("< Back")
                        .foregroundColor(.blue)
                        .padding()
                }
                .onAppear(){
                    initField()
                }
                Text("Admin Course Edit")
                    .foregroundColor(.red)
                    .font(.title)
                    .padding(.horizontal, 80)
                Text("Course Name")
                    .padding()
                TextField("", text: $courseNewName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Stepper("Credits: \(credits)", value: $credits, in: 0...4)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack{
                    Text("Level : ")
                        .padding()
                    Picker("Level", selection: $level){
                        ForEach(leveloptions, id: \.self){
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 80)
                }
                HStack{
                    Text("Subject : ")
                        .padding()
                    Picker("Subject", selection: $subject){
                        ForEach(subjects, id: \.self){
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 60)
                }
                Text("Grade : ")
                    .padding()
                HStack{
                    Toggle(isOn: $grade9){
                        Text("9")
                            .padding(.horizontal, 50)
                            .toggleStyle(.button)
                    }
                    Toggle(isOn: $grade10){
                        Text("10")
                            .padding(.horizontal, 50)
                            .toggleStyle(.button)
                    }
                }
                HStack{
                    Toggle(isOn: $grade11){
                        Text("11")
                            .padding(.horizontal, 50)
                            .toggleStyle(.button)
                    }
                    Toggle(isOn: $grade12){
                        Text("12")
                            .padding(.horizontal, 50)
                            .toggleStyle(.button)
                    }
                }
                Text("Prerequisites : ")
                    .padding()
                HStack {
                            TextField("Add Prerequisites", text: $newPre, onCommit: {
                                addPre()
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    addPre()
                                }
                        }
                        .onChange(of: newPre, perform: { value in
                            if value.contains(",") {
                                newPre = value.replacingOccurrences(of: ",", with: "")
                                addPre()
                            }
                        })
                Text(prereq.joined(separator: ","))
                Button(action: resetPre) {
                    Text("Reset Prerequisites")
                        .padding()
                }
                Button(action: addC) {
                    Text("Edit Units")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .bold()
                }
                .padding()
                NavigationLink(destination: EditUnitView(email: email, courseId: courseId, units: units).navigationBarBackButtonHidden(true), isActive: $navigateBack) {
                    EmptyView()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
                }
                
            }
        }
    }
    func resetPre(){
        prereq = []
        prereqId = []
    }
    func initField(){
        courseNewName = courseName
        Task{
            do{
                let document = try await db.collection("Courses").document(courseName).getDocument()
                courseId = document.data()!["id"] as! String
                getUnits()
                print(units)
                level = document.data()!["Level"] as! String
                subject = document.data()!["Subject"] as! String
                grades = document.data()!["Grades"] as! [String]
                if grades.contains("Grade 9")
                {
                    grade9 = true
                }
                if grades.contains("Grade 10")
                {
                    grade10 = true
                }
                if grades.contains("Grade 11")
                {
                    grade11 = true
                }
                if grades.contains("Grade 12")
                {
                    grade12 = true
                }
                credits = document.data()!["Credits"] as! Int
                prereq = document.data()!["Prereq"] as! [String]
            }
        }
    }
    func addPre(){
        Task{
            do {
                let querySnapshot = try await db.collection("Courses")
                    .whereField("Name", isEqualTo: newPre)                .getDocuments()
                if querySnapshot.isEmpty {
                    error = "Such a course doesn't exist"
                    showAlert.toggle()
                }
                else{
                    prereq.append(newPre)
                    prereq = Array(Set(prereq))
                    for document in querySnapshot.documents{
                        prereqId.append(document.data()["id"] as! String)
                        prereqId = Array(Set(prereqId))
                    }
                    newPre = ""
                }
            }
        }
    }
    func courseDelete(){
        db.collection("Courses").document(courseName).delete(){ err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        Task{
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
    func addC(){
        courseDelete()  // Delete old course details from Firestore
        Task {
            do {
                // Check if the course already exists
                let querySnapshot = try await db.collection("Courses")
                    .whereField("Name", isEqualTo: courseNewName)  // Use the new course name
                    .getDocuments()
                
                if querySnapshot.isEmpty {
                    grades = []
                    if(grade9 || grade10 || grade11 || grade12){
                        if(courseNewName.count > 0){
                            // Assign grades based on toggle selections
                            if(grade9){ grades.append("Grade 9") }
                            if(grade10){ grades.append("Grade 10") }
                            if(grade11){ grades.append("Grade 11") }
                            if(grade12){ grades.append("Grade 12") }

                            // Generate a new ID for the course
                            let id = UUID().description
                            courseId = id

                            // Save the edited course details into Firestore
                            try await db.collection("Courses").document(courseNewName).setData([
                                "id": id,
                                "Name": courseNewName,  // Save the new course name
                                "Level": level,
                                "Subject": subject,
                                "Credits": credits,
                                "Grades": grades,
                                "Prereq": prereq
                            ])
                            navigateBack.toggle()  // Trigger navigation back
                        } else {
                            print("Course Name too small")
                        }
                    } else {
                        print("Select at least one grade")
                    }
                } else {
                    error = "Course Name already exists"
                    showAlert.toggle()
                }
            } catch {
                print("Error saving course: \(error)")
            }
        }
    }
    func getUnits() {
        Task{
            do {
                let querySnapshot = try await db.collection("CourseDetail")
                    .whereField("Course Id", isEqualTo: courseId)
                    .getDocuments()
                for document in querySnapshot.documents {
                    units.append(contentsOf: [
                        Unit1(title: document.data()["Title"] as! String,
                              link: document.data()["Link"] as! String,
                              description: document.data()["Description"] as! String
                             )
                    ])
                }
            } catch {
                print("Error getting documents: \(error)")
            }
        }
    }
}

#Preview {
    EditCourseView(email: "", courseName: "English 11")
}
