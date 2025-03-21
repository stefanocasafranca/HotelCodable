
import UIKit

class AddRegistrationTableViewController: UITableViewController, SelectRoomTypeTableViewControllerDelegate {
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var checkInDateLabel: UILabel!
    //New term or Type: UIDatePicker
    @IBOutlet var checkInDatePicker: UIDatePicker!
    @IBOutlet var checkOutDateLabel: UILabel!
    @IBOutlet var checkOutDatePicker: UIDatePicker!
    @IBOutlet var numberOfAdultsLabel: UILabel!
    //New term or Type: UIStepper
    @IBOutlet var numberOfAdultsStepper: UIStepper!
    @IBOutlet var numberOfChildrenLabel: UILabel!
    @IBOutlet var numberOfChildrenStepper: UIStepper!
    //New term or Type: UISwitch
    @IBOutlet var wifiSwitch: UISwitch!
    @IBOutlet var roomTypeLabel: UILabel!
    //New term or Type: UIBarButtonItem
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!
    
    // MARK: Charges Section Outlets
    
    @IBOutlet var chargesNumberOfNightsLabel: UILabel!
    @IBOutlet var chargesNumberOfNightsDetailLabel: UILabel!
    @IBOutlet var chargesRoomRateLabel: UILabel!
    @IBOutlet var chargesRoomTypeLabel: UILabel!
    @IBOutlet var chargesWifiRateLabel: UILabel!
    @IBOutlet var chargesWifiDetailLabel: UILabel!
    @IBOutlet var chargesTotalLabel: UILabel!
    
    
    
    let checkInDateLabelCellIndexPath = IndexPath(row: 0, section: 1)
    //Here the picker
    let checkInDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    
    let checkOutDateLabelCellIndexPath = IndexPath(row: 2, section: 1)
    //Here the picker again
    let checkOutDatePickerCellIndexPath = IndexPath(row: 3, section: 1)

    
    //ONLY THIS MAKES THE PICKER TO BE HIDDEN BUT BUGGY
    //var isCheckInDatePickerVisible = false
   // var isCheckOutDatePickerVisible = false

    //This makes it smooth and to hide elegantly

    var isCheckInDatePickerVisible : Bool = false {
        didSet {
            checkInDatePicker.isHidden = !isCheckInDatePickerVisible
        }
    }
    
    
     var isCheckOutDatePickerVisible: Bool = false {
       didSet {
       checkOutDatePicker.isHidden = !isCheckOutDatePickerVisible
        }
    }
    
    var roomType: RoomType?
    
    var registration: Registration? {
        guard let roomType = roomType,
              //unwraps the text field + Var Shadowing
              let firstName = firstNameTextField.text,
                // Checks if its not empty
                !firstName.isEmpty,
              
              //unwraps the text field + Var Shadowing
              let lastName = lastNameTextField.text,
              // Checks if its not empty
                !lastName.isEmpty
        
        else { return nil } // it does not let to register anything till Name and Last name is set up
        
        let email = emailTextField.text ?? "" //Return an empty string...so make it the only optional
        let checkInDate = checkInDatePicker.date
        let checkOutDate = checkOutDatePicker.date
        let numberOfAdults = Int(numberOfAdultsStepper.value)
        let numberOfChildren = Int(numberOfChildrenStepper.value)
        let hasWifi = wifiSwitch.isOn
        
        //Returning all the new registration variables stored in a single registration struct
        return Registration(firstName: firstName,
                            lastName: lastName,
                            emailAddress: email,
                            checkInDate: checkInDate,
                            checkOutDate: checkOutDate,
                            numberOfAdults: numberOfAdults,
                            numberOfChildren: numberOfChildren,
                            roomType: roomType,
                            wifi: hasWifi)
    }
    
    //It holds existing registration data if you’re editing; if it’s nil, you’re creating a new one.
    var existingRegistration: Registration?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If there's an existing registration, we are in "edit/view" mode.
        if let existingRegistration = existingRegistration {
            // Set the screen title to indicate we're viewing a guest registration.
            title = "View Guest Registration"
            // Disable the Done button initially (possibly until some edits occur).
            doneBarButtonItem.isEnabled = false
            // Pre-fill the form fields with data from the existing registration.
            roomType = existingRegistration.roomType
            firstNameTextField.text = existingRegistration.firstName
            lastNameTextField.text = existingRegistration.lastName
            emailTextField.text = existingRegistration.emailAddress
            checkInDatePicker.date = existingRegistration.checkInDate
            checkOutDatePicker.date = existingRegistration.checkOutDate
            numberOfAdultsStepper.value = Double(existingRegistration.numberOfAdults)
            numberOfChildrenStepper.value = Double(existingRegistration.numberOfChildren)
            wifiSwitch.isOn = existingRegistration.wifi
        } else {
            // If no existing registration, configure the check-in date picker for a new registration.
            //MAKING IT MANAGEABLE TO PICK THE DATE AFTER TODAY, NOT BACKWARDS
            let midnightToday = Calendar.current.startOfDay(for: Date())
            // Set the minimum check-in date to today.
            checkInDatePicker.minimumDate = midnightToday
            // Set the default check-in date to today.
            checkInDatePicker.date = midnightToday
        }

