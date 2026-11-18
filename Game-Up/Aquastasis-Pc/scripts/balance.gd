extends Node
## Balance (autoload): every tunable number of the game lives here, nothing else.
## crisis_sim.gd and region.gd read it via preload (works headless without autoloads);
## other scripts may use the Balance singleton. Tune values freely; keep names stable.

# --- Time ---------------------------------------------------------------------
const TICK_SECONDS := 2.5          # real seconds per monthly simulation tick at 1x
const TOTAL_TICKS := 240           # 2026 -> 2046 at 1x is 240 months (12 ticks = 1 yr)
const TICKS_PER_YEAR := 12
const START_YEAR := 2026
const END_YEAR := 2046
const SPEEDS := [0.0, 1.0, 2.0, 4.0]   # index 0 = pause, 1 = 1x, 2 = 2x, 3 = 4x
const MAX_TICKS_PER_FRAME := 8     # guard against frame spikes at 4x
const DEFAULT_SEED := 31

# --- Global climate -------------------------------------------------------------
const TEMP_START := 1.5            # degrees C above pre-industrial
const TEMP_LOSE := 4.0
const TEMP_BASE_RISE_PER_TICK := 0.0016
const TEMP_CRISIS_RISE_PER_TICK := 0.0135   # multiplied by average crisis / 100
const TEMP_STRESS_COEFF := 0.045     # extra pollution / stress per tick per degree above TEMP_START
const TEMP_MILESTONES := [2.0, 2.5, 3.0, 3.5]  # toast when warming crosses each value
const TEMP_ALARM_MILESTONE := 3.0  # milestones from here on are alarms (severity 3)

# --- Crisis level of a region (weights sum to 1) --------------------------------
const CRISIS_W_POLLUTION := 0.4
const CRISIS_W_CORAL := 0.2
const CRISIS_W_SEAGRASS := 0.2
const CRISIS_W_FISH := 0.2
const STATUS_STRESSED := 30.0      # crisis >= this -> "stressed"
const STATUS_CRITICAL := 55.0      # crisis >= this -> "critical"
const STATUS_COLLAPSED := 75.0     # crisis >= this -> "collapsed"

# --- Per-tick regional dynamics (all values are 0-100 scales) -------------------
const BASE_POLLUTION_RATE := 0.056
const SOURCE_INFLOW_COEFF := 0.115      # x coastal_pop: rivers, sewage, plastic inflow
const NEIGHBOR_PRESSURE_COEFF := 0.00034  # x neighbour pollution x route weight x kind mult
const PROTECT_COEFF := 0.0050          # x protection: pollution reduction (at LEVER_POLLUTION_REF)
const AWARE_COEFF := 0.0058             # x awareness: pollution reduction (at LEVER_POLLUTION_REF)
const LEVER_POLLUTION_REF := 50.0      # lever reductions scale with pollution / this
const BIO_SAFE_POLLUTION := 30.0       # below: clean water lets life regrow; above: damage
const BIO_ROOM_EXPONENT := 2.3         # coral / seagrass recovery x (1 - value / 100) ^ this
const BIO_DIRTY_RECOVERY_CUT := 0.6    # protection-driven recovery x (1 - dirtiness x this)
const CORAL_POLLUTION_DAMAGE := 0.19   # per tick at pollution 100 (0 at BIO_SAFE_POLLUTION)
const CORAL_HEAT_DAMAGE := 0.044       # per tick per degree above TEMP_START (x heat_sensitivity)
const CORAL_RECOVERY := 2.15           # x protection / 100 x clean-water factor x room to grow
const CORAL_CLEAN_REGROWTH := 0.044    # x cleanliness below BIO_SAFE_POLLUTION x room to grow
const SEAGRASS_POLLUTION_DAMAGE := 0.19
const SEAGRASS_HEAT_DAMAGE := 0.030
const SEAGRASS_RECOVERY := 2.15         # same rules as coral (kelp & seagrass meadows)
const SEAGRASS_CLEAN_REGROWTH := 0.044
const FISHING_PRESSURE := 0.45         # catch per tick at stock 50, cut by no-take zones
const FISH_PROTECT_MULT := 1.35        # no-take share = protection / 100 x this (capped at 1)
const FISH_POLLUTION_DAMAGE := 0.078   # x pollution / 100
const FISH_REGEN := 0.42               # logistic regrowth per tick at stock 50
const FISH_SEED_STOCK := 2.0           # migrants: lets an emptied stock restart
const FISH_HABITAT_WEIGHT := 0.5       # share of fish regrowth that needs seagrass nurseries
const AWARENESS_DECAY_PER_TICK := 0.016   # flat part
const AWARENESS_DECAY_RATE := 0.0115    # proportional part (x awareness)
const PROTECTION_DECAY_PER_TICK := 0.015  # flat part
const PROTECTION_DECAY_RATE := 0.0115    # proportional part (x protection)
const AWARE_PROTECTION_HOLD := 0.6     # x awareness / 100: protection decays this much slower
const AWARE_FISHING_CUT := 0.36        # x awareness / 100: fishing demand drops this much

