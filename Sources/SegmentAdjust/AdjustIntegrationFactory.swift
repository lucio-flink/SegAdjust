import Foundation
import Segment

public class AdjustIntegrationFactory: NSObject, SEGIntegrationFactory {
    public static let instance = AdjustIntegrationFactory()
        
    public func create(withSettings settings: [AnyHashable : Any], for analytics: Analytics) -> Integration {
        return AdjustIntegration(settings: settings, analytics: analytics)
    }
    
    public func key() -> String {
        return "Adjust"
    }
}