        //Activate the whole functions from the bottom
        updateDateViews()
        updateNumberOfGuests()
        updateRoomType()
        updateChargesSection()
    }
    
    
    //Date Update
    func updateDateViews() {
        checkOutDatePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: checkInDatePicker.date)
        checkInDateLabel.text = checkInDatePicker.date.formatted(date: .abbreviated, time: .omitted)
        checkOutDateLabel.text = checkOutDatePicker.date.formatted(date: .abbreviated, time: .omitted)
    }
    
    //Steppers + -
    func updateNumberOfGuests() {
        numberOfAdultsLabel.text = "\(Int(numberOfAdultsStepper.value))"
        numberOfChildrenLabel.text = "\(Int(numberOfChildrenStepper.value))"
    }
    
    //RoomType
    func updateRoomType() {
        if let roomType = roomType {
            roomTypeLabel.text = roomType.name
        } else {
            roomTypeLabel.text = "Not Set"
        }
        //DONE BUTTON GETS ACTIVATED WHEN ...

        doneBarButtonItem.isEnabled = existingRegistration == nil && registration != nil
    }
    
    func updateChargesSection() {
        let dateComponents = Calendar.current.dateComponents([.day], from: checkInDatePicker.date, to: checkOutDatePicker.date)
        let numberOfNights = dateComponents.day ?? 0
        
        chargesNumberOfNightsLabel.text = "\(numberOfNights)"
        chargesNumberOfNightsDetailLabel.text = "\(checkInDatePicker.date.formatted(date: .abbreviated, time: .omitted)) - \(checkOutDatePicker.date.formatted(date: .abbreviated, time: .omitted))"
        
        let roomRateTotal: Int
        if let roomType = roomType {
            roomRateTotal = roomType.price * numberOfNights
            chargesRoomRateLabel.text = "$ \(roomRateTotal)"
            chargesRoomTypeLabel.text = "\(roomType.name) @ $\(roomType.price)/night"
        } else {
            roomRateTotal = 0
            chargesRoomRateLabel.text = "--"
            chargesRoomTypeLabel.text = "--"
        }
        
        
        let wifiTotal: Int
        if wifiSwitch.isOn {
            wifiTotal = 10 * numberOfNights
        } else {
            wifiTotal = 0
        }
        chargesWifiRateLabel.text = "$ \(wifiTotal)"
        chargesWifiDetailLabel.text = wifiSwitch.isOn ? "Yes" : "No"
        
        chargesTotalLabel.text = "$ \(roomRateTotal + wifiTotal)"
    }
    
    //DONE BUTTON GETS ACTIVATED WHEN ...
    @IBAction func nameTextFieldChanged(_ sender: UITextField) {
        doneBarButtonItem.isEnabled = existingRegistration == nil && registration != nil
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
        updateChargesSection()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateNumberOfGuests()
        updateChargesSection()
    }
    
    @IBAction func wifiSwitchChanged(_ sender: UISwitch) {
        updateChargesSection()
    }
    
    @IBSegueAction func selectRoomType(_ coder: NSCoder) -> SelectRoomTypeTableViewController? {
        
        let selectRoomTypeController = SelectRoomTypeTableViewController(coder: coder)
        selectRoomTypeController?.delegate = self
        selectRoomTypeController?.roomType = roomType
        
        return selectRoomTypeController
    }
    
    @IBAction func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case checkInDatePickerCellIndexPath where isCheckInDatePickerVisible == false:
            return 0
        case checkOutDatePickerCellIndexPath where isCheckOutDatePickerVisible == false:
            return 0
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case checkInDatePickerCellIndexPath:
            return 190
        case checkOutDatePickerCellIndexPath:
            return 190
        default:
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == checkInDateLabelCellIndexPath && isCheckOutDatePickerVisible == false {
            // check-in label selected, check-out picker is not visible, toggle check-in picker
            isCheckInDatePickerVisible.toggle()
        } else if indexPath == checkOutDateLabelCellIndexPath && isCheckInDatePickerVisible == false {
            // check-out label selected, check-in picker is not visible, toggle check-out picker
            isCheckOutDatePickerVisible.toggle()
        } else if indexPath == checkInDateLabelCellIndexPath || indexPath == checkOutDateLabelCellIndexPath {
            // either label was selected, previous conditions failed meaning at least one picker is visible, toggle both
            isCheckInDatePickerVisible.toggle()
            isCheckOutDatePickerVisible.toggle()
        } else {
            return
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - SelectRoomTypeTableViewControllerDelegate
    
    func selectRoomTypeTableViewController(_ controller: SelectRoomTypeTableViewController, didSelect roomType: RoomType) {
        self.roomType = roomType
        updateRoomType()
        updateChargesSection()
    }
}
