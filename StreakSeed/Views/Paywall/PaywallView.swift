//
//  PaywallView.swift
//  StreakSeed
//
//  Pro upgrade paywall — shown after onboarding or from settings.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedProductId: String?

    /// Optional callback when the user dismisses (used by onboarding to continue to Home).
    var onDismiss: (() -> Void)?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("🌿")
                            .font(.system(size: 56))

                        Text(String(localized: "Grow your streak\nfaster with Pro"))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)

                        Text(String(localized: "Widgets, smart nudges, and streak protection — so your habit actually sticks."))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)

                    // Feature bullets
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(ProFeature.allCases) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: feature.iconName)
                                    .font(.body)
                                    .foregroundStyle(Color.seedGreen)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.title)
                                        .font(.subheadline.weight(.medium))
                                    Text(feature.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .cardStyle()

                    // Product options
                    VStack(spacing: 10) {
                        ForEach(sortedProducts) { product in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedProductId = product.id
                                }
                            } label: {
                                productRow(product)
                            }
                            .pressScale()
                        }

                        if StoreKitService.shared.products.isEmpty && !isLoading {
                            ProgressView()
                                .tint(.seedGreen)
                        }
                    }

                    // CTA
                    if !StoreKitService.shared.products.isEmpty {
                        Button {
                            if let selected = StoreKitService.shared.products.first(where: { $0.id == selectedProductId }) {
                                Task { await purchase(selected) }
                            }
                        } label: {
                            Text(String(localized: "Start Pro"))
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.seedGreen)
                                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous))
                        }
                        .pressScale()
                    }

                    // Secondary dismiss — clearly tappable, not dimmed
                    Button {
                        handleDismiss()
                    } label: {
                        Text(String(localized: "Continue with Free"))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                    }

                    // Fine print
                    VStack(spacing: 4) {
                        Text(String(localized: "Cancel anytime. No backend. Your data stays on device."))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)

                        Text(String(localized: "Payment charged to Apple ID at confirmation. Subscriptions renew automatically unless canceled 24 hours before end of period."))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 4) {
                            Link(String(localized: "Terms of Use (EULA)"),
                                 destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            Text("·")
                                .foregroundStyle(.tertiary)
                            Link(String(localized: "Privacy Policy"),
                                 destination: URL(string: "https://www.disruptlogic.com/privacy-policy")!)
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
                .padding(Constants.screenPadding)
            }
            .background(Color.surfaceBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        handleDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                }
            }
            .alert(String(localized: "Purchase Error"), isPresented: $showError) {
                Button(String(localized: "OK")) {}
            } message: {
                Text(errorMessage)
            }
        }
        .task {
            await StoreKitService.shared.loadProducts()
            // Default selection to annual
            if selectedProductId == nil {
                selectedProductId = Constants.proAnnualProductId
            }
        }
    }

    // MARK: - Product Row

    @ViewBuilder
    private func productRow(_ product: Product) -> some View {
        let annual = isAnnual(product)
        let lifetime = isLifetime(product)
        let isSelected = product.id == selectedProductId

        HStack {
            // Selection radio
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.seedGreen : Color(.tertiaryLabel), lineWidth: 2)
                    .frame(width: 22, height: 22)

                if isSelected {
                    Circle()
                        .fill(Color.seedGreen)
                        .frame(width: 14, height: 14)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(product.displayName)
                        .font(.subheadline.weight(.semibold))

                    if annual {
                        savingsBadge(text: savingsText(for: product))
                    } else if lifetime {
                        savingsBadge(text: String(localized: "Best Value"))
                    }
                }

                Text(productSubtitle(for: product))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text(product.displayPrice)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.seedGreen)

                if annual {
                    Text(monthlyEquivalent(for: product))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous)
                .stroke(
                    isSelected ? Color.seedGreen : Color.clear,
                    lineWidth: isSelected ? 2 : 0
                )
        )
    }

    private func savingsBadge(text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.seedGreen)
            .clipShape(Capsule())
    }

    // MARK: - Helpers

    /// Sort: Annual first, then lifetime, then monthly.
    private var sortedProducts: [Product] {
        StoreKitService.shared.products.sorted { a, b in
            let order: [String: Int] = [
                Constants.proAnnualProductId: 0,
                Constants.proLifetimeProductId: 1,
                Constants.proMonthlyProductId: 2
            ]
            return (order[a.id] ?? 99) < (order[b.id] ?? 99)
        }
    }

    private func isAnnual(_ product: Product) -> Bool {
        product.id == Constants.proAnnualProductId
    }

    private func isLifetime(_ product: Product) -> Bool {
        product.id == Constants.proLifetimeProductId
    }

    private func isMonthly(_ product: Product) -> Bool {
        product.id == Constants.proMonthlyProductId
    }

    /// Calculate "Save X%" for annual vs monthly x 12.
    private func savingsText(for product: Product) -> String {
        guard let monthly = StoreKitService.shared.products.first(where: { isMonthly($0) }) else {
            return String(localized: "Save 58%")  // fallback
        }
        let monthlyDouble = NSDecimalNumber(decimal: monthly.price).doubleValue
        let productDouble = NSDecimalNumber(decimal: product.price).doubleValue
        let yearlyFromMonthly = monthlyDouble * 12.0
        guard yearlyFromMonthly > 0 else { return String(localized: "Save") }
        let pct = Int(((yearlyFromMonthly - productDouble) / yearlyFromMonthly) * 100.0)
        guard pct > 0 else { return String(localized: "Save") }
        return "Save \(pct)%"
    }

    /// e.g. "$0.83/mo"
    private func monthlyEquivalent(for product: Product) -> String {
        let monthly = product.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceFormatStyle.locale
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: NSDecimalNumber(decimal: monthly)) ?? "\(monthly)"
        return "\(formatted)/mo"
    }

    private func productSubtitle(for product: Product) -> String {
        if isAnnual(product) {
            return String(localized: "Billed annually — most popular")
        } else if isLifetime(product) {
            return String(localized: "Pay once, keep forever")
        } else if isMonthly(product) {
            return String(localized: "Billed monthly")
        }
        return product.description
    }

    private func purchase(_ product: Product) async {
        isLoading = true
        do {
            let success = try await StoreKitService.shared.purchase(product)
            if success {
                handleDismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    private func handleDismiss() {
        dismiss()
        onDismiss?()
    }
}
