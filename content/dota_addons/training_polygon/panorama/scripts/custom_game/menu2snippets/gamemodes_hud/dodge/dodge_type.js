let name=$.GetContextPanel().GetAttributeString("name", "")
let parent=$.GetContextPanel()
let SkillImage = $.CreatePanel('DOTAAbilityImage', parent, 'type_' + name)
SkillImage.abilityname = name