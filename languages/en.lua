local shieldSetting = modvalueconfig.shieldSetting
local spearSetting = modvalueconfig.spearSetting
local helmSetting = modvalueconfig.helmSetting
local shallowGraveSetting = modvalueconfig.shallowGraveSetting
local autoSingSetting = modvalueconfig.autoSingSetting
local unfetteredSetting = modvalueconfig.unfetteredSetting
local slaughterSetting = modvalueconfig.slaughterSetting
local shadowSetting = modvalueconfig.shadowSetting
local lunarSetting = modvalueconfig.lunarSetting

STRINGS.ACTIONS.USESPEAROARTOOL = "Spoar Transfer"
STRINGS.ACTIONS.USESHIELDBOATTOOL = "RöndBoat Transfer"
STRINGS.ACTIONS.BOATDISMANTLED = "Call In The Fleet"
STRINGS.ACTIONS.CALLLIST = "Call Sentinel"
STRINGS.ACTIONS.CONCATLIST = "Concat List"

STRINGS.NAMES.OAR_WATHGRITHR_LIGHTNING = "Elding Oar"
STRINGS.NAMES.OAR_WATHGRITHR_LIGHTNING_CHARGED = "Charged Elding Oar"
STRINGS.NAMES.BOAT_BUTTON = "Battle Boat"
STRINGS.NAMES.BOAT_SHIELD = "Battle Boat"
STRINGS.NAMES.BOAT_SHIELD_DEPLOYER = "Battle Boat Kit"
STRINGS.NAMES.BEEFALO_CASTER_BATTLE = "Beefalo Sentinel"
STRINGS.NAMES.BEEFALO_CASTER_WALK = "Beefalo Rover"
STRINGS.NAMES.BEEFALODEATHLIST = "Death List"
STRINGS.NAMES.BEEFALO_SHAKE_BASIC = "Keen-eyed"
STRINGS.NAMES.BEEFALO_SHAKE_WAR = "Vast"
STRINGS.NAMES.BEEFALO_SHAKE_DOLL = "Greedy"
STRINGS.NAMES.BEEFALO_SHAKE_FESTIVE = "Quickened"
STRINGS.NAMES.BEEFALO_SHAKE_NATURE = "Timeless"
STRINGS.NAMES.BEEFALO_SHAKE_ROBOT = "Tough"
STRINGS.NAMES.BEEFALO_SHAKE_ICE = "Feverish"
STRINGS.NAMES.BEEFALO_SHAKE_FORMAL = "Brawny"
STRINGS.NAMES.BEEFALO_SHAKE_VICTORIAN = "Mystical"
STRINGS.NAMES.BEEFALO_SHAKE_BEAST = "Alert"
STRINGS.NAMES.HELM_GNARWAIL = "Gnarwail Dominated by Helm of the Overlord"
STRINGS.NAMES.HELM_POLLY_ROGERS = "Polly Roger Dominated by Helm of the Overlord"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOAT_BUTTON = "As strong as a shield."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOAT_SHIELD = "As strong as a shield."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALODEATHLIST = "A list of how many Beefalos have been killed."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.BEEFALODEATHLIST = "A list of how many Beefalos have been tamed."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.HELM_GNARWAIL = "It has a sharp horn on its head, just like my helm."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.HELM_GNARWAIL = "A marine bard with horns on its head."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_BASIC = "Keen-eyed Madstone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_WAR = "Vast Madstone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_DOLL = "Greedy Madstone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_FESTIVE = "Quickened Madstone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_NATURE = "Timeless Madstone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_ROBOT = "Tough Madstone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_ICE = "Feverish Madstone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_FORMAL = "Brawny Madstone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_VICTORIAN = "Mystical Madstone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_SHAKE_BEAST = "Alert Madstone!"

