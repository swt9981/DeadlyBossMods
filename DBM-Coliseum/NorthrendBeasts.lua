local mod = DBM:NewMod("NorthrendBeasts", "DBM-Coliseum", 1)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 599 $"):sub(12, -3))
mod:SetCreatureID(34797)
mod:SetMinCombatTime(30)
mod:SetZone()

-- 34816 npc to talk to
-- 34797 npc icehowl died

mod:RegisterCombat("yell", "Hailing from the deepest, darkest caverns of the Storm Peaks, Gormok the Impaler! Battle on, heroes!")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_START",
	"SPELL_DAMAGE",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"SPELL_AURA_APPLIED_DOSE"
)

local timerBreath		= mod:NewCastTimer(5, 67650)
local timerNextStomp	= mod:NewNextTimer(20, 66330)
local timerNextImpale	= mod:NewNextTimer(10, 67477)

local warnImpaleOn		= mod:NewAnnounce("WarningImpale", 2, 67478)
local warnFireBomb		= mod:NewAnnounce("WarningFireBomb", 4, 66317)
local warnSpray			= mod:NewAnnounce("WarningSpray", 2, 67616)
local warnBreath		= mod:NewAnnounce("WarningBreath", 1, 67650)
local warnRage			= mod:NewAnnounce("WarningRage", 3, 67657)

local specWarnImpale3	= mod:NewSpecialWarning("SpecialWarningImpale3", false)
local specWarnFireBomb	= mod:NewSpecialWarning("SpecialWarningFireBomb")
local specWarnSlimePool	= mod:NewSpecialWarning("SpecialWarningSlimePool")
local specWarnSpray		= mod:NewSpecialWarning("SpecialWarningSpray")
local specWarnToxin		= mod:NewSpecialWarning("SpecialWarningToxin")
local specWarnSilence	= mod:NewSpecialWarning("SpecialWarningSilence")
local specWarnCharge	= mod:NewSpecialWarning("SpecialWarningCharge")

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 67477 or args.spellId == 66331 then
		timerNextImpale:Start()
	elseif args.spellId == 67657 then
		warnRage:Show()
	elseif args.spellId == 66823 or args.spellId == 67618 then
		if UnitName("player") == args.destName then
			specWarnToxin:Show()
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 66901 or args.spellId == 67615 then
		warnSpray:Show(args.spellName)
		-- todo: get target of spellcast
	elseif args.spellId == 67648 then
		specWarnSilence:Show()
	elseif args.spellId == 67650 then		
		timerBreath:Start()
		warnBreath:Show()
	elseif args.spellId == 66313 then		-- FireBomb (Impaler)
		warnFireBomb:Show()
	elseif args.spellId == 66330 or args.spellId == 67647 then	-- Staggering Stomp
		timerNextStomp:Start()
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	local target = msg:match(L.Charge)
	if target and target == UnitName("player") then
		specWarnCharge:Show()
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if (args.spellId == 67477 or args.spellId == 66331) and args.amount >= 3 then
		timerNextImpale:Start()
		warnImpaleOn:Show(args.spellName, args.destName)
		if UnitName("player") == args.destName then
			specWarnImpale3:Show()
		end
	end
end

function mod:SPELL_DAMAGE(args)
	if args.spellId == 66320 or args.spellId == 66317 then
		if UnitName("player") == args.destName then
			specWarnFireBomb:Show()
		end
	elseif args.spellId == 66881 and args.destName == UnitName("player") then
		specWarnSlimePool:Show()
	end
end

