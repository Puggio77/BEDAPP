//
//  UrgeWidget.swift
//  BEDAPP
//
//  Created by Alberto Besne Cabrera on 27/01/26.
//
//  Note: To show this widget on the home screen, add a Widget Extension target
//  and move this file (and Provider/Entry) into that target.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct UrgeWidgetEntry: TimelineEntry {
    let date: Date
}

// MARK: - Timeline Provider
struct UrgeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> UrgeWidgetEntry {
        UrgeWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (UrgeWidgetEntry) -> Void) {
        completion(UrgeWidgetEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UrgeWidgetEntry>) -> Void) {
        let entry = UrgeWidgetEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - Widget
struct UrgeWidget: Widget {
    let kind: String = "UrgeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UrgeWidgetProvider()) { entry in
            UrgeWidgetView(entry: entry)
        }
        .configurationDisplayName("I need help")
        .description("Quick access to coping tools when you feel an urge.")
    }
}

struct UrgeWidgetView: View {
    let entry: UrgeWidgetEntry

    var body: some View {
        VStack {
            Image(systemName: "heart.text.square")
                .font(.largeTitle)
            Text("I need help")
                .font(.caption)
                .bold()
        }
        .containerBackground(
            LinearGradient(
                colors: [Color.bedPrimary, Color.bedSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .widget
        )
        .widgetURL(URL(string: "bedsupport://intervention"))
    }
}
