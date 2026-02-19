//
//  StoreKitService.swift
//  StreakSeed
//
//  StoreKit 2 service for Pro subscriptions and lifetime purchase.
//

import Foundation
import StoreKit
import Observation

@Observable
final class StoreKitService {
    static let shared = StoreKitService()

    var products: [Product] = []
    var isPro: Bool = false
    var isLoading: Bool = false

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task { await checkEntitlement() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        do {
            let storeProducts = try await Product.products(for: Constants.allProductIds)
            print("[StoreKit] Requested IDs: \(Constants.allProductIds)")
            print("[StoreKit] Loaded \(storeProducts.count) products:")
            for p in storeProducts {
                print("  - \(p.id): \(p.displayName) (\(p.displayPrice)) type=\(p.type)")
            }
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            print("[StoreKit] Failed to load products: \(error)")
        }
        isLoading = false
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await checkEntitlement()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restore() async {
        try? await AppStore.sync()
        await checkEntitlement()
    }

    // MARK: - Entitlement

    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if Constants.allProductIds.contains(transaction.productID) {
                    isPro = true
                    syncProStatusToAppGroup()
                    return
                }
            }
        }
        isPro = false
        syncProStatusToAppGroup()
    }

    /// Sync Pro status to shared App Group so widgets can read it.
    private func syncProStatusToAppGroup() {
        // Write to App Group UserDefaults
        let sharedDefaults = UserDefaults(suiteName: Constants.appGroupId)
        sharedDefaults?.set(isPro, forKey: Constants.isProKey)

        // Also write a flag file in the shared container as a fallback
        if let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.appGroupId
        ) {
            let flagURL = containerURL.appendingPathComponent(".isPro")
            if isPro {
                try? Data([1]).write(to: flagURL)
            } else {
                try? FileManager.default.removeItem(at: flagURL)
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await self.checkEntitlement()
                }
            }
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
