if ( TukuiUF ~= true and ( TukuiCF == nil or TukuiCF["unitframes"] == nil or not TukuiCF["unitframes"]["enable"] ) ) then return; end

--[[ Configuration functions - DO NOT TOUCH
	id - spell id
	castByAnyone - show if aura wasn't created by player
	color - bar color (nil for default color)
	unitType - 0 all, 1 friendly, 2 enemy
	castSpellId - fill only if you want to see line on bar that indicates if its safe to start casting spell and not clip the last tick, also note that this can be different from aura id 
]]--
local CreateSpellEntry = function( id, castByAnyone, color, unitType, castSpellId )
	return { id = id, castByAnyone = castByAnyone, color = color, unitType = unitType or 0, castSpellId = castSpellId };
end

local CreateColor = function( red, green, blue, alpha )
	return { red / 255, green / 255, blue / 255, alpha };
end

-- Configuration starts here:

-- Bar height
local BAR_HEIGHT = 20;

-- Distance between bars
local BAR_SPACING = 1;

--[[ Layouts
	1 - both player and target auras in one frame right above player frame
	2 - player and target auras separated into two frames above player frame
	3 - player, target and trinket auras separated into three frames above player frame
	4 - player and trinket auras are shown above player frame and target auras are shown above target frame
]]--
local LAYOUT = 3;

-- Background alpha (range from 0 to 1)
local BACKGROUND_ALPHA = 0.75;

--[[ Show icons outside of frame (flags - that means you can combine them - for example 3 means it will be outside the right edge)
	0 - left
	1 - right
	2 - outside
	4 - hide
]]--
local ICON_POSITION = 0;

-- Icon overlay color
local ICON_COLOR = CreateColor( 120, 120, 120, 1 );

-- Show spark
local SPARK = false;

-- Show cast separator
local CAST_SEPARATOR = true;

-- Sets cast separator color
local CAST_SEPARATOR_COLOR = CreateColor( 0, 0, 0, 0.5 );

-- Sets distance between right edge of bar and name and left edge of bar and time left
local TEXT_MARGIN = 5;

local MASTER_FONT, STACKS_FONT;
if ( TukuiCF and TukuiCF["media"] and TukuiCF["media"]["uffont"] ) then
	-- Sets font for all texts
	MASTER_FONT = { TukuiCF["media"]["uffont"], 12, "OUTLINE" };

	-- Sets font for stack count
	STACKS_FONT = { TukuiCF["media"]["uffont"], 11, "OUTLINE" };
else
	-- Sets font for all texts
	MASTER_FONT = { [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=], 12, "OUTLINE" };

	-- Sets font for stack count
	STACKS_FONT = { [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=], 11, "OUTLINE" };
end

--[[ Permanent aura bars
	1 filled 		
	0 empty
]]--
local PERMANENT_AURA_VALUE = 1;