# --- Spread along routes ----------------------------------------------------------
const CURRENT_WEIGHT_MULT := 1.0
const SHIPPING_WEIGHT_MULT := 0.8
const SPREAD_THRESHOLD := 45.0         # source crisis needed before it can spread
const SPREAD_CHANCE_PER_TICK := 0.052  # x route weight x source crisis / 100 (scaled for 19 global routes)
const SPREAD_POLLUTION_BUMP := 4.5       # pollution added to the target (x shield)
const SPREAD_BIO_DAMAGE := 1.5         # coral / seagrass / fish hit on the target
const SPREAD_PROTECTION_SHIELD := 0.8  # x target protection / 100: chance and damage cut
const SPREAD_ROUTE_COOLDOWN_TICKS := 10

# --- Resources ------------------------------------------------------------------
const BUDGET_START := 240.0
const POLITICAL_START := 75.0
const SCIENCE_START := 22.0
const BUDGET_INCOME_PER_TICK := 5.2    # at sea health BUDGET_REF_HEALTH (linear in sea health)
const BUDGET_REF_HEALTH := 52.0
const BUDGET_BREAKEVEN_HEALTH := 32.0  # below this the sea economy costs money
const POLITICAL_INCOME_PER_TICK := 1.50 # at average awareness POLITICAL_REF_AWARENESS
const POLITICAL_REF_AWARENESS := 24.0
const POLITICAL_BREAKEVEN_AWARENESS := 11.5  # below this lobbies erode support
const SCIENCE_INCOME_PER_TICK := 0.25  # monthly science trickle; bubbles and satellites add more
const RESOURCE_CAP := 999.0
const DEPLETED_THRESHOLD := 1.0        # both budget and political below this -> lose
const DEPLETED_GRACE_TICKS := 5        # ... for this many consecutive ticks
const LOW_BUDGET_WARN := 20.0          # warning toast when budget AND political are below
const LOW_POLITICAL_WARN := 4.0
const LOW_RESOURCE_TOAST_GAP_TICKS := 15

# --- Win / lose -------------------------------------------------------------------
const WIN_SEA_HEALTH := 60.0           # checked at END_YEAR
const WIN_ALL_CRISIS_BELOW := 25.0     # checked every tick: early win
const LOSE_SEA_HEALTH := 10.0

# --- Toast thresholds ---------------------------------------------------------------
const REGION_CRITICAL_CRISIS := 66.0
const REGION_RECOVERED_CRISIS := 35.0
const ALERT_HYSTERESIS := 8.0          # crisis must move this far back before re-alerting
const TOAST_MIN_GAP_TICKS := 2         # at most one toast per kind per this many ticks

