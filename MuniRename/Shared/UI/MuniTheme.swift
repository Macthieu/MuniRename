import SwiftUI
import AppKit

enum MuniTheme {
    static let windowBackground = LinearGradient(
        colors: [
            Color(nsColor: NSColor(calibratedWhite: 0.96, alpha: 1.0)),
            Color(nsColor: NSColor(calibratedWhite: 0.93, alpha: 1.0))
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let panelFill = Color.white.opacity(0.72)
    static let panelStroke = Color.black.opacity(0.12)

    static let paneFill = Color.white.opacity(0.65)
    static let paneStroke = Color.black.opacity(0.10)

    static let sectionActiveFill = Color.accentColor.opacity(0.10)
    static let sectionInactiveFill = Color.white.opacity(0.72)
    static let sectionActiveStroke = Color.accentColor.opacity(0.75)
    static let sectionInactiveStroke = Color.black.opacity(0.12)

    static let divider = Color.black.opacity(0.08)
}

private struct MuniSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat
    var fill: Color
    var stroke: Color
    var lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(stroke, lineWidth: lineWidth)
            )
    }
}

extension View {
    func muniSurface(
        cornerRadius: CGFloat = 12,
        fill: Color = MuniTheme.panelFill,
        stroke: Color = MuniTheme.panelStroke,
        lineWidth: CGFloat = 1
    ) -> some View {
        modifier(MuniSurfaceModifier(cornerRadius: cornerRadius, fill: fill, stroke: stroke, lineWidth: lineWidth))
    }
}