--[[ Player bar color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local PLAYER_BAR_COLOR = CreateColor( 70, 70, 150, 1 );

--[[ Player debuff color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local PLAYER_DEBUFF_COLOR = nil;

--[[ Target bar color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local TARGET_BAR_COLOR = CreateColor( 70, 150, 70, 1 );

--[[ Target debuff color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local TARGET_DEBUFF_COLOR = CreateColor( 150, 70, 70, 1 );

--[[ Trinket bar color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local TRINKET_BAR_COLOR = CreateColor( 150, 150, 70, 1 );

--[[ Sort direction
	false - ascending
	true - descending
]]--
local SORT_DIRECTION = true;

-- Timer tenths threshold - range from 1 to 60
local TENTHS_TRESHOLD = 1

-- Trinket filter - mostly for trinket procs, delete or wrap into comment block --[[  ]] if you dont want to track those
local TRINKET_FILTER = {
		CreateSpellEntry( 67671 ), -- Fury(Banner of Victory)
		CreateSpellEntry( 71564 ), -- Deadly Precision (Nevermelting Ice Crystal)
		CreateSpellEntry( 67669 ), -- Elusive Power (Abyssal Rune)
		
		CreateSpellEntry( 60229 ), -- Greatness (Greatness - Strength)
		CreateSpellEntry( 60233 ), -- Greatness (Greatness - Agility)
		CreateSpellEntry( 60234 ), -- Greatness (Greatness - Intellect)
		CreateSpellEntry( 60235 ), -- Greatness (Greatness - Spirit)
		
		CreateSpellEntry( 67703 ), CreateSpellEntry( 67708 ), CreateSpellEntry( 67772 ), CreateSpellEntry( 67773 ), -- Paragon (Death Choice)
		CreateSpellEntry( 67684 ), -- Hospitality (Talisman of Resurgence)
		
		CreateSpellEntry( 71432 ), -- Mote of Anger (Tiny Abomination in a Jar)	
		CreateSpellEntry( 71485 ), CreateSpellEntry( 71556 ), -- Agility of the Vrykul (Deathbringer's Will)
		CreateSpellEntry( 71492 ), CreateSpellEntry( 71560 ), -- Speed of the Vrykul (Deathbringer's Will)
		CreateSpellEntry( 71487 ), CreateSpellEntry( 71557 ), -- Precision of the Iron Dwarves (Deathbringer's Will)
		CreateSpellEntry( 71491 ), CreateSpellEntry( 71559 ), -- Aim of the Iron Dwarves (Deathbringer's Will)
		CreateSpellEntry( 71486 ), CreateSpellEntry( 71558 ), -- Power of the Taunka (Deathbringer's Will)
		CreateSpellEntry( 71484 ), CreateSpellEntry( 71561 ), -- Strength of the Taunka (Deathbringer's Will)
		CreateSpellEntry( 71570 ), CreateSpellEntry( 71572 ), -- Cultivated Power (Muradin's Spyglass)
		CreateSpellEntry( 71605 ), CreateSpellEntry( 71636 ), -- Phylactery of the Nameless Lich
		CreateSpellEntry( 71401 ), CreateSpellEntry( 71541 ), -- Icy Rage (Whispering Fanged Skull)
		CreateSpellEntry( 71396 ), -- Herkuml War Token
		CreateSpellEntry( 72412 ), -- Frostforged Champion (Ashen Band of Unmatched/Endless Might/Vengeance)
		CreateSpellEntry( 72414 ), -- Frostforged Defender (Ashen Band of Courage)
		CreateSpellEntry( 72416 ), -- Frostforged Sage (Ashen Band of Destruction/Wisdom)
	
		CreateSpellEntry( 59626 ), -- Black Magic
		CreateSpellEntry( 54758 ), -- Hyperspeed Acceleration (Hyperspeed Accelerators)
		CreateSpellEntry( 55637 ), -- Lightweave
		CreateSpellEntry( 59620 ), -- Berserking
		
		CreateSpellEntry( 2825, true ), CreateSpellEntry( 32182, true ), -- Bloodlust/Heroism
		CreateSpellEntry( 90355, true ), -- Ancient Hysteria, bloodlust from hunters pet
		CreateSpellEntry( 26297 ), -- Berserking (troll racial)
		CreateSpellEntry( 33702 ), CreateSpellEntry( 33697 ), CreateSpellEntry( 20572 ), -- Blood Fury (orc racial)
		CreateSpellEntry( 57933 ), -- Tricks of Trade (15% dmg buff)
		
		CreateSpellEntry( 67694 ), -- Defensive Tactics (Glyph of Indomitability)
		CreateSpellEntry( 67699 ), CreateSpellEntry( 67753 ), -- Fortitude (Juggernaut's Vitality/Satrina's Impeding Scarab)
		CreateSpellEntry( 71586 ), -- Hardened Skin (Corroded Skeleton Key)
		
		CreateSpellEntry( 75465 ), CreateSpellEntry( 75474 ), -- Twilight Flames (Charred Twilight Scale)
		CreateSpellEntry( 71602 ), CreateSpellEntry( 71644 ), -- Surge of Power (Dislodged Foreign Object)
	};
	
--[[ Class specific filters

Examples:

	Track "Frost Fever" and "Blood Plague" on target and "Bone Shield" on player:
	
		DEATHKNIGHT = { 
			target = { 
				CreateSpellEntry( "Frost Fever" ),
				CreateSpellEntry( "Blood Plague" ),
			},
			player = { 
				CreateSpellEntry( "Bone Shield" ),
			}
		},

	Track "Frost Fever" and "Blood Plague" on target and nothing on player:
	
		DEATHKNIGHT = { 
			target = { 
				CreateSpellEntry( "Frost Fever" ),
				CreateSpellEntry( "Blood Plague" ),
			},
		},

	Track nothing on target and nothing on player:
	
		DEATHKNIGHT = { 

		},
		
	or
	
				
		
		( ^^^ yes nothing ^^^ )
]]--

local CLASS_FILTERS = {
		DEATHKNIGHT = { 
			target = {
				CreateSpellEntry( 55095 ), -- Frost Fever
				CreateSpellEntry( 55078 ), -- Blood Plague
				CreateSpellEntry( 81130 ), -- Scarlet Fever
				CreateSpellEntry( 50536 ), -- Unholy Blight
				CreateSpellEntry( 65142 ), -- Ebon Plague
 
			},
			player = {
				CreateSpellEntry( 59052 ), -- Freezing Fog
				CreateSpellEntry( 51124 ), -- Killing Machine
				CreateSpellEntry( 49016 ), -- Unholy Frenzy
				CreateSpellEntry( 57330 ), -- Horn of Winter
				CreateSpellEntry( 70654 ), -- Blood Armor
				CreateSpellEntry( 77535 ), -- Blood Shield
				CreateSpellEntry( 55233 ), -- Vampiric Blood
				CreateSpellEntry( 81141 ), -- Blood Swarm
				CreateSpellEntry( 45529 ), -- Blood Tap
				CreateSpellEntry( 49222 ), -- Bone sheild
				CreateSpellEntry( 48792 ), -- Ice Bound Fortitude
				CreateSpellEntry( 49028 ), -- Dancing Rune Weapon
				CreateSpellEntry( 51271 ), -- Pillar of Frost
				CreateSpellEntry( 48707 ), -- Anti-Magic Shell
			},
			procs = {
				CreateSpellEntry( 53365 ), -- Unholy Strength
				CreateSpellEntry( 64856 ), -- Blade barrier
				CreateSpellEntry( 70657 ), -- Advantage
				CreateSpellEntry( 81340 ), -- Sudden Doom
			}		},
		DRUID = { 
			target = { 
				CreateSpellEntry( 48438 ), -- Wild Growth
				CreateSpellEntry( 774 ), -- Rejuvenation
				CreateSpellEntry( 8936, false, nil, nil, 8936 ), -- Regrowth
				CreateSpellEntry( 33763 ), -- Lifebloom
				CreateSpellEntry( 5570 ), -- Insect Swarm
				CreateSpellEntry( 8921 ), -- Moonfire
				CreateSpellEntry( 339 ), -- Entangling Roots
				CreateSpellEntry( 33786 ), -- Cyclone
				CreateSpellEntry( 2637 ), -- Hibernate
				CreateSpellEntry( 2908 ), -- Soothe
				CreateSpellEntry( 50259 ), -- Feral Charge (Cat) - daze
				CreateSpellEntry( 45334 ), -- Feral Charge (Bear) - immobilize
				CreateSpellEntry( 58180 ), -- Infected Wounds
				CreateSpellEntry( 6795 ), -- Growl
				CreateSpellEntry( 5209 ), -- Challenging Roar
				CreateSpellEntry( 99 ), -- Demoralizing Roar
				CreateSpellEntry( 33745 ), -- Lacerate
				CreateSpellEntry( 5211 ), -- Bash
				CreateSpellEntry( 80964 ), -- Skull Bash (Bear)
				CreateSpellEntry( 80965 ), -- Skull Bash (Cat)
				CreateSpellEntry( 22570 ), -- Maim
				CreateSpellEntry( 1822 ), -- Rake
				CreateSpellEntry( 1079 ), -- Rip
				CreateSpellEntry( 33878, true ), -- Mangle (Bear)
				CreateSpellEntry( 33876, true ), -- Mangle (Cat)
				CreateSpellEntry( 9007 ), -- Pounce bleed
				CreateSpellEntry( 9005 ), -- Pounce stun
				CreateSpellEntry( 16857, true ), -- Faerie Fire (Feral)
				CreateSpellEntry( 770, true ), -- Farie Fire
				CreateSpellEntry( 467 ), -- Thorns
				CreateSpellEntry( 78675 ), -- Solar Beam
				CreateSpellEntry( 93402 ), -- Sunfire
			},
			player = {
				CreateSpellEntry( 48505 ), -- Starfall
				CreateSpellEntry( 29166 ), -- Innervate
				CreateSpellEntry( 22812 ), -- Barkskin
				CreateSpellEntry( 5215 ), -- Prowl
				CreateSpellEntry( 16689 ), -- Nature's Grasp
				CreateSpellEntry( 17116 ), -- Nature's Swiftness
				CreateSpellEntry( 5229 ), -- Enrage
				CreateSpellEntry( 52610 ), -- Savage Roar
				CreateSpellEntry( 5217 ), -- Tiger's Fury
				CreateSpellEntry( 1850 ), -- Dash
				CreateSpellEntry( 22842 ), -- Frenzied Regeneration
				CreateSpellEntry( 50334 ), -- Berserk
				CreateSpellEntry( 61336 ), -- Survival Instincts
				CreateSpellEntry( 48438 ), -- Wild Growth
				CreateSpellEntry( 774 ), -- Rejuvenation
				CreateSpellEntry( 8936, false, nil, nil, 8936 ), -- Regrowth
				CreateSpellEntry( 33763 ), -- Lifebloom
				CreateSpellEntry( 467 ), -- Thorns
				CreateSpellEntry( 80951 ), -- Pulverize
			},
			procs = {
				CreateSpellEntry( 16870 ), -- Clearcasting
				CreateSpellEntry( 48518 ), -- Eclipse Lunar
				CreateSpellEntry( 48517 ), -- Eclipse Solar
				CreateSpellEntry( 69369 ), -- Predator's Swiftness
				CreateSpellEntry( 93400 ), -- Shooting Stars
				CreateSpellEntry( 81192 ), -- Lunar Shower
 
			},
			procs = {		

			}
		},
		HUNTER = { 
			target = {
				CreateSpellEntry( 49050 ), -- Aimed Shot
				CreateSpellEntry( 1978 ), -- Serpent Sting
				CreateSpellEntry( 53238 ), -- Piercing Shots
				CreateSpellEntry( 3674 ), -- Black Arrow
				CreateSpellEntry( 82654 ), -- Widow Venom
				CreateSpellEntry( 34490 ), -- Silencing Shot
				CreateSpellEntry( 37506 ), -- Scatter Shot
				CreateSpellEntry( 53243 ), -- Marker for death, need to be changed I think
				CreateSpellEntry( 1130 ), -- Hunters mark
			},
			player = {
				CreateSpellEntry( 82749 ), -- killing streak
				CreateSpellEntry( 3045 ), -- Rapid Fire
				CreateSpellEntry( 34471 ), --The beast within
			},
			procs = {
				CreateSpellEntry( 53257 ), -- cobra strikes 
				CreateSpellEntry( 6150 ), -- Quick Shots
				CreateSpellEntry( 56453 ), -- Lock and Load
				CreateSpellEntry( 82692 ), --Focus Fire
				CreateSpellEntry( 35099 ), --Rapid Killing Rank 2
				CreateSpellEntry( 53220 ), -- Improved Steadyshot
				CreateSpellEntry( 70728 ), -- Exploit Weakness (2pc t10)
				CreateSpellEntry( 71007 ), -- Stinger (4pc t10)
			},
		},
		MAGE = {
			target = { 
				CreateSpellEntry( 44457 ), -- Living Bomb
				CreateSpellEntry( 118 ), -- Polymorph
				CreateSpellEntry( 28271 ), -- Polymorph Turtle
				CreateSpellEntry( 31589 ), -- Slow
				CreateSpellEntry( 116 ), -- Frostbolt
				CreateSpellEntry( 120 ), -- Cone of Cold
				CreateSpellEntry( 122 ), -- Frost Nova
				CreateSpellEntry( 44614 ), -- Frostfire Bolt
				CreateSpellEntry( 92315 ), -- Pyroblast!
				CreateSpellEntry( 12654 ), -- Ignite
				CreateSpellEntry( 22959 ), -- Critical Mass
				CreateSpellEntry( 83853 ), -- Combustion
				CreateSpellEntry( 31661 ), -- Dragon's Breath
				CreateSpellEntry( 83154 ), -- Piercing Chill
				CreateSpellEntry( 44572 ), -- Deep Freeze
			},
			player = {
				CreateSpellEntry( 36032 ), -- Arcane Blast
				CreateSpellEntry( 12042 ), -- Arcane Power
				CreateSpellEntry( 32612 ), -- Invisibility
				CreateSpellEntry( 1463 ), -- Mana Shield
				CreateSpellEntry( 543 ), -- Mage Ward
				CreateSpellEntry( 11426 ), -- Ice Barrier
				CreateSpellEntry( 45438 ), -- Ice Block
				CreateSpellEntry( 12472 ), -- Icy Veins
				CreateSpellEntry( 130 ), -- Slow Fall
				CreateSpellEntry( 57761 ), -- Brain Freeze
			},
			procs = {
				CreateSpellEntry( 44544 ), -- Fingers of Frost
				CreateSpellEntry( 79683 ), -- Arcane Missiles!
				CreateSpellEntry( 48108 ), -- Hot Streak
				CreateSpellEntry( 64343 ), -- Impact
				CreateSpellEntry( 83582 ), -- Pyromaniac
				CreateSpellEntry( 70753 ), -- Pushing the Limit (2pc t10)
				CreateSpellEntry( 70747 ), -- Quad Core (4pc t10)
			},
		},
		PALADIN = { 
			target = {
                CreateSpellEntry( 31803 ), -- Censure --
                CreateSpellEntry( 20066 ), -- Repentance --
                CreateSpellEntry( 853 ), -- Hammer of Justice --
                CreateSpellEntry( 31935 ), -- Avenger's Shield --
                CreateSpellEntry( 20170 ), -- Seal of Justice --
                CreateSpellEntry( 26017 ), -- Vindication --
                CreateSpellEntry( 68055 ), -- Judgements of the Just --
				CreateSpellEntry( 86273 ), -- Illuminated Healing
            },
            player = {
                CreateSpellEntry( 642 ), -- Divine Shield
                CreateSpellEntry( 31850 ), -- Ardent Defender
                CreateSpellEntry( 498 ), -- Divine Protection
                CreateSpellEntry( 31884 ), -- Avenging Wrath
                CreateSpellEntry( 85696 ), -- Zealotry
                CreateSpellEntry( 25771 ), -- Debuff: Forbearance
                CreateSpellEntry( 1044 ), -- Hand of Freedom
                CreateSpellEntry( 1022 ), -- Hand of Protection
                CreateSpellEntry( 1038 ), -- Hand of Salvation
				CreateSpellEntry( 53657 ), -- Judgements of the Pure
				CreateSpellEntry( 53563 ), -- Beacon of Light
				CreateSpellEntry( 31821 ), -- Aura Mastery
				CreateSpellEntry( 54428 ), -- Divine Plea
				CreateSpellEntry( 31482 ), -- Divine Favor
				CreateSpellEntry( 6940 ), -- Hand of Sacrifice
            },
            procs = {
                CreateSpellEntry( 59578 ), -- The Art of War
                CreateSpellEntry( 90174 ), -- Hand of Light
                CreateSpellEntry( 71396 ), -- Rage of the Fallen		
				CreateSpellEntry( 53672 ), CreateSpellEntry( 54149 ), -- Infusion of Light (Rank1/Rank2)
				CreateSpellEntry( 85496 ), -- Speed of Light
				CreateSpellEntry( 88819 ), -- Daybreak
				CreateSpellEntry( 20050 ), CreateSpellEntry( 20052 ), CreateSpellEntry( 20053 ), -- Conviction (Rank1/Rank2/Rank3)
			},
		},
		PRIEST = { 
			target = { 
				CreateSpellEntry( 17 ), -- Power Word: Shield
                CreateSpellEntry( 6788, true, nil, 1 ), -- Weakened Soul
                CreateSpellEntry( 139 ), -- Renew
                CreateSpellEntry( 33076 ), -- Prayer of Mending
                CreateSpellEntry( 552 ), -- Abolish Disease
                CreateSpellEntry( 63877 ), -- Pain Suppression
                CreateSpellEntry( 34914, false, nil, nil, 34914 ), -- Vampiric Touch
                CreateSpellEntry( 589 ), -- Shadow Word: Pain
                CreateSpellEntry( 2944 ), -- Devouring Plague
                CreateSpellEntry( 48153 ), -- Guardian Spirit
				CreateSpellEntry( 77489 ), -- Echo of Light
            },
            player = {
                CreateSpellEntry( 10060 ), -- Power Infusion
                CreateSpellEntry( 588 ), -- Inner Fire
                CreateSpellEntry( 47585 ), -- Dispersion
				CreateSpellEntry( 81700 ), -- Archangel
				CreateSpellEntry( 14751 ), -- Chakra
				CreateSpellEntry( 81208 ), -- Chakra Heal
				CreateSpellEntry( 81207 ), -- Chakra Renew
				CreateSpellEntry( 81209 ), -- Chakra Smite
				CreateSpellEntry( 81206 ), -- Prayer of Healing
            },
            procs = {
                CreateSpellEntry( 63735 ), -- Serendipity
                CreateSpellEntry( 88690 ), -- Surge of Light
                CreateSpellEntry( 77487 ), -- Shadow Orb
                CreateSpellEntry( 71572 ), -- Cultivated Power
				CreateSpellEntry( 81661 ), -- Evangelism
				CreateSpellEntry( 72418 ), -- Kuhlendes Wissen
				CreateSpellEntry( 71584 ), -- Revitalize
				CreateSpellEntry( 59888 ), -- Borrowed Time
				CreateSpellEntry( 95799 ), -- Empowered Shadow
			},
		},
		ROGUE = { 
			target = { 
				CreateSpellEntry( 1833 ), -- Cheap Shot --
                CreateSpellEntry( 408 ), -- Kidney Shot --
                CreateSpellEntry( 1776 ), -- Gouge   --
                CreateSpellEntry( 2094 ), -- Blind --
                CreateSpellEntry( 8647 ), -- Expose Armor --
                CreateSpellEntry( 51722 ), -- Dismantle --
                CreateSpellEntry( 2818 ), -- Deadly Poison --
                CreateSpellEntry( 13218 ), -- Wound Posion --
                CreateSpellEntry( 3409 ),  -- Crippling Poison 
                CreateSpellEntry( 5760 ), -- Mind-Numbing Poison --
                CreateSpellEntry( 6770 ), -- Sap
                CreateSpellEntry( 1943 ), -- Rupture --
                CreateSpellEntry( 703 ), -- Garrote --
                CreateSpellEntry( 79140 ), -- vendetta
                CreateSpellEntry( 16511 ), -- Hemorrhage
            },
            player = {
                CreateSpellEntry( 32645 ), -- Envenom --
                CreateSpellEntry( 2983 ), -- Sprint --
                CreateSpellEntry( 5277 ), -- Evasion --
                CreateSpellEntry( 1776 ), -- Gouge --
                CreateSpellEntry( 51713 ), -- Shadow Dance --
                CreateSpellEntry( 1966 ), -- Feint --
                CreateSpellEntry( 73651 ), -- Recuperate --
                CreateSpellEntry( 5171 ), -- Slice and Dice
                CreateSpellEntry( 55503 ), -- Lifeblood --
				CreateSpellEntry( 13877 ), -- Blade Flurry --
            },
            procs = {
                CreateSpellEntry( 71396 ), -- Rage of the Fallen
			},
		},
		SHAMAN = {
			target = {
				CreateSpellEntry( 974 ), -- Earth Shield
				CreateSpellEntry( 8050), -- Flame Shock
				CreateSpellEntry( 8056 ), -- Frost Shock
				CreateSpellEntry( 17364 ), -- Storm Strike
				CreateSpellEntry( 61295 ), -- Riptide
				CreateSpellEntry( 51945 ), -- Earthliving
				CreateSpellEntry( 77657 ), -- Searing Flames
			},
				player = {
				CreateSpellEntry( 324 ), -- Lightning Shield
				CreateSpellEntry( 52127 ), -- Water Shield
				CreateSpellEntry( 974 ), -- Earth Shield
				CreateSpellEntry( 30823 ), -- Shamanistic Rage
				CreateSpellEntry( 55198 ), -- Tidal Force
				CreateSpellEntry( 61295 ), -- Riptide
 
			},
			procs = {
				CreateSpellEntry( 53817 ), -- Maelstrom Weapon			
			},
		},
		WARLOCK = { 
			target = {
				CreateSpellEntry( 48181, false, nil, nil, 48181 ), -- Haunt
				CreateSpellEntry( 32389 ), -- Shadow Embrace 
				CreateSpellEntry( 172 ), -- Corruption
				CreateSpellEntry( 30108, false, nil, nil, 30108 ), -- Unstable Affliction
				CreateSpellEntry( 603 ), -- Curse of Doom
				CreateSpellEntry( 980 ), -- Curse of Agony
				CreateSpellEntry( 1490 ), -- Curse of the Elements 
				CreateSpellEntry( 17962 ), -- Conflagration
				CreateSpellEntry( 348, false, nil, nil, 348 ), -- Immolate
				CreateSpellEntry( 27243, false, nil, nil, 27243 ), -- Seed of Corruption
				CreateSpellEntry( 17941 ), -- Shadow trance
				CreateSpellEntry( 64371 ), -- Eradication
				CreateSpellEntry( 85383 ), -- Imp Soul Fire
				CreateSpellEntry( 1741 ), -- Curse of Tongue
				CreateSpellEntry( 18223 ), -- Curse of Exhaustion
			},
				player = {            
				CreateSpellEntry( 17941 ), -- Shadow trance 
				CreateSpellEntry( 64371 ), -- Eradication
			},
			procs = {
				CreateSpellEntry( 86121 ), -- Soul Swap
				CreateSpellEntry( 54274 ), CreateSpellEntry( 54276 ), CreateSpellEntry( 54277 ), -- Backdraft rank 1/2/3
				CreateSpellEntry( 71165 ), -- Molten Cor
				CreateSpellEntry( 63167 ), -- Decimation
				           
			},
		},
		WARRIOR = { 
			target = {
				CreateSpellEntry( 94009 ), -- Rend
				CreateSpellEntry( 12294 ), -- Mortal Strike
				CreateSpellEntry( 1160 ), -- Demoralizing Shout
				CreateSpellEntry( 64382 ), -- Shattering Throw
				CreateSpellEntry( 58567 ), -- Sunder Armor
				CreateSpellEntry( 86346 ), -- Colossus Smash
				CreateSpellEntry( 7922 ), -- Charge (stun)
				CreateSpellEntry( 1715 ), -- Hamstring
				CreateSpellEntry( 50725 ), -- Vigilance
				CreateSpellEntry( 676 ), -- Disarm
				CreateSpellEntry( 29703 ), -- Daze (Shield Bash)
				CreateSpellEntry( 18498 ), -- Gag Order
				CreateSpellEntry( 12809 ), -- Concussion Blow
				CreateSpellEntry( 6343 ), -- Thunderclap
				CreateSpellEntry( 12162 ), CreateSpellEntry( 12850 ), CreateSpellEntry( 12868 ), -- Deep Wounds Rank 1, 2 & 3
			},
			player = {
				CreateSpellEntry( 469 ), -- Commanding Shout
				CreateSpellEntry( 6673 ), -- Battle Shout
				CreateSpellEntry( 55694 ), -- Enraged Regeneration
				CreateSpellEntry( 23920 ), -- Spell Reflection
				CreateSpellEntry( 871 ), -- Shield Wall
				CreateSpellEntry( 1719 ), -- Recklessness
				CreateSpellEntry( 20230 ), -- Retaliation
				CreateSpellEntry( 2565 ), -- Shield Block
                CreateSpellEntry( 12975 ), -- Last Stand
				CreateSpellEntry( 90806 ), -- Executioner
				CreateSpellEntry( 32216 ), -- Victorious (Victory Rush enabled)
				CreateSpellEntry( 12292 ), -- Death Wish
				CreateSpellEntry( 85738 ), CreateSpellEntry( 85739 ), -- Meat Cleaver Rank 1 and 2
				CreateSpellEntry( 86662 ), CreateSpellEntry( 86663 ), -- Rude interruption rank 1 and 2
			},
			procs = {
				CreateSpellEntry( 46916 ), -- Bloodsurge Slam (Free & Instant)
				CreateSpellEntry( 12964 ), -- Battle Trance (Free Special)
				CreateSpellEntry( 86627 ), -- Incite (Auto-crit HStrike)
			},
		},
	};

local CreateUnitAuraDataSource;
do
	local auraTypes = { "HELPFUL", "HARMFUL" };

	-- private
	local CheckFilter = function( self, id, caster, filter )
		if ( filter == nil ) then return false; end
			
		local byPlayer = caster == "player" or caster == "pet" or caster == "vehicle";
			
		for _, v in ipairs( filter ) do
			if ( v.id == id and ( v.castByAnyone or byPlayer ) ) then return v; end
		end
		
		return false;
	end
	
	local CheckUnit = function( self, unit, filter, result )
		if ( not UnitExists( unit ) ) then return 0; end

		local unitIsFriend = UnitIsFriend( "player", unit );

		for _, auraType in ipairs( auraTypes ) do
			local isDebuff = auraType == "HARMFUL";
		
			for index = 1, 40 do
				local name, _, texture, stacks, _, duration, expirationTime, caster, _, _, spellId = UnitAura( unit, index, auraType );		
				if ( name == nil ) then
					break;
				end							
				
				local filterInfo = CheckFilter( self, spellId, caster, filter );
				if ( filterInfo and ( filterInfo.unitType ~= 1 or unitIsFriend ) and ( filterInfo.unitType ~= 2 or not unitIsFriend ) ) then 					
					filterInfo.name = name;
					filterInfo.texture = texture;
					filterInfo.duration = duration;
					filterInfo.expirationTime = expirationTime;
					filterInfo.stacks = stacks;
					filterInfo.unit = unit;
					filterInfo.isDebuff = isDebuff;
					table.insert( result, filterInfo );
				end
			end
		end
	end

	-- public 
	local Update = function( self )
		local result = self.table;

		for index = 1, #result do
			table.remove( result );
		end				

		CheckUnit( self, self.unit, self.filter, result );
		if ( self.includePlayer ) then
			CheckUnit( self, "player", self.playerFilter, result );
		end
		
		self.table = result;
	end

	local SetSortDirection = function( self, descending )
		self.sortDirection = descending;
	end
	
	local GetSortDirection = function( self )
		return self.sortDirection;
	end
	
	local Sort = function( self )
		local direction = self.sortDirection;
		local time = GetTime();
	
		local sorted;
		repeat
			sorted = true;
			for key, value in pairs( self.table ) do
				local nextKey = key + 1;
				local nextValue = self.table[ nextKey ];
				if ( nextValue == nil ) then break; end
				
				local currentRemaining = value.expirationTime == 0 and 4294967295 or math.max( value.expirationTime - time, 0 );
				local nextRemaining = nextValue.expirationTime == 0 and 4294967295 or math.max( nextValue.expirationTime - time, 0 );
				
				if ( ( direction and currentRemaining < nextRemaining ) or ( not direction and currentRemaining > nextRemaining ) ) then
					self.table[ key ] = nextValue;
					self.table[ nextKey ] = value;
					sorted = false;
				end				
			end			
		until ( sorted == true )
	end
	
	local Get = function( self )
		return self.table;
	end
	
	local Count = function( self )
		return #self.table;
	end
	
	local AddFilter = function( self, filter, defaultColor, debuffColor )
		if ( filter == nil ) then return; end
		
		for _, v in pairs( filter ) do
			local clone = { };
			
			clone.id = v.id;
			clone.castByAnyone = v.castByAnyone;
			clone.color = v.color;
			clone.unitType = v.unitType;
			clone.castSpellId = v.castSpellId;
			
			clone.defaultColor = defaultColor;
			clone.debuffColor = debuffColor;
			
			table.insert( self.filter, clone );
		end
	end
	
	local AddPlayerFilter = function( self, filter, defaultColor, debuffColor )
		if ( filter == nil ) then return; end

		for _, v in pairs( filter ) do
			local clone = { };
			
			clone.id = v.id;
			clone.castByAnyone = v.castByAnyone;
			clone.color = v.color;
			clone.unitType = v.unitType;
			clone.castSpellId = v.castSpellId;
			
			clone.defaultColor = defaultColor;
			clone.debuffColor = debuffColor;
			
			table.insert( self.playerFilter, clone );
		end
	end
	
	local GetUnit = function( self )
		return self.unit;
	end
	
	local GetIncludePlayer = function( self )
		return self.includePlayer;
	end
	
	local SetIncludePlayer = function( self, value )
		self.includePlayer = value;
	end
	
	-- constructor
	CreateUnitAuraDataSource = function( unit )
		local result = {  };

		result.Sort = Sort;
		result.Update = Update;
		result.Get = Get;
		result.Count = Count;
		result.SetSortDirection = SetSortDirection;
		result.GetSortDirection = GetSortDirection;
		result.AddFilter = AddFilter;
		result.AddPlayerFilter = AddPlayerFilter;
		result.GetUnit = GetUnit; 
		result.SetIncludePlayer = SetIncludePlayer; 
		result.GetIncludePlayer = GetIncludePlayer; 
		
		result.unit = unit;
		result.includePlayer = false;
		result.filter = { };
		result.playerFilter = { };
		result.table = { };
		
		return result;
	end
end

local CreateFramedTexture;
do
	-- public
	local SetTexture = function( self, ... )
		return self.texture:SetTexture( ... );
	end
	
	local GetTexture = function( self )
		return self.texture:GetTexture();
	end
	
	local GetTexCoord = function( self )
		return self.texture:GetTexCoord();
	end
	
	local SetTexCoord = function( self, ... )
		return self.texture:SetTexCoord( ... );
	end
	
	local SetBorderColor = function( self, ... )
		return self.border:SetVertexColor( ... );
	end
	
	-- constructor
	CreateFramedTexture = function( parent )
		local result = parent:CreateTexture( nil, "BACKGROUND", nil );
		local border = parent:CreateTexture( nil, "BORDER", nil );
		local background = parent:CreateTexture( nil, "ARTWORK", nil );
		local texture = parent:CreateTexture( nil, "OVERLAY", nil );		
		
		result:SetTexture( 0.1, 0.1, 0.1, 1 );
		border:SetTexture( 0.5, 0.5, 0.5, 1 );
		background:SetTexture( 0.1, 0.1, 0.1, 1 );
			
		border:SetPoint( "TOPLEFT", result, "TOPLEFT", 1, -1 );
		border:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", -1, 1 );
		
		background:SetPoint( "TOPLEFT", border, "TOPLEFT", 1, -1 );
		background:SetPoint( "BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, 1 );

		texture:SetPoint( "TOPLEFT", background, "TOPLEFT", 1, -1 );
		texture:SetPoint( "BOTTOMRIGHT", background, "BOTTOMRIGHT", -1, 1 );
			
		result.border = border;
		result.background = background;
		result.texture = texture;
			
		result.SetBorderColor = SetBorderColor;
		
		result.SetTexture = SetTexture;
		result.GetTexture = GetTexture;
		result.SetTexCoord = SetTexCoord;
		result.GetTexCoord = GetTexCoord;
			
		return result;
	end
end

local CreateAuraBarFrame;
do
	-- classes
	local CreateAuraBar;
	do
		-- private 
		local OnUpdate = function( self, elapsed )	
			local time = GetTime();
		
			if ( time > self.expirationTime ) then
				self.bar:SetScript( "OnUpdate", nil );
				self.bar:SetValue( 0 );
				self.time:SetText( "" );
				
				local spark = self.spark;
				if ( spark ) then			
					spark:Hide();
				end
			else
				local remaining = self.expirationTime - time;
				self.bar:SetValue( remaining );
				
				local timeText = "";
				if ( remaining >= 3600 ) then
					timeText = tostring( math.floor( remaining / 3600 ) ) .. "h";
				elseif ( remaining >= 60 ) then
					timeText = tostring( math.floor( remaining / 60 ) ) .. "m";
				elseif ( remaining > TENTHS_TRESHOLD ) then
					timeText = tostring( math.floor( remaining ) );
				elseif ( remaining > 0 ) then
					timeText = tostring( math.floor( remaining * 10 ) / 10 );
				end
				self.time:SetText( timeText );
				
				local barWidth = self.bar:GetWidth();
				
				local spark = self.spark;
				if ( spark ) then			
					spark:SetPoint( "CENTER", self.bar, "LEFT", barWidth * remaining / self.duration, 0 );
				end
				
				local castSeparator = self.castSeparator;
				if ( castSeparator and self.castSpellId ) then
					local _, _, _, _, _, _, castTime, _, _ = GetSpellInfo( self.castSpellId );

					castTime = castTime / 1000;
					if ( castTime and remaining > castTime ) then
						castSeparator:SetPoint( "CENTER", self.bar, "LEFT", barWidth * ( remaining - castTime ) / self.duration, 0 );
					else
						castSeparator:Hide();
					end
				end
			end
		end
		
		-- public
		local SetIcon = function( self, icon )
			if ( not self.icon ) then return; end
			
			self.icon:SetTexture( icon );
		end
		
		local SetTime = function( self, expirationTime, duration )
			self.expirationTime = expirationTime;
			self.duration = duration;
			
			if ( expirationTime > 0 and duration > 0 ) then		
				self.bar:SetMinMaxValues( 0, duration );
				OnUpdate( self, 0 );
		
				local spark = self.spark;
				if ( spark ) then 
					spark:Show();
				end
		
				self:SetScript( "OnUpdate", OnUpdate );
			else
				self.bar:SetMinMaxValues( 0, 1 );
				self.bar:SetValue( PERMANENT_AURA_VALUE );
				self.time:SetText( "" );
				
				local spark = self.spark;
				if ( spark ) then 
					spark:Hide();
				end
				
				self:SetScript( "OnUpdate", nil );
			end
		end
		
		local SetName = function( self, name )
			self.name:SetText( name );
		end
		
		local SetStacks = function( self, stacks )
			if ( not self.stacks ) then
				if ( stacks ~= nil and stacks > 1 ) then
					local name = self.name;
					
					name:SetText( tostring( stacks ) .. "  " .. name:GetText() );
				end
			else			
				if ( stacks ~= nil and stacks > 1 ) then
					self.stacks:SetText( stacks );
				else
					self.stacks:SetText( "" );
				end
			end
		end
		
		local SetColor = function( self, color )
			self.bar:SetStatusBarColor( unpack( color ) );
		end
		
		local SetCastSpellId = function( self, id )
			self.castSpellId = id;
			
			local castSeparator = self.castSeparator;
			if ( castSeparator ) then
				if ( id ) then
					self.castSeparator:Show();
				else
					self.castSeparator:Hide();
				end
			end
		end
		
		local SetAuraInfo = function( self, auraInfo )
			self:SetName( auraInfo.name );
			self:SetIcon( auraInfo.texture );	
			self:SetTime( auraInfo.expirationTime, auraInfo.duration );
			self:SetStacks( auraInfo.stacks );
			self:SetCastSpellId( auraInfo.castSpellId );
		end
		
		-- constructor
		CreateAuraBar = function( parent )
			local result = CreateFrame( "Frame", nil, parent, nil );

			if ( bit.band( ICON_POSITION, 4 ) == 0 ) then		
				local icon = CreateFramedTexture( result, "ARTWORK" );
				icon:SetTexCoord( 0.15, 0.85, 0.15, 0.85 );
				icon:SetBorderColor( unpack( ICON_COLOR ) );
				
				local iconAnchor1;
				local iconAnchor2;
				local iconOffset;
				if ( bit.band( ICON_POSITION, 1 ) == 1 ) then
					iconAnchor1 = "TOPLEFT";
					iconAnchor2 = "TOPRIGHT";
					iconOffset = 1;
				else
					iconAnchor1 = "TOPRIGHT";
					iconAnchor2 = "TOPLEFT";
					iconOffset = -1;
				end			
				
				if ( bit.band( ICON_POSITION, 2 ) == 2 ) then
					icon:SetPoint( iconAnchor1, result, iconAnchor2, iconOffset * 6, 1 );
				else
					icon:SetPoint( iconAnchor1, result, iconAnchor2, iconOffset * ( -BAR_HEIGHT - 1 ), 1 );
				end			
				icon:SetWidth( BAR_HEIGHT + 2 );
				icon:SetHeight( BAR_HEIGHT + 2 );	

				result.icon = icon;
				
				local stacks = result:CreateFontString( nil, "OVERLAY", nil );
				stacks:SetFont( unpack( STACKS_FONT ) );
				stacks:SetShadowColor( 0, 0, 0 );
				stacks:SetShadowOffset( 1.25, -1.25 );
				stacks:SetJustifyH( "RIGHT" );
				stacks:SetJustifyV( "BOTTOM" );
				stacks:SetPoint( "TOPLEFT", icon, "TOPLEFT", 0, 0 );
				stacks:SetPoint( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 3 );
				result.stacks = stacks;
			end
			
			local bar = CreateFrame( "StatusBar", nil, result, nil );
			bar:SetStatusBarTexture( TukuiCF["media"].normTex );
			if ( bit.band( ICON_POSITION, 2 ) == 2 or bit.band( ICON_POSITION, 4 ) == 4 ) then
				bar:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
				bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
			else
				if ( bit.band( ICON_POSITION, 1 ) == 1 ) then
					bar:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
					bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", -BAR_HEIGHT - 1, 0 );
				else
					bar:SetPoint( "TOPLEFT", result, "TOPLEFT", BAR_HEIGHT + 1, 0 );
					bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );					
				end	
			end
			result.bar = bar;
			
			if ( SPARK ) then
				local spark = bar:CreateTexture( nil, "OVERLAY", nil );
				spark:SetTexture( [[Interface\CastingBar\UI-CastingBar-Spark]] );
				spark:SetWidth( 12 );
				spark:SetBlendMode( "ADD" );
				spark:Show();
				result.spark = spark;
			end
			
			if ( CAST_SEPARATOR ) then
				local castSeparator = bar:CreateTexture( nil, "OVERLAY", nil );
				castSeparator:SetTexture( unpack( CAST_SEPARATOR_COLOR ) );
				castSeparator:SetWidth( 1 );
				castSeparator:SetHeight( BAR_HEIGHT );
				castSeparator:Show();
				result.castSeparator = castSeparator;
			end
						
			local name = bar:CreateFontString( nil, "OVERLAY", nil );
			name:SetFont( unpack( MASTER_FONT ) );
			name:SetJustifyH( "LEFT" );
			name:SetShadowColor( 0, 0, 0 );
			name:SetShadowOffset( 1.25, -1.25 );
			name:SetPoint( "TOPLEFT", bar, "TOPLEFT", TEXT_MARGIN, 0 );
			name:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", -45, 2 );
			result.name = name;
			
			local time = bar:CreateFontString( nil, "OVERLAY", nil );
			time:SetFont( unpack( MASTER_FONT ) );
			time:SetJustifyH( "RIGHT" );
			time:SetShadowColor( 0, 0, 0 );
			time:SetShadowOffset( 1.25, -1.25 );
			time:SetPoint( "TOPLEFT", name, "TOPRIGHT", 0, 0 );
			time:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", -TEXT_MARGIN, 2 );
			result.time = time;
			
			result.SetIcon = SetIcon;
			result.SetTime = SetTime;
			result.SetName = SetName;
			result.SetStacks = SetStacks;
			result.SetAuraInfo = SetAuraInfo;
			result.SetColor = SetColor;
			result.SetCastSpellId = SetCastSpellId;
			
			return result;
		end
	end

	-- private
	local SetAuraBar = function( self, index, auraInfo )
		local line = self.lines[ index ]
		if ( line == nil ) then
			line = CreateAuraBar( self );
			if ( index == 1 ) then
				line:SetPoint( "TOPLEFT", self, "BOTTOMLEFT", 0, BAR_HEIGHT );
				line:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0 );
			else
				local anchor = self.lines[ index - 1 ];
				line:SetPoint( "TOPLEFT", anchor, "TOPLEFT", 0, BAR_HEIGHT + BAR_SPACING );
				line:SetPoint( "BOTTOMRIGHT", anchor, "TOPRIGHT", 0, BAR_SPACING );
			end
			tinsert( self.lines, index, line );
		end	
		
		line:SetAuraInfo( auraInfo );
		if ( auraInfo.color ) then
			line:SetColor( auraInfo.color );
		elseif ( auraInfo.debuffColor and auraInfo.isDebuff ) then
			line:SetColor( auraInfo.debuffColor );
		elseif ( auraInfo.defaultColor ) then
			line:SetColor( auraInfo.defaultColor );
		end
		
		line:Show();
	end
	
	local function OnUnitAura( self, unit )
		if ( unit ~= self.unit and ( self.dataSource:GetIncludePlayer() == false or unit ~= "player" ) ) then
			return;
		end
		
		self:Render();
	end
	
	local function OnPlayerTargetChanged( self, method )
		self:Render();
	end
	
	local function OnPlayerEnteringWorld( self )
		self:Render();
	end
	
	local function OnEvent( self, event, ... )
		if ( event == "UNIT_AURA" ) then
			OnUnitAura( self, ... );
		elseif ( event == "PLAYER_TARGET_CHANGED" ) then
			OnPlayerTargetChanged( self, ... );
		elseif ( event == "PLAYER_ENTERING_WORLD" ) then
			OnPlayerEnteringWorld( self );
		else
			error( "Unhandled event " .. event );
		end
	end
	
	-- public
	local function Render( self )
		local dataSource = self.dataSource;	

		dataSource:Update();
		dataSource:Sort();
		
		local count = dataSource:Count();

		for index, auraInfo in ipairs( dataSource:Get() ) do
			SetAuraBar( self, index, auraInfo );
		end
		
		for index = count + 1, 80 do
			local line = self.lines[ index ];
			if ( line == nil or not line:IsShown() ) then
				break;
			end
			line:Hide();
		end
		
		if ( count > 0 ) then
			self:SetHeight( ( BAR_HEIGHT + BAR_SPACING ) * count - BAR_SPACING );
			self:Show();
		else
			self:Hide();
			self:SetHeight( self.hiddenHeight or 1 );
		end
	end
	
	local function SetHiddenHeight( self, height )
		self.hiddenHeight = height;
	end

	-- constructor
	CreateAuraBarFrame = function( dataSource, parent )
		local result = CreateFrame( "Frame", nil, parent, nil );
		local unit = dataSource:GetUnit();
		
		result.unit = unit;
		
		result.lines = { };		
		result.dataSource = dataSource;
		
		local background = result:CreateTexture( nil, "BACKGROUND", nil );
		background:SetAlpha( BACKGROUND_ALPHA );
		background:SetTexture( TukuiCF["media"].normTex );
		background:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
		background:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
		background:SetVertexColor( 0.15, 0.15, 0.15 );
		result.background = background;
		
		local border = CreateFrame( "Frame", nil, result, nil );
		border:SetAlpha( BACKGROUND_ALPHA );
		border:SetFrameStrata( "BACKGROUND" );
		border:SetBackdrop( {
			edgeFile = TukuiCF["media"].glowTex, 
			edgeSize = 5,
			insets = { left = 3, right = 3, top = 3, bottom = 3 }
		} );
		border:SetBackdropColor( 0, 0, 0, 0 );
		border:SetBackdropBorderColor( 0, 0, 0 );
		border:SetPoint( "TOPLEFT", result, "TOPLEFT", -5, 5 );
		border:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 5, -5 );
		result.border = border;		
		
		result:RegisterEvent( "PLAYER_ENTERING_WORLD" );
		result:RegisterEvent( "UNIT_AURA" );
		if ( unit == "target" ) then
			result:RegisterEvent( "PLAYER_TARGET_CHANGED" );
		end
		
		result:SetScript( "OnEvent", OnEvent );
		
		result.Render = Render;
		result.SetHiddenHeight = SetHiddenHeight;
		
		return result;
	end
end

local _, playerClass = UnitClass( "player" );
local classFilter = CLASS_FILTERS[ playerClass ];

if ( LAYOUT == 1 ) then
	local dataSource = CreateUnitAuraDataSource( "target" );

	dataSource:SetSortDirection( SORT_DIRECTION );
	
	dataSource:AddPlayerFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );
	
	if ( classFilter ) then
		dataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );
		dataSource:AddPlayerFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
		dataSource:AddPlayerFilter( classFilter.procs, TRINKET_BAR_COLOR );
		dataSource:SetIncludePlayer( classFilter.player ~= nil );
	end

	local frame = CreateAuraBarFrame( dataSource, oUF_Tukz_player );
	local yOffset = 1;
	if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" or playerClass == "PALADIN" or playerClass == "DRUID" or playerClass == "WARLOCK") then
		yOffset = yOffset + 8;
	end
	frame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset );
	frame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset );
	frame:Show(); 
elseif ( LAYOUT == 2 ) then
	local targetDataSource = CreateUnitAuraDataSource( "target" );
	local playerDataSource = CreateUnitAuraDataSource( "player" );

	targetDataSource:SetSortDirection( SORT_DIRECTION );
	playerDataSource:SetSortDirection( SORT_DIRECTION );
	
	playerDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );

	if ( classFilter ) then
		targetDataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );
		playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
		playerDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
	end

	local yOffset = 6;
	
	local playerFrame = CreateAuraBarFrame( playerDataSource, oUF_Tukz_player );	
	playerFrame:SetHiddenHeight( -yOffset );
	if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" or playerClass == "PALADIN" or playerClass == "DRUID" or playerClass == "WARLOCK") then
		playerFrame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset + 8 );
		playerFrame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset + 8 );
	else
		playerFrame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset );
		playerFrame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset );
	end
	playerFrame:Show();

	local targetFrame = CreateAuraBarFrame( targetDataSource, oUF_Tukz_player );
	targetFrame:SetPoint( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, yOffset );
	targetFrame:SetPoint( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, yOffset );
	targetFrame:Show();
elseif ( LAYOUT == 3 ) then
	local yOffset = 6;

	local targetDataSource = CreateUnitAuraDataSource( "target" );
	local playerDataSource = CreateUnitAuraDataSource( "player" );
	local trinketDataSource = CreateUnitAuraDataSource( "player" );
	
	targetDataSource:SetSortDirection( SORT_DIRECTION );
	playerDataSource:SetSortDirection( SORT_DIRECTION );
	trinketDataSource:SetSortDirection( SORT_DIRECTION );
	
	if ( classFilter ) then
		targetDataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );		
		playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
		trinketDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
	end
	trinketDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );

	local playerFrame = CreateAuraBarFrame( playerDataSource, oUF_Tukz_player );
	playerFrame:SetHiddenHeight( -yOffset );
	if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" or playerClass == "PALADIN" or playerClass == "DRUID" or playerClass == "WARLOCK") then
		playerFrame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset + 8 );
		playerFrame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset + 8 );
	else
		playerFrame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset );
		playerFrame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset );
	end
	playerFrame:Show();

	local trinketFrame = CreateAuraBarFrame( trinketDataSource, oUF_Tukz_player );
	trinketFrame:SetHiddenHeight( -yOffset );
	trinketFrame:SetPoint( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, yOffset );
	trinketFrame:SetPoint( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, yOffset );
	trinketFrame:Show();
	
	local targetFrame = CreateAuraBarFrame( targetDataSource, oUF_Tukz_player );
	targetFrame:SetHiddenHeight( -yOffset );
	targetFrame:SetPoint( "BOTTOMLEFT", trinketFrame, "TOPLEFT", 0, yOffset );
	targetFrame:SetPoint( "BOTTOMRIGHT", trinketFrame, "TOPRIGHT", 0, yOffset );
	targetFrame:Show();
