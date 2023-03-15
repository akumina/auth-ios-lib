import Foundation
import Rollbar

public final class AkuminaLib {
    
    public init() {
        let config: RollbarConfiguration = RollbarConfiguration()
                    config.environment = "production"
        Rollbar.initWithAccessToken(Constants.ROLLBAR_TOKEN, configuration: config)
        
        Rollbar.info(Constants.ROLLBAR_APP_ID +  " has started ");
    }
    
    public func authenticateWithIntune(parentViewController: UIViewController, clientDetails: ClientDetails, completionHandler: @escaping (MSALResponse) -> Void) throws {
        do {
            try MSALUtils.instance.initMSAL(parentViewController: parentViewController, clientDetails: clientDetails, withIntune: true,completionHandler: completionHandler)
        }catch {
            throw MSALException.TokenFailedException(error: error)
        }
    }
    public func authenticateWithOutIntune(parentViewController: UIViewController, clientDetails: ClientDetails, completionHandler: @escaping (MSALResponse) -> Void) throws {
        do {
            try MSALUtils.instance.initMSAL(parentViewController: parentViewController, clientDetails: clientDetails, withIntune: false,completionHandler: completionHandler)
        }catch {
            throw MSALException.TokenFailedException(error: error)
        }
    }
    public func authenticateWithOutIntune(){
        print("authenticateWithOutIntune")
    }
}


