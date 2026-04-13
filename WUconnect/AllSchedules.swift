//
//  AllSchedules.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/6/26.
//

import SwiftUI

struct AllSchedules: View {
    @Binding var schedules: [ScheduleDay]
    @Binding var selectedDates: Set<DateComponents>

    @State private var isEditing = false
    @State private var selectedItemIds: Set<UUID> = []

    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {

                
                //description
                Text(isEditing ? "Select schedules to delete" : "Tap a schedule to edit")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                //Using List because with ScrollView + VStack we cannot implement swipe to delete
                if schedules.isEmpty {
                    Text("No schedules")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 24)

                    Spacer()
                } else {
                    List {
                        ForEach(schedules) { day in
                            Section {
                                ForEach(day.items) { item in
                                    scheduleRow(day: day, item: item)
                                        .listRowBackground(Color(red: 0.16, green: 0.15, blue: 0.18))
                                }
                                .onDelete(perform: isEditing ? nil : { offsets in
                                    deleteItems(at: offsets, from: day)
                                })
                            } header: {
                                Text(day.date)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .textCase(nil)
                            }
                            .listRowBackground(Color(red: 0.16, green: 0.15, blue: 0.18))
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }

                if isEditing && !schedules.isEmpty {
                    Button(action: {
                        deleteSelectedItems()
                    }) {
                        Text("Delete Selected")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(selectedItemIds.isEmpty ? Color.gray : Color.red)
                            .cornerRadius(8)
                    }
                    .disabled(selectedItemIds.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("All Schedules")
        .navigationBarTitleDisplayMode(.inline)
        
        
        //let user delete items in bulk using the "delete" button
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Delete") {
                    if isEditing {
                        isEditing = false
                        selectedItemIds.removeAll()
                    } else {
                        isEditing = true
                    }
                }
            }
        }
    }

    
    
    @ViewBuilder
    func scheduleRow(day: ScheduleDay, item: ScheduleItem) -> some View {
        if isEditing {
            Button(action: {
                toggleSelection(for: item.id)
            }) {
                HStack(spacing: 12) {

                    //Selection circle to look clearer. Not visible without this since our app is dark
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 2.5)
                            .frame(width: 24, height: 24)

                        if selectedItemIds.contains(item.id) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 14, height: 14)
                        }
                    }

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
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(
                destination: EditScheduleView(
                    scheduleDay: day,
                    scheduleItem: item,
                    onSave: { updatedDate, updatedTime, updatedTitle in
                        ScheduleHelper.updateScheduleItem(
                            schedules: &schedules,
                            selectedDates: &selectedDates,
                            dayId: day.id,
                            itemId: item.id,
                            newDate: updatedDate,
                            newTime: updatedTime,
                            newTitle: updatedTitle
                        )
                    },
                    onDelete: {
                        ScheduleHelper.deleteScheduleItem(
                            schedules: &schedules,
                            selectedDates: &selectedDates,
                            dayId: day.id,
                            itemId: item.id
                        )
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
                .padding(.vertical, 4)
            }
        }
    }

    func toggleSelection(for itemId: UUID) {
        if selectedItemIds.contains(itemId) {
            selectedItemIds.remove(itemId)
        } else {
            selectedItemIds.insert(itemId)
        }
    }

    func deleteItems(at offsets: IndexSet, from day: ScheduleDay) {
        for offset in offsets {
            let item = day.items[offset]

            ScheduleHelper.deleteScheduleItem(
                schedules: &schedules,
                selectedDates: &selectedDates,
                dayId: day.id,
                itemId: item.id
            )
        }
    }

    //tap the delete button, and delete selected items
    func deleteSelectedItems() {
        let itemsToDelete = schedules.flatMap { day in
            day.items.compactMap { item in
                selectedItemIds.contains(item.id) ? (day.id, item.id) : nil
            }
        }

        for (dayId, itemId) in itemsToDelete {
            ScheduleHelper.deleteScheduleItem(
                schedules: &schedules,
                selectedDates: &selectedDates,
                dayId: dayId,
                itemId: itemId
            )
        }

        selectedItemIds.removeAll()
        isEditing = false
    }
}
