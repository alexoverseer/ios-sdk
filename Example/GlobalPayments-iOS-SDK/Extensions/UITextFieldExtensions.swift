import Foundation
import UIKit

extension UITextField {

    func loadDropDownData(_ data: [String], onSelectItem: ((String) -> Void)? = nil) {
        self.inputView = DropDown(pickerData: data, dropdownField: self, onSelect: onSelectItem)
    }
}

private final class DropDown: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    private var pickerData: [String]
    private var pickerTextField: UITextField
    private var selectionHandler: ((String) -> Void)?

    init(pickerData: [String], dropdownField: UITextField) {
        self.pickerData = pickerData
        self.pickerTextField = dropdownField

        super.init(frame: .zero)

        delegate = self
        dataSource = self

        DispatchQueue.main.async {
            if pickerData.count > 0 {
                self.pickerTextField.text = self.pickerData[0]
                self.pickerTextField.isEnabled = true
            } else {
                self.pickerTextField.text = nil
                self.pickerTextField.isEnabled = false
            }
        }

        if let text = pickerTextField.text, let handler = selectionHandler {
            handler(text)
        }
    }

    convenience init(pickerData: [String], dropdownField: UITextField, onSelect: ((String) -> Void)?) {
        self.init(pickerData: pickerData, dropdownField: dropdownField)
        self.selectionHandler = onSelect
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row]

        guard let text = pickerTextField.text, let handler = selectionHandler else { return }
        handler(text)
    }
}

