var skill_name=$.GetContextPanel().GetAttributeString("skill_name", "")

var id=$.GetContextPanel().GetAttributeInt("id", 0)

var select_controller = $.CreatePanel('Panel', $.GetContextPanel(), 'primary_skill_selector_' + id)
$('#prim_skill_img').abilityname=skill_name


$('#prim_skill_check').SetPanelEvent (
	"onselect", 
	function() {
		select_controller.AddClass("selected")
	}
)
$('#prim_skill_check').SetPanelEvent (
	"ondeselect", 
	function() {
		select_controller.RemoveClass("selected")
	}
)