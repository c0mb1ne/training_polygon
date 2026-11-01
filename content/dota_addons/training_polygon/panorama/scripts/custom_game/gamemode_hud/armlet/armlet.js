$.Msg('armlet gameplay hud loaded')
var attackerInd = null

function stopTraining() {
    GameEvents.SendCustomGameEventToServer('armlet_mode_end', {})
}

function toggleFakeMod() {
    GameEvents.SendCustomGameEventToServer('armlet_mode_mod_attacker', {type: 'fm'})
}

function changeAttackSpeed(value) {
    GameEvents.SendCustomGameEventToServer('armlet_mode_mod_attacker', {type: 'as', value: value})
}

function changeAttackDamage(value) {
    GameEvents.SendCustomGameEventToServer('armlet_mode_mod_attacker', {type: 'ad', value: value})
}

function UpdateStats() {
    if (attackerInd == null || !Entities.IsValidEntity(attackerInd)) {
        return
    }
    var attackSpeed = Entities.GetAttackSpeed(attackerInd)
    var minDmg = Entities.GetDamageMin(attackerInd)
    var maxDmg = Entities.GetDamageMax(attackerInd)
    var bonusDmg = Entities.GetDamageBonus(attackerInd)
    $('#asField').text = (attackSpeed * 100).toFixed(0)
    $('#dmgField').text = Math.round((minDmg + maxDmg) / 2 + bonusDmg)
    if (Entities.IsAlive(attackerInd)) {
        $.Schedule(0.25, UpdateStats)
    }
}

function ArmletStarted(info) {
    attackerInd = info.attacker
    UpdateStats()
}

GameEvents.Subscribe('armlet_mode_started', ArmletStarted)