# --- Field operations (per region, tuned for 12 global basins) ---------------------
const ACTIONS := {
	"cleanup": {
		"branch": "source",
		"cost": {"budget": 40.0},
		"cooldown_ticks": 4,
		"icon": "cleanup",
		"name_key": "action.cleanup.name",
		"desc_key": "action.cleanup.desc",
		"toast_key": "toast.action.cleanup",
	},
	"patrol": {
		"branch": "protect",
		"cost": {"political": 11.0},
		"cooldown_ticks": 4,
		"icon": "patrol",
		"name_key": "action.patrol.name",
		"desc_key": "action.patrol.desc",
		"toast_key": "toast.action.patrol",
	},
	"campaign": {
		"branch": "science",
		"cost": {"budget": 24.0, "political": 5.0},
		"cooldown_ticks": 5,
		"icon": "campaign",
		"name_key": "action.campaign.name",
		"desc_key": "action.campaign.desc",
		"toast_key": "toast.action.campaign",
	},
}
const ACTION_ORDER := ["cleanup", "patrol", "campaign"]
const CLEANUP_POLLUTION_DROP := 17.5   # at pollution CLEANUP_REF_POLLUTION
const CLEANUP_REF_POLLUTION := 50.0    # cleanup scales with pollution / this ...
const CLEANUP_MIN_SCALE := 0.6         # ... clamped to this range
const CLEANUP_MAX_SCALE := 1.4
const PATROL_PROTECTION_GAIN := 24.0   # x (1 - protection / 100 x PATROL_SATURATION)
const PATROL_SATURATION := 0.8
const CAMPAIGN_AWARENESS_GAIN := 21.0  # x (1 - awareness / 100 x CAMPAIGN_SATURATION)
const CAMPAIGN_SATURATION := 1.0
const CAMPAIGN_NEIGHBOR_SHARE := 0.48
const CAMPAIGN_POLLUTION_DROP := 0.8    # direct pollution cut in the campaigned region

# --- Policy tree economy & Repeatable Science Projects ---------------------------------
const BLUE_CARBON_SEAGRASS := 60.0     # "blue_carbon" pays per tick per region with seagrass above this
const HISTORY_EVERY := 3               # live chart: one sample per this many ticks (every quarter)
const SCIENCE_CURE_COST := 30.0        # Science Points required to synthesize counter-strategy and cure mutation
const PROJECT_BIO_ALGAE_COST := 40.0   # Science cost
const PROJECT_BIO_ALGAE_BUDGET := 25.0 # Operational Budget cost
const PROJECT_BIO_ALGAE_CD_TICKS := 15 # 37.5 seconds at 1x
const PROJECT_DRONE_SWARM_COST := 30.0 # Science cost
const PROJECT_DRONE_SWARM_BUDGET := 20.0 # Operational Budget cost
const PROJECT_DRONE_SWARM_CD_TICKS := 12 # 30 seconds at 1x

# --- HQ Emergency Response Fleet (3.2) --------------------------------------------
const FLEET_HQ_CRISIS_MAX := 50.0       # available when HQ crisis < 50%
const FLEET_COOLDOWN_TICKS := 18        # ~45 s at 1x
const FLEET_TICKS_PER_HOP := 2          # travel duration proportional to route distance
const FLEET_MIN_TRAVEL_TICKS := 2
const FLEET_BUDGET_COST := 35.0
const FLEET_POLLUTION_DROP := 18.0
const FLEET_PROTECTION_BOOST := 12.0
const FLEET_BIO_BOOST := 5.0

# --- Triple Synergy Combo: Full Mobilization (3.3) -------------------------------
const COMBO_WINDOW_TICKS := 10         # 3 distinct operations in a region within this window
const COMBO_SHIELD_TICKS := 12         # spread reduction shield duration
const COMBO_SPREAD_MULT := 0.5         # outbound spread probability multiplier while shielded
const COMBO_CORAL_BOOST := 4.0
const COMBO_SEAGRASS_BOOST := 4.0
const COMBO_FISH_BOOST := 4.0
const COMBO_POLITICAL_BONUS := 6.0

