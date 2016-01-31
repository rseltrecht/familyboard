//
//  ViewController.swift
//  familyboard
//
//  Created by Richard Seltrecht on 24/01/2016.
//  Copyright © 2016 Selten. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var mqttStatus: String = "Disconnected"
    var topic: String = "familyboard/display"
    
    @IBOutlet weak var buttonConnect: UIButton!
    
    @IBOutlet weak var boxConnect: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var logTextView: UITextView!
    
    
    @IBOutlet weak var boxMessage: UIImageView!
    @IBOutlet weak var txtFieldMessage: UITextField!
    
    @IBOutlet weak var labelMessage: UILabel!
    
    @IBOutlet weak var buttonPublishMessage: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var labelChooseColor: UILabel!
    
    @IBOutlet weak var buttonColorRed: UIButton!
    
    @IBOutlet weak var buttonColorBlue: UIButton!
    
    @IBOutlet weak var buttonColorGreen: UIButton!
   
    
    @IBOutlet weak var labelPredefinedMsg: UILabel!
 
    @IBOutlet weak var buttonText1: UIButton!
    
    @IBOutlet weak var buttonText2: UIButton!
    
    @IBOutlet weak var buttonText3: UIButton!
    
    @IBOutlet weak var buttonText4: UIButton!
    
    @IBOutlet weak var buttonText5: UIButton!
    
    var connected = false;
    // var publishViewController : UIViewController!;
    // var subscribeViewController : UIViewController!;
    // var configurationViewController : UIViewController!;
    
    var iotDataManager: AWSIoTDataManager!;
    var iotData: AWSIoTData!
    var iotManager: AWSIoTManager!;
    var iot: AWSIoT!
    
    var items: [String] = ["I will be late",
        "Don't forget your homework",
        "Call me when you are back",
        "I will be home at 8 pm",
        "Prepare your sport affairs",
    ]
    
    // MARK : Actions
    
    @IBAction func connectButtonPressed(sender: UIButton) {
        
        // let tabBarViewController = tabBarController as! IoTSampleTabBarController
        
        sender.enabled = false
        
        func mqttEventCallback( status: AWSIoTMQTTStatus )
        {
            dispatch_async( dispatch_get_main_queue()) {
                print("connection status = \(status.rawValue)")
                switch(status)
                {
                case .Connecting:
                    self.mqttStatus = "Connecting..."
                    print( self.mqttStatus )
                    self.logTextView.text = self.mqttStatus
                    
                case .Connected:
                    self.mqttStatus = "Connected"
                    print( self.mqttStatus )
                    sender.setTitle( "Disconnect", forState:.Normal)
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.connected = true
                    sender.enabled = true
                    let uuid = NSUUID().UUIDString;
                    let defaults = NSUserDefaults.standardUserDefaults()
                    let certificateId = defaults.stringForKey( "certificateId")
                    
                    // self.logTextView.text = "Using certificate:\n\(certificateId!)\n\n\nClient ID:\n\(uuid)"
                    
                    self.logTextView.text = "Connected"

                    
                    self.boxMessage.hidden = false
                    self.txtFieldMessage.hidden = false
                    self.labelMessage.hidden = false
                    self.buttonPublishMessage.hidden = false
                    
                    self.labelChooseColor.hidden = false
                    self.buttonColorRed.hidden = false
                    self.buttonColorBlue.hidden = false
                    self.buttonColorGreen.hidden = false
                    
                    self.labelPredefinedMsg.hidden = false
                    self.buttonText1.hidden = false
                    self.buttonText2.hidden = false
                    self.buttonText3.hidden = false
                    self.buttonText4.hidden = false
                    self.buttonText5.hidden = false
                    
                    self.buttonColorRed.selected = true
                    self.buttonColorBlue.selected = false
                    self.buttonColorGreen.selected = false

                    
                    self.buttonConnect.hidden = true
                    self.boxConnect.hidden = true

                    
                    //tabBarViewController.viewControllers = [ self, self.publishViewController, self.subscribeViewController ]
                    
                    
                case .Disconnected:
                    self.mqttStatus = "Disconnected"
                    print( self.mqttStatus )
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = nil
                    
                case .ConnectionRefused:
                    self.mqttStatus = "Connection Refused"
                    print( self.mqttStatus )
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = self.mqttStatus
                    
                case .ConnectionError:
                    self.mqttStatus = "Connection Error"
                    print( self.mqttStatus )
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = self.mqttStatus
                    
                case .ProtocolError:
                    self.mqttStatus = "Protocol Error"
                    print( self.mqttStatus )
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = self.mqttStatus
                    
                default:
                    self.mqttStatus = "Unknown State"
                    print("unknown state: \(status.rawValue)")
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = self.mqttStatus
                    
                }
                NSNotificationCenter.defaultCenter().postNotificationName( "connectionStatusChanged", object: self )
            }
            
        }
        
        if (connected == false)
        {
            activityIndicatorView.hidden = false
            activityIndicatorView.startAnimating()
            
            boxMessage.hidden = true
            txtFieldMessage.hidden = true
            labelMessage.hidden = true
            buttonPublishMessage.hidden = true
            
            boxConnect.hidden = false
            buttonConnect.hidden = false
            
            labelChooseColor.hidden = true
            buttonColorRed.hidden = true
            buttonColorBlue.hidden = true
            buttonColorGreen.hidden = true
            
            labelPredefinedMsg.hidden = true
            buttonText1.hidden = true
            buttonText2.hidden = true
            buttonText3.hidden = true
            buttonText4.hidden = true
            buttonText5.hidden = true

            
            tableView.hidden = true


            
            let defaults = NSUserDefaults.standardUserDefaults()
            var certificateId = defaults.stringForKey( "certificateId")
            
            if (certificateId == nil)
            {
                dispatch_async( dispatch_get_main_queue()) {
                    self.logTextView.text = "No certificate available, creating one..."
                }
                print ("no certificate found")
                //
                // Now create and store the certificate ID in NSUserDefaults
                //
                let csrDictionary = [ "commonName":CertificateSigningRequestCommonName, "countryName":CertificateSigningRequestCountryName, "organizationName":CertificateSigningRequestOrganizationName, "organizationalUnitName":CertificateSigningRequestOrganizationalUnitName ]
                
                // commonName, countryName, organizationName, organizationalUnitName
                
                self.iotManager.createKeysAndCertificateFromCsr(csrDictionary, callback: {  (response ) -> Void in
                    defaults.setObject(response.certificateId, forKey:"certificateId")
                    defaults.setObject(response.certificateArn, forKey:"certificateArn")
                    certificateId = response.certificateId
                    print("response: [\(response)]")
                    let uuid = NSUUID().UUIDString;
                    
                    let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest()
                    attachPrincipalPolicyRequest.policyName = PolicyName
                    attachPrincipalPolicyRequest.principal = response.certificateArn
                    //
                    // Attach the policy to the certificate
                    //
                    self.iot.attachPrincipalPolicy(attachPrincipalPolicyRequest).continueWithBlock { (task) -> AnyObject? in
                        if let error = task.error {
                            print("failed: [\(error)]")
                        }
                        if let exception = task.exception {
                            print("failed: [\(exception)]")
                        }
                        print("result: [\(task.result)]")
                        //
                        // Connect to the AWS IoT platform
                        //
                        if (task.exception == nil && task.error == nil)
                        {
                            let delayTime = dispatch_time( DISPATCH_TIME_NOW, Int64(2*Double(NSEC_PER_SEC)))
                            dispatch_after( delayTime, dispatch_get_main_queue()) {
                                self.logTextView.text = "Using certificate: \(certificateId!)"
                                self.iotDataManager.connectWithClientId( uuid, cleanSession:true, certificateId:certificateId,statusCallback: mqttEventCallback)
                            }
                        }
                        return nil
                    }
                } )
            }
            else
            {
                let uuid = NSUUID().UUIDString;
                
                //
                // Connect to the AWS IoT service
                //
                iotDataManager.connectWithClientId( uuid, cleanSession:true, certificateId:certificateId, statusCallback: mqttEventCallback)
            }
        }
        else
        {
            activityIndicatorView.hidden = false
            activityIndicatorView.startAnimating()
            logTextView.text = "Disconnecting..."
            
            dispatch_async( dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0) ){
                self.iotDataManager.disconnect();
                dispatch_async( dispatch_get_main_queue() ) {
                    self.activityIndicatorView.stopAnimating()
                    self.connected = false
                    sender.setTitle( "Connect", forState:.Normal)
                    sender.enabled = true
                    // tabBarViewController.viewControllers = [ self, self.configurationViewController ]
                }
            }
        }
    }
    
    func actionDisplayInfos(sender: AnyObject){
        // println("action")
        
        performSegueWithIdentifier("FamilyBoardToInformationsSegue", sender: nil)
    }
    
    
    @IBAction func actionButtonRed(sender: AnyObject) {
        
        buttonColorRed.selected = true
        buttonColorBlue.selected = false
        buttonColorGreen.selected = false
        
    }
    
    
    @IBAction func actionButtonBlue(sender: AnyObject) {
        
        buttonColorRed.selected = false
        buttonColorBlue.selected = true
        buttonColorGreen.selected = false
    }
    
    @IBAction func actionButtonGreen(sender: AnyObject) {
        
        buttonColorRed.selected = false
        buttonColorBlue.selected = false
        buttonColorGreen.selected = true

    }
    
    @IBAction func actionButtonText1(sender: AnyObject) {
        
        txtFieldMessage.text = items[0];
    }
    
    @IBAction func actionButtonText2(sender: AnyObject) {
        txtFieldMessage.text = items[1];
    }
    
    @IBAction func actionButtonText3(sender: AnyObject) {
        txtFieldMessage.text = items[2];
    }
    
    @IBAction func actionButtonText4(sender: AnyObject) {
        txtFieldMessage.text = items[3];
    }
  
    @IBAction func actionButtonText5(sender: AnyObject) {
        txtFieldMessage.text = items[4];
    }
    
    
    // ======================================
    // MARK: - TextField Delegate function
    // ======================================
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtFieldMessage.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        txtFieldMessage.text = textField.text
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("familyboard/display", forKey:"sliderTopic")
    }

    @IBAction func actionPublishMessage(sender: AnyObject) {
        txtFieldMessage.resignFirstResponder()
        
        
        // iotDataManager.publishData(<#T##data: NSData!##NSData!#>, onTopic: topic)
        
        if (buttonColorRed.selected == true)
        {
            iotDataManager.publishString(txtFieldMessage.text! + "color=red", onTopic:topic)
        }
        else if (buttonColorBlue.selected == true)
        {
            iotDataManager.publishString(txtFieldMessage.text! + "color=blue", onTopic:topic)
        }
        else if (buttonColorGreen.selected == true)
        {
            iotDataManager.publishString(txtFieldMessage.text! + "color=green", onTopic:topic)
        }
        
    }

    // ======================================
    // MARK: - TableVIew Delegate function
    // ======================================
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("CellMessage")! as UITableViewCell
        
        
        if let theLabel = cell.viewWithTag(123) as? UILabel {
            theLabel.text = self.items[indexPath.row]
        }
        // cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Init IOT
        //
        // Set up Cognito
        //
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AwsRegion, identityPoolId: CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: AwsRegion, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        iotManager = AWSIoTManager.defaultIoTManager()
        iot = AWSIoT.defaultIoT()
        
        iotDataManager = AWSIoTDataManager.defaultIoTDataManager()
        iotData = AWSIoTData.defaultIoTData()
        
        boxMessage.hidden = true
        txtFieldMessage.hidden = true
        labelMessage.hidden = true
        buttonPublishMessage.hidden = true
        
        labelChooseColor.hidden = true
        buttonColorRed.hidden = true
        buttonColorBlue.hidden = true
        buttonColorGreen.hidden = true
        
        labelPredefinedMsg.hidden = true
        buttonText1.hidden = true
        buttonText2.hidden = true
        buttonText3.hidden = true
        buttonText4.hidden = true
        buttonText5.hidden = true
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.hidden = true
        
        let menu_button_ = UIBarButtonItem(image: UIImage(named: "infos"),
            style: UIBarButtonItemStyle.Plain ,
            target: self, action: "actionDisplayInfos:")
        
        self.navigationItem.leftBarButtonItem = menu_button_


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

