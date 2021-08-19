import Foundation
import Adjust
import Segment

public class AdjustIntegration: SegmentIntegration {
    public var settings: [AnyHashable: Any]
    public var analytics: Analytics
    
    public init(settings: [AnyHashable: Any], analytics: Analytics) {
        self.settings = settings
        self.analytics = analytics
        super.init()
        
        guard let appToken = settings["appToken"] as? String else { return }
        
        let environment: String
        if self.isProdEnvironment {
            environment = ADJEnvironmentProduction
        } else {
            environment = ADJEnvironmentSandbox
        }
        
        let adjustConfig = ADJConfig(appToken: appToken, environment: environment)
        
        if self.isEventBufferingEnabled {
            adjustConfig?.eventBufferingEnabled = true
        }
        
        if self.shouldTrackAttributionData {
            adjustConfig?.delegate = self
        }
        
        if self.shouldSetDelay  {
            adjustConfig?.delayStart = self.delay
        }
        
        Adjust.appDidLaunch(adjustConfig)
    }
    
    public override func identify(_ payload: IdentifyPayload) {
        if !payload.userId.isEmpty {
            Adjust.addSessionPartnerParameter("user_id", value: payload.userId)
        }
        
        if !payload.anonymousId.isEmpty {
            Adjust.addSessionPartnerParameter("anonymous_id", value: payload.anonymousId)
        }
    }
    
    public override func track(_ payload: TrackPayload) {
        let segmentAnonymousId = Analytics.shared().getAnonymousId()
        if !segmentAnonymousId.isEmpty {
            Adjust.addSessionPartnerParameter("anonymous_id", value: segmentAnonymousId)
        }
        
        guard let token = self.getMappedCustomEventToken(event: payload.event) else { return }
        
        let event = ADJEvent(eventToken: token)
        
        payload.properties?.keys.forEach {
            if let key = $0 as? String, let value = payload.properties?[key] {
                let value = "\(value)"
                event?.addCallbackParameter(key, value: value)
            }
        }
        
        if let properties = payload.properties {
            if let revenue = Self.extractRevenue(from: properties, with: "revenue") {
                let currency = Self.extractCurrency(from: properties, with: "currency")
                event?.setRevenue(revenue.doubleValue, currency: currency)
            }
            
            if let orderId = Self.extractOrderId(from: properties, with: "orderId") {
                event?.setTransactionId(orderId)
            }
        }
        
        Adjust.trackEvent(event)
        
    }
    
    public override func screen(_ payload: ScreenPayload) {
        // Overrides this method to avoid crash. Screen track not needed for Adjust
    }
    
    public override func reset() {
        Adjust.resetSessionPartnerParameters()
    }
    
    public override func registeredForRemoteNotifications(withDeviceToken deviceToken: Data) {
        Adjust.setDeviceToken(deviceToken)
    }
    
//    public override func applicationDidEnterBackground() {
//        if Thread.isMainThread {
//            super.applicationDidEnterBackground()
//        } else {
//            DispatchQueue.main.async {
//                self.applicationDidEnterBackground()
//            }
//        }
//    }
        
//    public override func flush() {
//        
//    }
    
    // MARK: - Configuration
    
    private func getMappedCustomEventToken(event: String) -> String? {
        let tokens = self.settings["customEvents"] as? [String: Any]
        let token = tokens?[event] as? String
        return token
    }
    
    private var delay: Double {
        return (self.settings["delayTime"] as? Double) ?? .zero
    }
    
    private var isProdEnvironment: Bool {
        if let value = self.settings["setEnvironmentProduction"] as? NSNumber {
            return value.boolValue
        }
        return false
    }
    
    private var isEventBufferingEnabled: Bool {
        if let value = self.settings["setEventBufferingEnabled"] as? NSNumber {
            return value.boolValue
        }
        return false
    }
    
    private var shouldTrackAttributionData: Bool {
        if let value = self.settings["trackAttributionData"] as? NSNumber {
            return value.boolValue
        }
        return false
    }
    
    private var shouldSetDelay: Bool {
        if let value = self.settings["setDelay"] as? NSNumber {
            return value.boolValue
        }
        return false
    }
    
    private class func extractRevenue(from dictionary: [AnyHashable: Any], with revenueKey: String) -> NSNumber? {
        let matchingKeyValue = dictionary.first { (key, value) in
            if let stringKey = key as? String {
                return stringKey.caseInsensitiveCompare(revenueKey) == .orderedSame
            }
            return false
        }
        
        if let stringRevenueProperty = matchingKeyValue?.value as? String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.number(from: stringRevenueProperty)
        } else if let numberRevenueProperty = matchingKeyValue?.value as? NSNumber {
            return numberRevenueProperty
        }
        
        return nil
    }
    
    private class func extractCurrency(from dictionary: [AnyHashable: Any], with currencyKey: String) -> String {
        let matchingValue = dictionary.first { (key, value) in
            if let stringKey = key as? String {
                return stringKey.caseInsensitiveCompare(currencyKey) == .orderedSame
            }
            return false
        }.map { $0.value }
        
        return (matchingValue as? String) ?? "USD"
    }
    
    private class func extractOrderId(from dictionary: [AnyHashable: Any], with orderIdKey: String) -> String? {
        let matchingValue = dictionary.first { (key, value) in
            if let stringKey = key as? String {
                return stringKey.caseInsensitiveCompare(orderIdKey) == .orderedSame
            }
            return false
        }.map { $0.value }
        
        return (matchingValue as? String) ?? nil
    }
}

extension AdjustIntegration: AdjustDelegate {
    public func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        let campaign: [String: Any] = [
            "source" : attribution?.network ?? NSNull(),
            "name" : attribution?.campaign ?? NSNull(),
            "content" : attribution?.clickLabel ?? NSNull(),
            "adCreative" : attribution?.creative ?? NSNull(),
            "adGroup" : attribution?.adgroup ?? NSNull()
        ]
        
        self.analytics.track("Install Attributed",
                             properties: [
                                "provider" : "Adjust",
                                "trackerToken" : attribution?.trackerToken ?? NSNull(),
                                "trackerName" : attribution?.trackerName ?? NSNull(),
                                "campaign" :campaign
                             ]
        )
    }
}
