import SwiftUI

/// A button component that triggers waitlist signup
public struct WaitlistButton: View {
    @StateObject private var viewModel: WaitlistButtonViewModel
    @State private var showSheet: Bool = false
    
    private let config: WaitlistConfig
    private let label: String
    private let style: ButtonStyle
    
    /// Button style options
    public enum ButtonStyle {
        case primary
        case secondary
        case custom(foreground: Color, background: Color)
    }
    
    /// Initialize a new WaitlistButton
    /// - Parameters:
    ///   - config: The waitlist configuration
    ///   - label: The button label text
    ///   - style: The button style
    public init(
        config: WaitlistConfig,
        label: String = "Join Waitlist",
        style: ButtonStyle = .primary
    ) {
        self.config = config
        self.label = label
        self.style = style
        _viewModel = StateObject(wrappedValue: WaitlistButtonViewModel(config: config))
    }
    
    public var body: some View {
        Button(action: {
            showSheet = true
        }) {
            Text(label)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(8)
        }
        .sheet(isPresented: $showSheet) {
            WaitlistView(config: config)
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .blue
        case .secondary:
            return .gray
        case .custom(_, let background):
            return background
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary:
            return .white
        case .custom(let foreground, _):
            return foreground
        }
    }
}

/// View model for WaitlistButton
@MainActor
private class WaitlistButtonViewModel: ObservableObject {
    private let client: WaitlistClient
    
    init(config: WaitlistConfig) {
        self.client = WaitlistClient(config: config)
    }
}
