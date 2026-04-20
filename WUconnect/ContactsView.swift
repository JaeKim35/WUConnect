//
//  ContactsView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//

import SwiftUI
import AVFoundation
import FirebaseFirestore

struct ContactsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var contactsStore: ContactsStore
    
    @State private var searchText = ""
    @State private var showCreateGroupSheet = false
    @State private var newGroupName = ""
    
    @State private var showQRScanner = false
    @State private var scannedUsername: String? = nil
    
    let database = Firestore.firestore()

    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //Top title area
                Text("Contacts")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )
                    .padding(.top, 24)
                
                Spacer().frame(height: 22)
                
                //Search + create group area
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Find", text: $searchText)
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 36)
                    .background(Color.black.opacity(0.25))
                    .cornerRadius(8)
                    
                    Button(action: {
                        showCreateGroupSheet = true
                    }) {
                        Text("Create Group")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .frame(height: 36)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }
                    Button(action: {
                        showQRScanner = true
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        //Groups section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Groups")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            if filteredGroups.isEmpty {
                                Text("No matching groups")
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                                    .cornerRadius(16)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(filteredGroups) { group in
                                        NavigationLink(
                                            destination: GroupDetailView(groupId: group.id)
                                        ) {
                                            GroupRow(group: group)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        if group.id != filteredGroups.last?.id {
                                            Divider()
                                                .background(Color.white.opacity(0.15))
                                                .padding(.horizontal, 14)
                                        }
                                    }
                                }
                                .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                                .cornerRadius(16)
                            }
                        }
                        
                        //All contacts section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Contacts")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            if filteredAllContacts.isEmpty {
                                Text("No matching contacts")
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                                    .cornerRadius(16)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(filteredAllContacts) { contact in
                                        ContactRow(contact: contact)
                                        
                                        if contact.id != filteredAllContacts.last?.id {
                                            Divider()
                                                .background(Color.white.opacity(0.15))
                                                .padding(.horizontal, 14)
                                        }
                                    }
                                }
                                .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 6)
                }
                
                Spacer()
                
                //Bottom buttons
                HStack {
                    profileButton
                    
                    Spacer()
                    
                    NavigationLink(destination: CalendarView()) {
                        Text("Calendar")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .onAppear {
                
                if let user = appState.currentUser {
                    
                    database
                        .collection("Contacts")
                        .whereField("username", isEqualTo: user.username)
                        .limit(to: 1)
                        .getDocuments { (querySnapshot, error) in
                            
                            if let error = error {
                                print("There was an error getting the users:", error)
                                return
                            }
                            
                            guard let querySnapshot = querySnapshot,
                                  let document = querySnapshot.documents.first else {
                                return
                            }
                            
                            var newContacts = [] as [Contact]
                            
                            if let contactsFetched = document.data()["contacts"] as? [[String: String]] {
                                for contact in contactsFetched {
                                    guard let username = contact["username"],
                                          let name = contact["name"] else {
                                        return
                                    }
                                    newContacts.append(Contact(username: username, name: name))
                                }
                            }
                            
                            contactsStore.allContacts = newContacts
                            
                        }
                    
                    database
                        .collection("ContactGroups")
                        .whereField("username", isEqualTo: user.username)
                        .getDocuments { (querySnapshot, error) in
                            
                            if let error = error {
                                print("There was an error getting the users:", error)
                                return
                            }
                            
                            guard let querySnapshot = querySnapshot else {
                                return
                            }
                            
                            var newContactGroups = [] as [ContactGroup]
                            
                            for contactGroupFetched in querySnapshot.documents {
                                
                                let groupData = contactGroupFetched.data()
                                
                                guard let groupName = groupData["name"] as? String,
                                      let groupContacts = groupData["contacts"] as? [[String: Any]] else {
                                    continue
                                    }
                                
                                var newContactGroup = ContactGroup(name: groupName, contacts: [])
                                
                                for contact in groupContacts {
                                    guard let username = contact["username"] as? String,
                                          let name = contact["name"] as? String else {
                                        continue
                                    }
                                    newContactGroup.contacts.append(Contact(username: username, name: name))
                                }
                                
                                newContactGroups.append(newContactGroup)
                                
                            }
                            
                            contactsStore.contactGroups = newContactGroups
                            
                        }
                    
                    
                }
                
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showCreateGroupSheet) {
            CreateGroupSheet(
                groupName: $newGroupName,
                onSave: {
                    createGroup()
                }
            )
        }
        .sheet(isPresented: $showQRScanner) {
            QRScannerView { username in
                scannedUsername = username
                showQRScanner = false
                // TODO: use scannedUsername to look up and add contact
                print("Scanned username: \(username)")
            }
        }
    }
    
    
    @ViewBuilder
    var profileButton: some View {
        if appState.currentUser != nil {
            NavigationLink(destination: ProfileView()) {
                Text("Profile")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(8)
            }
        } else {
            EmptyView()
        }
    }
    
    
    //search text
    var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    //filter groups by group name
    var filteredGroups: [ContactGroup] {
        if trimmedSearchText.isEmpty {
            return contactsStore.contactGroups
        }
        
        let lowercasedSearch = trimmedSearchText.lowercased()
        
        return contactsStore.contactGroups.filter { group in
            group.name.lowercased().contains(lowercasedSearch)
        }
    }
    
    //filtering all contacts section by name
    var filteredAllContacts: [Contact] {
        if trimmedSearchText.isEmpty {
            return contactsStore.allContacts
        }
        
        let lowercasedSearch = trimmedSearchText.lowercased()
        
        return contactsStore.allContacts.filter { contact in
            contact.name.lowercased().contains(lowercasedSearch)
        }
    }
    
    
    //Create a new group
    func createGroup() {
        contactsStore.createGroup(name: newGroupName)
        newGroupName = ""
        showCreateGroupSheet = false
    }
    
}