STRINGS.CHARACTERS.GENERIC.ANNOUNCE_BEEFALO_FLEE = "Beefalo ran away!!!"
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_BEEFALO_DIE = "My Beefalo dead!!!"
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_BEEFALO_KILL = {
    "\"The more my wrong, the more my spite.\"",
    "\"I’ll tame you for your good!\"",
    "\"You’re like a piece of wrought iron; you must be hammered into shape.\"",
    "Taming so easy!",
    "You become responsible, forever, for what you have tamed!",
    "To tame is to establish ties!",
}
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_BEEFALO_CAST = {
    "\"It’s a bloody business.\"",
    "\"Blood is the price of power.\"",
    "\"Blood will have blood.\"",
    "\"If you prick us, do we not bleed?\"",
    "\"The quality of mercy is not strained.\"",
}
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_BEEFALO_COME = {
    "\"Life’s but a walking shadow, a poor player that struts and frets his hour upon the stage!\"",
    "\"Come, you spirits that tend on mortal thoughts, unsex me here!\"",
    "\"The wheel is come full circle!\"",
    "\"The past is a prologue.\"",
    "\"The phoenix rising from the ashes.\"",
    "\"This is the very painting of your fear.\"",
    "\"Death is not the opposite of life, but a part of it.\"",
}
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_ATTACK_THRESHOLD = "Beefalo HELP!!!"
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_BOAT_DISMANTLE = "Someone else is on the boat!!!"
STRINGS.CHARACTERS.WATHGRITHR.ANNOUNCE_BOAT_DISMANTLE = {
    "No Viking leaves anyone behind on the boat!!!",
    "Useless, they can't even steer it!!!"
}
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_GNARWAIL_COME = {
    "Its horn gleams! It's blinding me!",
    "Music? Only Gnarwails understand it!",
    "The ocean's musician! It's one of a kind!",
    "That horn! Fierce and unyielding!",
    "Gnarwails hear melodies we can't even imagine!",
    "Music connects us, whether we like it or not!",
    "Its horn, just like my helmet, is a symbol of power!",
    "Play the music, and the Gnarwail will dance!",
    "As soon as the music starts, even the shyest Gnarwail shows up!"
}
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_GNARWAIL_GO = {
    "Once the music stops, the Gnarwail's dance ends!",
    "Its silhouette vanishes! Only silence remains!",
    "The horn fades into the horizon!",
    "The melody turns into nothing but ripples!",
    "Music ends, reflection begins!",
    "Gnarwail swims away! Leaving emptiness behind!",
    "Its song drifts off, whispering a final goodbye!",
    "The magic fades! The Gnarwail is gone!"
}
STRINGS.CHARACTERS.WATHGRITHR.ANNOUNCE_BATTLESONG_INSTANT_SHADOW_BUFF = {
    "Darkness falls! My heart is hollow!",
    "A sorrowful song plays, and the night deepens!",
    "In this endless dark, pain is my only company!",
    "Lost in the abyss! Only torment remains!",
    "I long to sink deeper, to escape this agony!"
}
STRINGS.CHARACTERS.WATHGRITHR.ANNOUNCE_BATTLESONG_INSTANT_LUNAR_BUFF = {
    "Drifting in the ocean of dreams!",
    "The cradle rocks! Off to the stars!",
    "In the moonlight, the soul floats!",
    "Silent steps into the edge of dreams!",
    "Wandering through dreams, seeking the lost self!"
}

if shieldSetting then
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ARSENAL_SHIELD_3_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ARSENAL_SHIELD_3_DESC ..
    "\nCan be used as an extremely strong, recyclable little boat."
end
if spearSetting then
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ARSENAL_SPEAR_5_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ARSENAL_SPEAR_5_DESC ..
    "\nCan be used as an extremely efficient oar, can knock off monkeys into the water."
end
if helmSetting then
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ARSENAL_HELMET_5_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ARSENAL_HELMET_5_DESC ..
    "\nCan operate the boat and its equipment more durably and flexibly, and dominate a Gnarwail to protect it."
end
if shallowGraveSetting then
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_SONGS_REVIVEWARRIOR_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_SONGS_REVIVEWARRIOR_DESC ..
    "\nWhen living allies are about to die, converting damage into healing for an encore performance."
end
if autoSingSetting then
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_SONGS_CONTAINER_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_SONGS_CONTAINER_DESC ..
    "\nPermanently gains 3 slots for Battle Songs, automatically performing corresponding songs when conditions are met."
end
if unfetteredSetting then
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_SONGS_INSTANTSONG_CD_DESC = "Performing Battle Stingers no longer requires minimum inspiration." ..
    "\nIf inspiration is insufficient, a compensation cooldown will activate.\nOverflowing inspiration accelerates cooldown recovery."
end
if slaughterSetting then
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_BEEFALO_SADDLE_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_BEEFALO_SADDLE_DESC ..
    "\nAlso give the Beefalo Sentinels a stronger saddle. Wigfrid enrages if a Sentinel dies."
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_BEEFALO_3_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_BEEFALO_3_DESC ..
    "\nThe same applies when you become the lead Beefalo."
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_BEEFALO_2_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_BEEFALO_2_DESC ..
    "\nExtends the duration of Beefalo Sentinels as well."
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_BEEFALO_1_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_BEEFALO_1_DESC ..
    "\nRecord killed Beefalo in the list to command them for protection and speed boost."
end
if shadowSetting then
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ALLEGIANCE_SHADOW_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ALLEGIANCE_SHADOW_DESC ..
    "The gloom melody of the Dark Lament can cause enemies to self-harm when attacking Wigfrid."
end
if lunarSetting then
    STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ALLEGIANCE_LUNAR_DESC = STRINGS.SKILLTREE.WATHGRITHR.WATHGRITHR_ALLEGIANCE_LUNAR_DESC ..
    "The ethereal melody of the Enlightened Lullaby makes enemies sleep and sleepwalk."
end