import IntuneMAMSwift
/*
 This enrollment delegate class can be initialized and set as the enrollment delegate of the IntuneMAMEnrollmentManager
 Doing this will trigger the enrollmentRequestWithStatus method whenever an enrollment is attempted.
 It can also be used to trigger unenrollRequestWithStatus whenever unenrollment is attempted.
 This allows for the app to check if an enrollment was successful
 
 NOTE: A number of other methods are avaliable in the IntuneMAMEnrollmentDelegate. See documentation or header file for more info.
 */
class EnrollmentDelegateClass: NSObject, IntuneMAMEnrollmentDelegate {
    
    var presentingViewController: UIViewController?
    var completionHandler:  (MSALResponse) -> Void =  {_ in MSALResponse()}
    override init() {
        super.init()
        self.presentingViewController = nil
    }
    
    /*
     To be able to change the view, the class should be initialzed with the curent view controller. Then this view controller can move to the desired view based on the enrollment success
     
     @param viewController - the view controller this class should use when triggered
     */
    init(viewController : UIViewController, completionHandler: @escaping (MSALResponse) -> Void){
        super.init()
        self.presentingViewController = viewController
        self.completionHandler = completionHandler
    }
    
    /*
     This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an enrollment is attempted.
     The status parameter is a member of the IntuneMAMEnrollmentStatus class. This object can be used to check for the status of an attempted enrollment
     If successful, logic for enrollment is initiated
     */
    func enrollmentRequest(with status: IntuneMAMEnrollmentStatus) {
        if status.didSucceed{
            print("Login successful")
            MSALUtils.instance.getSharePointAccessTokenAsync();
            
        } else if IntuneMAMEnrollmentStatusCode.loginCanceled != status.statusCode {
            
            if(status.statusCode == IntuneMAMEnrollmentStatusCode.alreadyEnrolled) {
                let msg = "Application already enrolled, so proceed to get token";
                print(msg);
                MSALUtils.instance.getSharePointAccessTokenAsync();
                return
                
            }
            var msg = "Enrollment result for identity \(status.identity) with status code \(status.statusCode)";
            print(msg)
            msg = "Debug message: \(String(describing: status.errorString))";
            print(msg)
            completionHandler(MSALResponse(token: "", error: MSALException.HTTPError(msg: msg) ))
            return
        }
    }
    
    /*
     This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an unenrollment is attempted.
     The status parameter is a member of the IntuneMAMEnrollmentStatus class. This object can be used to check for the status of an attempted unenrollment.
     Logic for logout/token clearing is initiated here.
     */
    func unenrollRequest(with status: IntuneMAMEnrollmentStatus) {
        //Go back to login page from current view controller
//        let presentingViewController = UIUtils.getCurrentViewController()
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let loginPage = storyboard.instantiateViewController(withIdentifier: "LoginPage")
//
//        presentingViewController.present(loginPage, animated: true, completion: nil)
//
//        if status.didSucceed != true {
//            //In the case unenrollment failed, log error
//            print("Unenrollment result for identity \(status.identity) with status code \(status.statusCode)")
//            print("Debug message: \(String(describing: status.errorString))")
//        }
    }
}