# --- Global Ocean Summit Report Card & 5-Year Pledges (3.4) ----------------------
const SUMMIT_GRADE_S_MARGIN := 6.0    # sea_health >= target + margin and temp < S_TEMP -> grade S
const SUMMIT_GRADE_S_TEMP := 2.4
const SUMMIT_GRADE_A_TEMP := 3.2
const SUMMIT_GRADE_B_MARGIN := 8.0    # within target - margin and temp < 3.4 -> grade B
const SUMMIT_GRADE_B_TEMP := 3.4
const SUMMIT_PLEDGE_HEALTH_GAIN := 5.0
const SUMMIT_PLEDGE_CRISIS_DROP := 4.0
const SUMMIT_PLEDGE_BIO_GAIN := 4.0
const SUMMIT_PLEDGE_PASS_BUDGET := 80.0
const SUMMIT_PLEDGE_PASS_POLITICAL := 18.0
const SUMMIT_PLEDGE_FAIL_POLITICAL := 15.0

# --- Crisis evolution (docs/ARCHITECTURE.md 11.4) ----------------------------
const EVO_WINDOW := 12                 # the crisis remembers this many recent player moves
const EVO_MIN_MOVES := 8               # ... and reads a strategy only once it has this many
const EVO_SHARE := 0.52                # one branch with at least this share evolves its resistance ...
const EVO_ADAPT_TICKS := 36            # ~90 s at 1x
const EVO_ADAPT_DECAY := 1.0           # adaptation lost per tick while the strategy is diverse again
const EVO_WARN_AT := 0.5               # "crisis is adapting" toast at this share of EVO_ADAPT_TICKS
const EVO_HEAT_TEMP := 2.50            # marine_heatwave evolves at this warming
const EVO_SPREAD_COUNT := 8            # invasive_species evolves after this many spreads

# --- Decision events (11.5) -----------------------------------------------------
const EVENT_FIRST_MIN := 14            # first random card between these ticks (~14-20 months)
const EVENT_FIRST_MAX := 20
const EVENT_INTERVAL_MIN := 24        # then one every 24..34 ticks (~2-3 years)
const EVENT_INTERVAL_MAX := 34
const EVENT_SUMMIT_GAP_TICKS := 8     # no random card this close before or after a Global Ocean Summit

# --- Data bubbles (11.6) ----------------------------------------------------------
const BUBBLE_CHANCE_PER_TICK := 0.36   # ~5-8 seconds interval at 2.5s ticks
const BUBBLES_MAX := 4                 # alive at once
const BUBBLE_TTL_TICKS := 8            # 20 s at 1x
const BUBBLE_POLITICAL_SHARE := 0.25   # the rest are science bubbles
const BUBBLE_SCIENCE_MIN := 4          # amount range before bubble_value_mult
const BUBBLE_SCIENCE_MAX := 8
const BUBBLE_POLITICAL_MIN := 3
const BUBBLE_POLITICAL_MAX := 6
const BUBBLE_AWARENESS_WEIGHT := 5.0   # political bubbles: region weight = awareness + this

# --- News headlines (11.7) -----------------------------------------------------------
const NEWS_SPREAD_GAP_TICKS := 10      # at most one spread headline per this many ticks
const NEWS_ALERT_GAP_TICKS := 3        # region alarm / recovery headlines

# --- Heat sensitivity multiplier per region (1.1) ------------------------------------
const REGION_HEAT_SENSITIVITY := {
	"north_atlantic": 0.90,
	"south_atlantic": 0.85,
	"caribbean": 1.15,
	"mediterranean": 1.05,
	"red_arabian": 1.15,
	"indian": 1.00,
	"coral_triangle": 1.30,
	"east_asian": 0.95,
	"north_pacific": 0.90,
	"south_pacific": 1.10,
	"arctic": 1.35,
	"southern": 1.15,
}

