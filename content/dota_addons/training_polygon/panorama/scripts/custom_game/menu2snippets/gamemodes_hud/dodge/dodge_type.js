let name=$.GetContextPanel().GetAttributeString("name", "")
let parent=$.GetContextPanel()
let SkillImage = $.CreatePanel('DOTAAbilityImage', parent, 'type_' + name)
SkillImage.abilityname = name
SkillImage.SetPanelEvent(
    "onmouseover",
    function() {
        $.DispatchEvent("DOTAShowAbilityTooltip", SkillImage, name);
    }
)
SkillImage.SetPanelEvent(
    "onmouseout",
    function() {
        $.DispatchEvent("DOTAHideAbilityTooltip", SkillImage);
    }
)