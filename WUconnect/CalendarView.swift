//
//  CalendarView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var appState: AppState

    //fake data for testing
    static let initialSchedules: [ScheduleDay] = [
        ScheduleDay(
            date: "04/08/2026",
            items: [
                ScheduleItem(time: "13:00", title: "Exam Review")
            ]
        ),
        ScheduleDay(
            date: "04/20/2026",
            items: [
                ScheduleItem(time: "13:00", title: "Presentation"),
                ScheduleItem(time: "16:00", title: "Study Session")
            ]
        )
    ]

    
    //some fake data for now
    @State private var selectedDates: Set<DateComponents>
    @State private var schedules: [ScheduleDay]

    @State private var showAddScheduleSheet = false
    @State private var newScheduleTitle = ""
    @State private var newScheduleDate = Date()
    @State private var newScheduleTime = Date()
    @State private var lastTappedDate: Date? = nil

    init() {
        let startingSchedules = Self.initialSchedules

        _schedules = State(initialValue: startingSchedules)
        _selectedDates = State(
            initialValue: ScheduleHelper.makeSelectedDates(from: startingSchedules)
        )
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
                        print("Share Schedule tapped")
                    }) {
                        Text("Share Schedule")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 16)

                //Calendar area
                VStack(spacing: 0) {
                    MultiDatePicker("Select Dates", selection: $selectedDates)
                        .padding()
                        .tint(.yellow)
                        .background(Color.white)
                        .cornerRadius(12)
                        .labelsHidden()
                        .onChange(of: selectedDates) { oldValue, newValue in
                            updateLastTappedDate(from: oldValue, to: newValue)
                        }

                    HStack {
                        NavigationLink(
                            destination: AllSchedules(
                                schedules: $schedules,
                                selectedDates: $selectedDates
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
                        },
                        onDelete: { dayId, itemId in
                            ScheduleHelper.deleteScheduleItem(
                                schedules: &schedules,
                                selectedDates: &selectedDates,
                                dayId: dayId,
                                itemId: itemId
                            )
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

        lastTappedDate = newScheduleDate
        newScheduleTitle = ""
        newScheduleDate = Date()
        newScheduleTime = Date()
        showAddScheduleSheet = false
    }
}



struct CalendarView_PreviewWrapper: View {
    @StateObject private var appState = AppState()

    var body: some View {
        NavigationStack {
            CalendarView()
                .environmentObject(appState)
        }
        .onAppear {
            appState.currentUser = User(
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
    CalendarView_PreviewWrapper()
}
