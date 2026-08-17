var numberSwitcherFieldValue=$('#numberSwitcherFieldValue')
var min=parseFloat($.GetContextPanel().GetAttributeString("min", ""))
var max=parseFloat($.GetContextPanel().GetAttributeString("max", ""))
var step=parseFloat($.GetContextPanel().GetAttributeString("step", ""))
var x10control=$.GetContextPanel().GetAttributeString("x10control", "")
var x100control=$.GetContextPanel().GetAttributeString("x100control", "")
var placeholder=parseFloat($.GetContextPanel().GetAttributeString("placeholder", ""))
var onClickEvent=$.GetContextPanel().GetAttributeString("onClickEvent", "")
/* numberSwitcherFieldValue.text=placeholder */
/* $.GetContextPanel().SetAttributeString("value", numberSwitcherFieldValue.text) */
$.Msg(step)

function countDecimals(value) {
    if (Math.floor(value) === value) return 0
    return value.toString().split(".")[1]?.length || 0
}

const precision = countDecimals(step)

// Centralized setter — every change goes through here
function setValue(newValue) {
    newValue = parseFloat(newValue.toFixed(precision))
    if (newValue < min) newValue = min
    if (newValue > max) newValue = max

    var oldValue = parseFloat($.GetContextPanel().GetAttributeString("value", "0"))
    numberSwitcherFieldValue.text = newValue
    $.GetContextPanel().SetAttributeString("value", newValue)

    if (newValue !== oldValue) {
        if (onClickEvent!==""){
            GameEvents.SendCustomGameEventToServer (
            onClickEvent,
                {
                    value:newValue
                }
            );
        }
    }
}

setValue(placeholder)

if (x10control==="1"){
    $('#plusButtonx10').style['visibility']="visible;"
    $('#minusButtonx10').style['visibility']="visible;" 
    $('#minus10label').text="-"+(step * 10).toFixed(precision)
    $('#plus10label').text="+"+(step * 10).toFixed(precision)
    $('#minusButtonx10').SetPanelEvent("onactivate", function() {
        setValue(parseFloat(numberSwitcherFieldValue.text) - step * 10)
    })
    $('#plusButtonx10').SetPanelEvent("onactivate", function() {
        setValue(parseFloat(numberSwitcherFieldValue.text) + step * 10)
    })
}

if (x100control==="1"){
    $('#plusButtonx100').style['visibility']="visible;"
    $('#minusButtonx100').style['visibility']="visible;" 
    $('#minus100label').text="-"+(step * 100).toFixed(precision)
    $('#plus100label').text="+"+(step * 100).toFixed(precision)
    $('#minusButtonx100').SetPanelEvent("onactivate", function() {
        setValue(parseFloat(numberSwitcherFieldValue.text) - step * 100)
    })
    $('#plusButtonx100').SetPanelEvent("onactivate", function() {
        setValue(parseFloat(numberSwitcherFieldValue.text) + step * 100)
    })
}

$('#minusButton').SetPanelEvent("onactivate", function() {
    setValue(parseFloat(numberSwitcherFieldValue.text) - step)
})
$('#plusButton').SetPanelEvent("onactivate", function() {
    setValue(parseFloat(numberSwitcherFieldValue.text) + step)
})