# --- Starting state per region (0-100) -----------------------------------------------
const REGION_START := {
	"north_atlantic": {"pollution": 44.0, "coral_health": 58.0, "seagrass": 54.0, "fish_stock": 44.0, "awareness": 30.0, "protection": 12.0},
	"south_atlantic": {"pollution": 38.0, "coral_health": 60.0, "seagrass": 56.0, "fish_stock": 48.0, "awareness": 20.0, "protection": 8.0},
	"caribbean": {"pollution": 48.0, "coral_health": 46.0, "seagrass": 50.0, "fish_stock": 42.0, "awareness": 22.0, "protection": 10.0},
	"mediterranean": {"pollution": 38.0, "coral_health": 62.0, "seagrass": 58.0, "fish_stock": 48.0, "awareness": 30.0, "protection": 14.0},
	"red_arabian": {"pollution": 54.0, "coral_health": 48.0, "seagrass": 44.0, "fish_stock": 40.0, "awareness": 16.0, "protection": 6.0},
	"indian": {"pollution": 50.0, "coral_health": 54.0, "seagrass": 50.0, "fish_stock": 42.0, "awareness": 18.0, "protection": 7.0},
	"coral_triangle": {"pollution": 56.0, "coral_health": 50.0, "seagrass": 48.0, "fish_stock": 38.0, "awareness": 18.0, "protection": 6.0},
	"east_asian": {"pollution": 66.0, "coral_health": 40.0, "seagrass": 36.0, "fish_stock": 32.0, "awareness": 20.0, "protection": 5.0},
	"north_pacific": {"pollution": 48.0, "coral_health": 56.0, "seagrass": 54.0, "fish_stock": 46.0, "awareness": 26.0, "protection": 11.0},
	"south_pacific": {"pollution": 32.0, "coral_health": 64.0, "seagrass": 62.0, "fish_stock": 54.0, "awareness": 28.0, "protection": 14.0},
	"arctic": {"pollution": 22.0, "coral_health": 72.0, "seagrass": 68.0, "fish_stock": 60.0, "awareness": 26.0, "protection": 12.0},
	"southern": {"pollution": 18.0, "coral_health": 76.0, "seagrass": 72.0, "fish_stock": 62.0, "awareness": 24.0, "protection": 15.0},
}

# --- Difficulty Levels --------------------------------------------------------
const DIFFICULTY_CADET := "cadet"
const DIFFICULTY_COMMANDER := "commander"
const DIFFICULTY_ADMIRAL := "admiral"

const DIFFICULTIES := {
	"cadet": {
		"id": "cadet",
		"name_key": "diff.cadet.name",
		"desc_key": "diff.cadet.desc",
		"badge": "🟢 CADET",
		"resource_mult": 1.5,
		"spread_mult": 0.70,
		"temp_rise_mult": 0.70,
		"evo_threshold_mult": 1.25,
		"hq_collapse_limit": 88.0,
		"pollution_mult": 0.85
	},
	"commander": {
		"id": "commander",
		"name_key": "diff.commander.name",
		"desc_key": "diff.commander.desc",
		"badge": "🟡 COMMANDER",
		"resource_mult": 1.0,
		"spread_mult": 1.0,
		"temp_rise_mult": 1.0,
		"evo_threshold_mult": 1.0,
		"hq_collapse_limit": 80.0,
		"pollution_mult": 1.0
	},
	"admiral": {
		"id": "admiral",
		"name_key": "diff.admiral.name",
		"desc_key": "diff.admiral.desc",
		"badge": "🔴 ADMIRAL",
		"resource_mult": 0.8,
		"spread_mult": 1.35,
		"temp_rise_mult": 1.35,
		"evo_threshold_mult": 0.85,
		"hq_collapse_limit": 68.0,
		"pollution_mult": 1.20
	}
}

# --- Global Ocean Summits (every 5 years: 2031, 2036, 2041) -------------------
const SUMMIT_TICKS := [60, 120, 180]

# --- Coalition HQ Rule --------------------------------------------------------
const HQ_COLLAPSE_DEFAULT := 80.0
