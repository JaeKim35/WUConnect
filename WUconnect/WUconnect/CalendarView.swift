//
//  CalendarView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//

import SwiftUI
import UIKit
import FirebaseFirestore

struct CalendarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var contactsStore: ContactsStore
    
    @State private var selectedDates: Set<DateComponents>
    @State private var schedules: [ScheduleDay]

    @State private var showAddScheduleSheet = false
    @State private var newScheduleTitle = ""
    @State private var newScheduleDate = Date()
    @State private var newScheduleTime = Date()
    @State private var lastTappedDate: Date? = nil
    
    @State private var showShareToContactSheet = false
    
    let database = Firestore.firestore()

    init() {
        _schedules = State(initialValue: [])
        _selectedDates = State(initialValue: [])
    }
    
    
    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                //Top title area
                Text("Schedules")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )
                    .padding(.top, 24)

                Spacer().frame(height: 20)

                //Share button area
                HStack {
                    Spacer()

                    Button(action: {
                        showShareToContactSheet = true
                    }) {
                        Text("Share Schedule")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }
                    .disabled(filteredSchedules.isEmpty || contactsStore.allContacts.isEmpty)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 16)

                //Calendar area
                VStack(spacing: 0) {
                    MultiDatePicker("Select Dates", selection: $selectedDates)
                        .padding()
                        .tint(.yellow)
                        .background(Color(red: 0.20, green: 0.19, blue: 0.23))
                        .cornerRadius(12)
                        .labelsHidden()
                        .onChange(of: selectedDates) { oldValue, newValue in
                            updateLastTappedDate(from: oldValue, to: newValue)
                        }

                    HStack {
                        NavigationLink(
                            destination: AllSchedules(
                                schedules: $schedules,
                                selectedDates: $selectedDates,
                                onSchedulesChanged: {
                                    syncOwnEventsToFirebase()
                                }
                            )
                        ) {
                            Text("All Schedules")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 140, height: 40)
                                .background(Color.gray)
                                .cornerRadius(6)
                        }

                        Spacer()

                        Button(action: {
                            prepareAddSchedule()
                            showAddScheduleSheet = true
                        }) {
                            Text("Add Schedule")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 140, height: 40)
                                .background(Color.blue)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.top, 14)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 26)

                //Schedules title
                HStack {
                    Text("Schedules")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 18)

                //Schedule list
                ScrollView {
                    ScheduleListView(
                        schedules: filteredSchedules,
                        emptyMessage: "No schedules for selected date(s)",
                        onSave: { dayId, itemId, updatedDate, updatedTime, updatedTitle in
                            ScheduleHelper.updateScheduleItem(
                                schedules: &schedules,
                                selectedDates: &selectedDates,
                                dayId: dayId,
                                itemId: itemId,
                                newDate: updatedDate,
                                newTime: updatedTime,
                                newTitle: updatedTitle
                            )
                            
                            syncOwnEventsToFirebase()
                        },
                        onDelete: { dayId, itemId in
                            ScheduleHelper.deleteScheduleItem(
                                schedules: &schedules,
                                selectedDates: &selectedDates,
                                dayId: dayId,
                                itemId: itemId
                            )
                            
                            syncOwnEventsToFirebase()
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                //Bottom buttons
                HStack {
                    profileButton

                    Spacer()

                    NavigationLink(destination: ContactsView()) {
                        Text("Contacts")
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
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadContactsForShare()
            loadEventsFromFirebase()
        }
        .sheet(isPresented: $showAddScheduleSheet) {
            AddScheduleSheet(
                title: $newScheduleTitle,
                selectedDate: $newScheduleDate,
                selectedTime: $newScheduleTime,
                onSave: {
                    addSchedule()
                }
            )
        }
        .sheet(isPresented: $showShareToContactSheet) {
            ShareToContactSheet(
                contacts: contactsStore.allContacts,
                onSelect: { contact in
                    shareVisibleSchedules(to: contact)
                }
            )
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

    
    //show only schedules for selected dates
    var filteredSchedules: [ScheduleDay] {
        if selectedDates.isEmpty {
            return schedules
        }

        return ScheduleHelper.filteredSchedules(
            schedules: schedules,
            selectedDates: selectedDates
        )
    }
    

    //make add schedule default to the most recently tapped date
    func prepareAddSchedule() {
        if let lastTappedDate {
            newScheduleDate = lastTappedDate
        } else if let selectedDate = selectedDates.compactMap({ Calendar.current.date(from: $0) }).last {
            newScheduleDate = selectedDate
        } else {
            newScheduleDate = Date()
        }

        newScheduleTime = Date()
    }

    
    //track the most recently tapped date from the calendar
    func updateLastTappedDate(from oldValue: Set<DateComponents>, to newValue: Set<DateComponents>) {
        let addedDates = newValue.subtracting(oldValue)

        if let mostRecentAddedDate = addedDates.compactMap({ Calendar.current.date(from: $0) }).last {
            lastTappedDate = mostRecentAddedDate
        }
    }

    
    //making it possible to add schedules
    func addSchedule() {
        let trimmedTitle = newScheduleTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty {
            return
        }

        ScheduleHelper.addSchedule(
            schedules: &schedules,
            selectedDates: &selectedDates,
            newScheduleDate: newScheduleDate,
            newScheduleTime: newScheduleTime,
            newScheduleTitle: trimmedTitle
        )

        saveOneOwnEventToFirebase(
            date: newScheduleDate,
            time: newScheduleTime,
            title: trimmedTitle
        )

        lastTappedDate = newScheduleDate
        newScheduleTitle = ""
        newScheduleDate = Date()
        newScheduleTime = Date()
        showAddScheduleSheet = false
    }
    
    
    //load my contacts so they can be selected for sharing
    func loadContactsForShare() {
        guard let user = appState.currentUser else {
            return
        }
        
        database
            .collection("Contacts")
            .whereField("username", isEqualTo: user.username)
            .limit(to: 1)
            .getDocuments { querySnapshot, error in
                
                if let error = error {
                    print("There was an error loading contacts:", error)
                    return
                }
                
                guard let document = querySnapshot?.documents.first else {
                    return
                }
                
                var newContacts = [] as [Contact]
                
                if let contactsFetched = document.data()["contacts"] as? [[String: String]] {
                    for contact in contactsFetched {
                        if let username = contact["username"],
                           let name = contact["name"] {
                            newContacts.append(Contact(username: username, name: name))
                        }
                    }
                }
                
                contactsStore.allContacts = newContacts
            }
    }
    
    
    //load all events assigned to this user
    func loadEventsFromFirebase() {
        guard let user = appState.currentUser else {
            return
        }
        
        database
            .collection("Events")
            .whereField("username", isEqualTo: user.username)
            .getDocuments { querySnapshot, error in
                
                if let error = error {
                    print("There was an error loading events:", error)
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    return
                }
                
                var dayMap: [String: [ScheduleItem]] = [:]
                var selected = Set<DateComponents>()
                
                for document in querySnapshot.documents {
                    let data = document.data()
                    
                    guard let timestamp = data["datetime"] as? Timestamp,
                          let eventName = data["name"] as? String else {
                        continue
                    }
                    
                    let eventDate = timestamp.dateValue()
                    let dateString = ScheduleHelper.dateString(from: eventDate)
                    let timeString = ScheduleHelper.timeString(from: eventDate)
                    
                    let sharedBy = data["sharedBy"] as? String
                    let ownerUsername = data["ownerUsername"] as? String
                    let isShared = sharedBy != nil && ownerUsername != user.username
                    
                    let item = ScheduleItem(
                        time: timeString,
                        title: eventName,
                        isShared: isShared,
                        sharedBy: sharedBy,
                        ownerUsername: ownerUsername
                    )
                    
                    if dayMap[dateString] != nil {
                        let alreadyExists = dayMap[dateString]?.contains {
                            $0.time == item.time && $0.title == item.title
                        } ?? false
                        
                        if !alreadyExists {
                            dayMap[dateString]?.append(item)
                        }
                    } else {
                        dayMap[dateString] = [item]
                    }
                    
                    let newDateComponents = Calendar.current.dateComponents(
                        [.year, .month, .day],
                        from: eventDate
                    )
                    selected.insert(newDateComponents)
                }
                
                var loadedSchedules = [] as [ScheduleDay]
                
                for (date, items) in dayMap {
                    let sortedItems = items.sorted { $0.time < $1.time }
                    loadedSchedules.append(
                        ScheduleDay(date: date, items: sortedItems)
                    )
                }
                
                ScheduleHelper.sortSchedules(&loadedSchedules)
                
                schedules = loadedSchedules
                selectedDates = selected
            }
    }
    
    
    //save one event for myself
    func saveOneOwnEventToFirebase(date: Date, time: Date, title: String) {
        guard let user = appState.currentUser else {
            return
        }
        
        let mergedDateTime = combineDateAndTime(date: date, time: time)
        
        database
            .collection("Events")
            .addDocument(data: [
                "username": user.username,
                "ownerUsername": user.username,
                "name": title,
                "datetime": Timestamp(date: mergedDateTime)
            ]) { error in
                if let error = error {
                    print("There was an error saving the event:", error)
                }
            }
    }
    
    
    //rewrite all events currently shown on this user's account
    func syncOwnEventsToFirebase() {
        guard let user = appState.currentUser else {
            return
        }
        
        let currentSchedules = schedules
        
        database
            .collection("Events")
            .whereField("username", isEqualTo: user.username)
            .getDocuments { querySnapshot, error in
                
                if let error = error {
                    print("There was an error finding current user's events:", error)
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    return
                }
                
                let batch = database.batch()
                
                for document in querySnapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit { error in
                    if let error = error {
                        print("There was an error deleting old events:", error)
                        return
                    }
                    
                    for day in currentSchedules {
                        guard let dayDate = ScheduleHelper.date(from: day.date) else {
                            continue
                        }
                        
                        for item in day.items {
                            let timeFormatter = DateFormatter()
                            timeFormatter.dateFormat = "HH:mm"
                            
                            guard let itemTime = timeFormatter.date(from: item.time) else {
                                continue
                            }
                            
                            let mergedDateTime = combineDateAndTime(date: dayDate, time: itemTime)
                            
                            var eventData: [String: Any] = [
                                "username": user.username,
                                "name": item.title,
                                "datetime": Timestamp(date: mergedDateTime)
                            ]
                            
                            if item.isShared {
                                eventData["ownerUsername"] = item.ownerUsername ?? item.sharedBy ?? user.username
                                eventData["sharedBy"] = item.sharedBy ?? item.ownerUsername ?? user.username
                            } else {
                                eventData["ownerUsername"] = user.username
                            }
                            
                            database
                                .collection("Events")
                                .addDocument(data: eventData)
                        }
                    }
                }
            }
    }
    
    
    //share currently visible schedules by duplicating them into the recipient's Events
    func shareVisibleSchedules(to contact: Contact) {
        guard let currentUser = appState.currentUser else {
            return
        }
        
        let schedulesToShare = filteredSchedules
        
        if schedulesToShare.isEmpty {
            return
        }
        
        for day in schedulesToShare {
            guard let dayDate = ScheduleHelper.date(from: day.date) else {
                continue
            }
            
            for item in day.items {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                
                guard let itemTime = timeFormatter.date(from: item.time) else {
                    continue
                }
                
                let mergedDateTime = combineDateAndTime(date: dayDate, time: itemTime)
                
                database
                    .collection("Events")
                    .addDocument(data: [
                        "username": contact.username,
                        "ownerUsername": currentUser.username,
                        "sharedBy": currentUser.username,
                        "name": item.title,
                        "datetime": Timestamp(date: mergedDateTime)
                    ]) { error in
                        if let error = error {
                            print("There was an error sharing the event:", error)
                        }
                    }
            }
        }
        
        showShareToContactSheet = false
    }
    
    
    func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        
        return calendar.date(from: mergedComponents) ?? date
    }
}


struct ShareToContactSheet: View {
    let contacts: [Contact]
    let onSelect: (Contact) -> Void
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(contacts) { contact in
                Button(action: {
                    onSelect(contact)
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.name)
                            .foregroundColor(.primary)
                        
                        Text(contact.username)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Share To")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

