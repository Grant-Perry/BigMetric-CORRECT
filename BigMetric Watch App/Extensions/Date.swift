//
//  Date.swift
//  howFar
//
//  Created by Grant Perry on 3/20/23.
//

import Foundation

extension Date {
   func formattedApple() -> String {
      let formatter = DateFormatter()
      let calendar = Calendar.current
      let oneWeekAgo = calendar.startOfDay(for: Date.now.addingTimeInterval(-7*24*3600)) // Calculate the start of one week ago
      let oneWeekAfter = calendar.startOfDay(for: Date.now.addingTimeInterval(7*24*3600)) // Calculate the start of one week from now

      if calendar.isDateInToday(self) { // Check if the date is today
         return formatted(date: .omitted, time: .shortened) // If yes, return a formatted string for today's date with the time shortened
      } else if calendar.isDateInYesterday(self) || calendar.isDateInTomorrow(self) { // Check if the date is yesterday or tomorrow
         formatter.doesRelativeDateFormatting = true // Enable relative date formatting
         formatter.dateStyle = .full // Set the date style to full
      } else if self > oneWeekAgo && self < oneWeekAfter { // Check if the date is within the past or next week
         formatter.dateFormat = "EEEE" // Set the date format to the day of the week (e.g. "Tuesday")
      } else if calendar.isDate(self, equalTo: .now, toGranularity: .year) { // Check if the date is in the same year as the current date
         formatter.dateFormat = "d MMM" // Set the date format to day and abbreviated month (e.g. "15 Jan")
      } else { // Otherwise
         formatter.dateFormat = "d MMM y" // Set the date format to day, month abbreviation, and year (e.g. "15 Jan 2022")
      }
      return formatter.string(from: self) // Return the formatted date string
   }
}
