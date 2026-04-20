//
//  SettingsView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//

import SwiftUI
import UIKit
import FirebaseFirestore
import FirebaseStorage

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var schoolInfo = ""
    @State private var major = ""
    @State private var secondMajor = ""

    @State private var personalEmail = ""
    @State private var schoolEmail = ""
    @State private var phone = ""

    @State private var showPersonalEmail = true
    @State private var showSchoolEmail = true
    @State private var showPhone = true

    @State private var validationMessage = ""
    
    @State private var showImageSourceActionSheet = false
    @State private var showImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImageData: Data? = nil
    @State private var selectedUIImage: UIImage? = nil
    
    let database = Firestore.firestore()
    let storage = Storage.storage()

    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            if let user = appState.currentUser {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        //Profile photo area
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Profile Photo")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            HStack(spacing: 16) {
                                Group {
                                    if let picked = selectedUIImage {
                                        Image(uiImage: picked)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        AsyncImage(url: URL(string: user.imageName)) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                }
                                .frame(width: 90, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                                Button(action: {
                                    showImageSourceActionSheet = true
                                }) {
                                    Text("Change Profile Photo")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(Color.white.opacity(0.12))
                                        .cornerRadius(8)
                                }
                                .confirmationDialog("Choose Photo", isPresented: $showImageSourceActionSheet, titleVisibility: .visible) {
                                    Button("Take Photo") {
                                        imageSourceType = .camera
                                        showImagePicker = true
                                    }
                                    Button("Choose from Library") {
                                        imageSourceType = .photoLibrary
                                        showImagePicker = true
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
                                .sheet(isPresented: $showImagePicker) {
                                    ImagePickerView(sourceType: imageSourceType) { image in
                                        
                                        selectedUIImage = image
                                        
                                        selectedImageData = image.jpegData(compressionQuality: 0.8)
                                        
                                        let profilePictureReference = storage.reference().child("\(appState.currentUser!.username)_PFP.jpg")
                                        
                                        profilePictureReference.putData(selectedImageData!) { _, error in
                                        
                                            if let error = error {
                                                print("There was an error uploading the profile picture:", error)
                                                return
                                            }
                                            
                                            profilePictureReference.downloadURL() { url, error in
                                                
                                                if let error = error {
                                                    print("There was an error getting the URL:", error)
                                                    return
                                                }
                                                
                                                database
                                                    .collection("Users")
                                                    .whereField("username", isEqualTo: appState.currentUser!.username)
                                                    .getDocuments { (querySnapshot, error) in
                                                        
                                                        if let error = error {
                                                            print("There was an error getting the users:", error)
                                                            return
                                                        }
                                                        
                                                        let documentID = database.collection("users").document(querySnapshot!.documents.first!.documentID)
                                                        
                                                        documentID.updateData(["imageName": url!.absoluteString])
                                                        
                                                        guard var user = appState.currentUser else {
                                                            return
                                                        }
                                                        
                                                        user.imageName = url!.absoluteString
                                                        
                                                        appState.updateUser(user)
                                                        
                                                    }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                            }
                        }

                        //Profile info
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Profile Info")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            SettingsInputField(
                                title: "Name",
                                text: $name,
                                keyboardType: UIKeyboardType.default
                            )
                            
                            SettingsInputField(
                                title: "School Info",
                                text: $schoolInfo,
                                keyboardType: UIKeyboardType.default
                            )
                            
                            //major field
                            SettingsInputField(
                                title: "Major",
                                text: $major,
                                keyboardType: UIKeyboardType.default
                            )
                            
                            //second major(set to be optional)
                            SettingsInputField(
                                title: "Second Major",
                                text: $secondMajor,
                                keyboardType: UIKeyboardType.default
                            )
                        }
    

                        //Edit contact info
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Edit Contact Info")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            SettingsInputField(
                                title: "Personal Email",
                                text: $personalEmail,
                                keyboardType: UIKeyboardType.emailAddress
                            )

                            SettingsInputField(
                                title: "School Email",
                                text: $schoolEmail,
                                keyboardType: UIKeyboardType.emailAddress
                            )

                            SettingsInputField(
                                title: "Phone Number",
                                text: $phone,
                                keyboardType: UIKeyboardType.phonePad
                            )
                        }

                        //Privacy settings
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Privacy Settings")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            SettingsToggleRow(
                                title: "Show Personal Email",
                                isOn: $showPersonalEmail
                            )

                            SettingsToggleRow(
                                title: "Show School Email",
                                isOn: $showSchoolEmail
                            )

                            SettingsToggleRow(
                                title: "Show Phone Number",
                                isOn: $showPhone
                            )
                        }

                        //Validation message
                        if !validationMessage.isEmpty {
                            Text(validationMessage)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.red)
                        }

                        //Save button
                        Button(action: {
                            saveSettings()
                        }) {
                            Text("Save Changes")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }

                        //Logout button
                        Button(action: {
                            appState.logout()
                            dismiss()
                        }) {
                            Text("Logout")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }
                .onAppear {
                    name = user.name
                    schoolInfo = user.schoolInfo
                    major = user.major
                    secondMajor = user.secondMajor
                    personalEmail = user.personalEmail
                    schoolEmail = user.schoolEmail
                    phone = user.phone
                    showPersonalEmail = user.showPersonalEmail
                    showSchoolEmail = user.showSchoolEmail
                    showPhone = user.showPhone
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    
    func saveSettings() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMajor = major.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSecondMajor = secondMajor.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPersonalEmail = personalEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSchoolEmail = schoolEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            validationMessage = "Name cannot be empty."
            return
        }

        
        if trimmedMajor.isEmpty {
                    validationMessage = "Major cannot be empty."
                    return
                }
        
        if !trimmedPersonalEmail.isEmpty && !isValidEmail(trimmedPersonalEmail) {
            validationMessage = "Please enter a valid personal email."
            return
        }

        if !trimmedSchoolEmail.isEmpty && !isValidEmail(trimmedSchoolEmail) {
            validationMessage = "Please enter a valid school email."
            return
        }

        if !trimmedPhone.isEmpty && !isValidPhone(trimmedPhone) {
            validationMessage = "Please enter a valid phone number."
            return
        }

        if !showPersonalEmail && !showSchoolEmail && !showPhone {
            validationMessage = "Please leave at least one contact item visible."
            return
        }

        guard var user = appState.currentUser else {
            return
        }
        
        database
            .collection("Users")
            .whereField("username", isEqualTo: appState.currentUser!.username)
            .getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    print("There was an error getting the users:", error)
                    return
                }
                
                let documentID = database.collection("Users").document(querySnapshot!.documents.first!.documentID)
                
                documentID.updateData([
                    "name": name,
                    "schoolInfo": schoolInfo,
                    "major": major,
                    "secondMajor": secondMajor,
                    "personalEmail": personalEmail,
                    "schoolEmail": schoolEmail,
                    "phone": phone,
                    "showPersonalEmail": showPersonalEmail,
                    "showSchoolEmail": showSchoolEmail,
                    "showPhone": showPhone
                ])
                
            }
        
        //updating user info
        user.name = trimmedName
        user.major = trimmedMajor
        user.secondMajor = trimmedSecondMajor
        user.personalEmail = trimmedPersonalEmail
        user.schoolEmail = trimmedSchoolEmail
        user.phone = trimmedPhone

        user.showPersonalEmail = showPersonalEmail
        user.showSchoolEmail = showSchoolEmail
        user.showPhone = showPhone

        validationMessage = ""
        appState.updateUser(user)
        dismiss()
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailPattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailPattern, options: .regularExpression) != nil
    }

    func isValidPhone(_ phone: String) -> Bool {
        let digitsOnly = phone.filter { $0.isNumber }
        return digitsOnly.count >= 10
    }
}



struct SettingsInputField: View {
    let title: String
    @Binding var text: String
    let keyboardType: UIKeyboardType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            TextField("", text: $text)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .frame(height: 42)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
                )
                .textInputAutocapitalization(.never)
                .keyboardType(keyboardType)
        }
    }
}



struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageSelected: (UIImage) -> Void

        init(onImageSelected: @escaping (UIImage) -> Void) {
            self.onImageSelected = onImageSelected
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = (info[.editedImage] ?? info[.originalImage]) as! UIImage
            onImageSelected(image)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
