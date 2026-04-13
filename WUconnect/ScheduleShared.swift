//
//  ScheduleShared.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/6/26.
//

import SwiftUI

struct ScheduleListView: View {
    let schedules: [ScheduleDay]
    let emptyMessage: String
    let onSave: (UUID, UUID, Date, Date, String) -> Void
    let onDelete: (UUID, UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            if schedules.isEmpty {
                Text(emptyMessage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            } else {
                ForEach(schedules) { day in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(day.date)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        ForEach(day.items) { item in
                            NavigationLink(
                                destination: EditScheduleView(
                                    scheduleDay: day,
                                    scheduleItem: item,
                                    onSave: { updatedDate, updatedTime, updatedTitle in
                                        onSave(
                                            day.id,
                                            item.id,
                                            updatedDate,
                                            updatedTime,
                                            updatedTitle
                                        )
                                    },
                                    onDelete: {
                                        onDelete(day.id, item.id)
                                    }
                                )
                            ) {
                                HStack(spacing: 10) {
                                    Text(item.time)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 90)
                                        .padding(.vertical, 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
                                        )

                                    Text(item.title)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

struct AddScheduleSheet: View {
    @Binding var title: String
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date

    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Schedule Info")) {
                    TextField("Schedule Title", text: $title)

                    DatePicker(
                        "Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            .navigationTitle("Add Schedule")
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

struct EditScheduleView: View {
    let scheduleDay: ScheduleDay
    let scheduleItem: ScheduleItem
    let onSave: (Date, Date, String) -> Void
    let onDelete: () -> Void

    @State private var editedTitle = ""
    @State private var editedDate = Date()
    @State private var editedTime = Date()

    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section(header: Text("Schedule Info")) {
                TextField("Schedule Title", text: $editedTitle)

                DatePicker(
                    "Date",
                    selection: $editedDate,
                    displayedComponents: .date
                )

                DatePicker(
                    "Time",
                    selection: $editedTime,
                    displayedComponents: .hourAndMinute
                )
            }

            Section {
                Button(role: .destructive) {
                    onDelete()
                    dismiss()
                } label: {
                    Text("Delete Schedule")
                }
            }
        }
        .navigationTitle("Edit Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    onSave(editedDate, editedTime, editedTitle)
                    dismiss()
                }
            }
        }
        .onAppear {
            editedTitle = scheduleItem.title

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            if let date = dateFormatter.date(from: scheduleDay.date) {
                editedDate = date
            }

            if let time = timeFormatter.date(from: scheduleItem.time) {
                editedTime = time
            }
        }
    }
}



struct ScheduleDay: Identifiable {
    let id: UUID
    var date: String
    var items: [ScheduleItem]

    init(id: UUID = UUID(), date: String, items: [ScheduleItem]) {
        self.id = id
        self.date = date
        self.items = items
    }
}

struct ScheduleItem: Identifiable {
    let id: UUID
    var time: String
    var title: String

    init(id: UUID = UUID(), time: String, title: String) {
        self.id = id
        self.time = time
        self.title = title
    }
}

enum ScheduleHelper {
    static func filteredSchedules(
        schedules: [ScheduleDay],
        selectedDates: Set<DateComponents>
    ) -> [ScheduleDay] {
        if selectedDates.isEmpty {
            return schedules
        }

        let selectedDateStrings: Set<String> = Set(
            selectedDates.compactMap { components in
                guard let date = Calendar.current.date(from: components) else {
                    return nil
                }
                return dateString(from: date)
            }
        )

        return schedules.filter { day in
            selectedDateStrings.contains(day.date)
        }
    }

    static func makeSelectedDates(from schedules: [ScheduleDay]) -> Set<DateComponents> {
        let dates: [DateComponents] = schedules.compactMap { day in
            guard let date = date(from: day.date) else {
                return nil
            }

            return Calendar.current.dateComponents([.year, .month, .day], from: date)
        }

        return Set(dates)
    }

    static func addSchedule(
        schedules: inout [ScheduleDay],
        selectedDates: inout Set<DateComponents>,
        newScheduleDate: Date,
        newScheduleTime: Date,
        newScheduleTitle: String
    ) {
        let dateString = dateString(from: newScheduleDate)
        let timeString = timeString(from: newScheduleTime)
        let newItem = ScheduleItem(time: timeString, title: newScheduleTitle)

        if let existingIndex = schedules.firstIndex(where: { $0.date == dateString }) {
            schedules[existingIndex].items.append(newItem)
            schedules[existingIndex].items.sort { $0.time < $1.time }
        } else {
            schedules.append(
                ScheduleDay(
                    date: dateString,
                    items: [newItem]
                )
            )
        }

        sortSchedules(&schedules)

        let newDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: newScheduleDate
        )
        selectedDates.insert(newDateComponents)
    }

    
    static func updateScheduleItem(
        schedules: inout [ScheduleDay],
        selectedDates: inout Set<DateComponents>,
        dayId: UUID,
        itemId: UUID,
        newDate: Date,
        newTime: Date,
        newTitle: String
    ) {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty {
            return
        }

        let newDateString = dateString(from: newDate)
        let newTimeString = timeString(from: newTime)

        guard let oldDayIndex = schedules.firstIndex(where: { $0.id == dayId }) else {
            return
        }

        guard let oldItemIndex = schedules[oldDayIndex].items.firstIndex(where: { $0.id == itemId }) else {
            return
        }

        let updatedItem = ScheduleItem(
            id: itemId,
            time: newTimeString,
            title: trimmedTitle
        )

        schedules[oldDayIndex].items.remove(at: oldItemIndex)

        if schedules[oldDayIndex].items.isEmpty {
            let removedDayDate = schedules[oldDayIndex].date
            schedules.remove(at: oldDayIndex)
            removeSelectedDate(
                from: &selectedDates,
                for: removedDayDate
            )
        }

        if let newDayIndex = schedules.firstIndex(where: { $0.date == newDateString }) {
            schedules[newDayIndex].items.append(updatedItem)
            schedules[newDayIndex].items.sort { $0.time < $1.time }
        } else {
            schedules.append(
                ScheduleDay(
                    date: newDateString,
                    items: [updatedItem]
                )
            )
        }

        sortSchedules(&schedules)

        let newDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: newDate
        )
        selectedDates.insert(newDateComponents)
    }

    
    
    static func deleteScheduleItem(
        schedules: inout [ScheduleDay],
        selectedDates: inout Set<DateComponents>,
        dayId: UUID,
        itemId: UUID
    ) {
        guard let dayIndex = schedules.firstIndex(where: { $0.id == dayId }) else {
            return
        }

        guard let itemIndex = schedules[dayIndex].items.firstIndex(where: { $0.id == itemId }) else {
            return
        }

        schedules[dayIndex].items.remove(at: itemIndex)

        if schedules[dayIndex].items.isEmpty {
            let removedDayDate = schedules[dayIndex].date
            schedules.remove(at: dayIndex)
            removeSelectedDate(
                from: &selectedDates,
                for: removedDayDate
            )
        }
    }

    
    //order of dates
    static func sortSchedules(_ schedules: inout [ScheduleDay]) {
        schedules.sort {
            guard
                let firstDate = date(from: $0.date),
                let secondDate = date(from: $1.date)
            else {
                return $0.date < $1.date
            }
            return firstDate < secondDate
        }

        for index in schedules.indices {
            schedules[index].items.sort { $0.time < $1.time }
        }
    }

    static func removeSelectedDate(
        from selectedDates: inout Set<DateComponents>,
        for dateString: String
    ) {
        guard let date = date(from: dateString) else {
            return
        }

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        selectedDates.remove(dateComponents)
    }

    static func date(from string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: string)
    }

    static func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }

    static func timeString(from date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }
}