elseif ( LAYOUT == 4 ) then
	local yOffset = 6;

	local targetDataSource = CreateUnitAuraDataSource( "target" );
	local playerDataSource = CreateUnitAuraDataSource( "player" );
	local trinketDataSource = CreateUnitAuraDataSource( "player" );
	
	targetDataSource:SetSortDirection( SORT_DIRECTION );
	playerDataSource:SetSortDirection( SORT_DIRECTION );
	trinketDataSource:SetSortDirection( SORT_DIRECTION );
	
	if ( classFilter ) then
		targetDataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );		
		playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
		trinketDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
	end
	trinketDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );

	local playerFrame = CreateAuraBarFrame( playerDataSource, oUF_Tukz_player );
	playerFrame:SetHiddenHeight( -yOffset );
	if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" or playerClass == "PALADIN" or playerClass == "DRUID" or playerClass == "WARLOCK") then
		playerFrame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset + 8 );
		playerFrame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset + 8 );
	else
		playerFrame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset );
		playerFrame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset );
	end
	playerFrame:Show();

	local trinketFrame = CreateAuraBarFrame( trinketDataSource, oUF_Tukz_player );
	trinketFrame:SetHiddenHeight( -yOffset );
	trinketFrame:SetPoint( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, yOffset );
	trinketFrame:SetPoint( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, yOffset );
	trinketFrame:Show();
	
	local targetFrame = CreateAuraBarFrame( targetDataSource, oUF_Tukz_target );
	targetFrame:SetPoint( "BOTTOMLEFT", oUF_Tukz_target, "TOPLEFT", 0, 8 + ( 32 * 3 ) );
	targetFrame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_target, "TOPRIGHT", 0, 8 + ( 32 * 3 ) );
	targetFrame:Show();
else
	error( "Undefined layout " .. tostring( LAYOUT ) );
end