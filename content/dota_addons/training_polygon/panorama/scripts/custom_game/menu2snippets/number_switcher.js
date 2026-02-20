var numberSwitcherFieldValue=$('#numberSwitcherFieldValue')
var min=parseFloat($.GetContextPanel().GetAttributeString("min", ""))
var max=parseFloat($.GetContextPanel().GetAttributeString("max", ""))
var step=parseFloat($.GetContextPanel().GetAttributeString("step", ""))
var placeholder=parseFloat($.GetContextPanel().GetAttributeString("placeholder", ""))
numberSwitcherFieldValue.text=placeholder
$.GetContextPanel().SetAttributeString("value", numberSwitcherFieldValue.text)
$.Msg(step)

function countDecimals(value) {
    if (Math.floor(value) === value) return 0
    return value.toString().split(".")[1]?.length || 0
}

const precision = countDecimals(step)

$('#minusButton').SetPanelEvent(
    "onactivate",
    function() {
        
        var number = parseFloat(numberSwitcherFieldValue.text)
        number = parseFloat((number - step).toFixed(precision))
        if (number < min) {
            number = min
        }
        numberSwitcherFieldValue.text = number
        $.GetContextPanel().SetAttributeString("value", numberSwitcherFieldValue.text)
    }
)
$('#plusButton').SetPanelEvent(
    "onactivate",
    function() {
        var number = parseFloat(numberSwitcherFieldValue.text)
        number = parseFloat((number + step).toFixed(precision))
        if (number > max) {
            number = max
        }
        numberSwitcherFieldValue.text = number
        $.GetContextPanel().SetAttributeString("value", numberSwitcherFieldValue.text)
    }
)
/* $('#numberSwitcherField').SetPanelEvent(
    "ontextentrychange",
    function() {
        $.Msg(parseFloat(numberField.text))
    }
) */
