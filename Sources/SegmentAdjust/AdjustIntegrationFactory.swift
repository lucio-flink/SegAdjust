import Foundation
import Segment

class AdjustIntegrationFactory: SEGIntegrationFactory {
    public let instance = AdjustIntegrationFactory()
    
    public init() {
        
    }
    
    func create(withSettings settings: [AnyHashable : Any], for analytics: Analytics) -> Integration {
        return AdjustIntegration(settings: settings, analytics: analytics)
    }
    
    func key() -> String {
        return "Adjust"
    }
}
