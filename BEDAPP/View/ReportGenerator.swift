//
//  ReportGenerator.swift
//  BEDAPP
//
//  Created by Alberto Besne Cabrera on 27/01/26.
//

import UIKit
import PDFKit

class ReportGenerator {

    /// Generates a PDF for one episode report (for the specialist).
    static func createPDFReport(for report: EpisodeReport) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            "Title": "BED Specialist Report",
            "Author": "BED Support App"
        ]
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateStyle = .long
            f.timeStyle = .short
            return f
        }()

        let data = renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = 40
            let margin: CGFloat = 40
            let maxWidth = pageRect.width - margin * 2

            let titleFont = UIFont.boldSystemFont(ofSize: 18)
            let headingFont = UIFont.boldSystemFont(ofSize: 14)
            let bodyFont = UIFont.systemFont(ofSize: 12)

            "Binge Eating Disorder - Clinical Progress Report"
                .draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: titleFont])
            y += 28

            "Episode report — \(dateFormatter.string(from: report.date))"
                .draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.gray])
            y += 24

            func drawRow(title: String, value: String) {
                let titleAttr: [NSAttributedString.Key: Any] = [.font: headingFont, .foregroundColor: UIColor.darkGray]
                let valueAttr: [NSAttributedString.Key: Any] = [.font: bodyFont, .foregroundColor: UIColor.black]
                (title + ": ").draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttr)
                let titleSize = (title + ": ").size(withAttributes: titleAttr)
                let valueRect = CGRect(x: margin + titleSize.width, y: y - 2, width: maxWidth - titleSize.width, height: 60)
                (value as NSString).draw(in: valueRect, withAttributes: valueAttr)
                y += max(24, (value as NSString).boundingRect(with: CGSize(width: valueRect.width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: valueAttr, context: nil).height + 8)
            }

            drawRow(title: "Feelings / triggers", value: report.triggers)
            drawRow(title: "Control level", value: "\(report.controlLevel)/10")
            drawRow(title: "Where", value: report.location)
            drawRow(title: "Urge to eat", value: report.urgeToEat)
            drawRow(title: "What you ate", value: report.whatAte)
            drawRow(title: "Episode duration", value: report.episodeDuration)
        }
        return data
    }
}