//Row used for groups on the main contacts page
struct GroupRow: View {
    let group: ContactGroup
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(group.name)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                
                Text("\(group.contacts.count) member\(group.contacts.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.75))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}


struct ContactRow: View {
    let contact: Contact

    var body: some View {
        NavigationLink(destination: ContactDetailView(contact: contact)) {
            Text(contact.name)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}


//creating a new group
struct CreateGroupSheet: View {
    @Binding var groupName: String
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Group Info")) {
                    TextField("Group Name", text: $groupName)
                }
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
        }
    }
}

struct QRScannerView: UIViewControllerRepresentable {
    let onUsernameScanned: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onUsernameScanned: onUsernameScanned)
    }

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onUsernameScanned: (String) -> Void
        private var hasScanned = false

        init(onUsernameScanned: @escaping (String) -> Void) {
            self.onUsernameScanned = onUsernameScanned
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard !hasScanned,
                  let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  metadata.type == .qr,
                  let scannedValue = metadata.stringValue else { return }

            hasScanned = true
            DispatchQueue.main.async {
                self.onUsernameScanned(scannedValue)
            }
        }
    }
}


class ScannerViewController: UIViewController {
    var delegate: AVCaptureMetadataOutputObjectsDelegate?

    private var captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            showCameraUnavailableLabel()
            return
        }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else { return }
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]

        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        self.previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func showCameraUnavailableLabel() {
        let label = UILabel()
        label.text = "Camera unavailable"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

struct ContactsView_PreviewWrapper: View {
    @StateObject private var appState = AppState()
    @StateObject private var contactsStore = ContactsStore()

    var body: some View {
        NavigationStack {
            ContactsView()
                .environmentObject(appState)
                .environmentObject(contactsStore)
        }
        .onAppear {
            appState.currentUser = User(
                username: "Edgar",
                name: "Dog Dog",
                schoolInfo: "WashU - Senior",
                major: "Computer Science",
                secondMajor: "",
                personalEmail: "aaaaaaa@gmail.com",
                schoolEmail: "aaaaaaa@wustl.edu",
                phone: "999-999-9999",
                imageName: "dogProfile",
                qrName: "sampleQR",
                showPersonalEmail: true,
                showSchoolEmail: true,
                showPhone: true
            )
        }
    }
}

#Preview {
    ContactsView_PreviewWrapper()
}
