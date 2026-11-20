-- ПИКСЕЛЬНЫЙ ОСТРОВ (LÖVE2D, горизонтально, сенсорное управление)
-- Нужен файл font.ttf рядом с main.lua (кириллица).
-- ПК: WASD/стрелки, Shift = бег, Пробел = удар, E = действие, C = сумка, Q = оружие, X = отмена, Esc = меню.

local lg = love.graphics
local WORLD, CELL = 2200, 12
local LAKE = {x = 700, y = 500, w = 260, h = 200}
local SP = {x = 400, y = 600}

local PAL = {
  k = {.10, .07, .08}, s = {.93, .72, .55}, S = {.74, .50, .37}, h = {.27, .15, .07},
  F = {.45, .28, .12}, f = {.64, .43, .20}, B = {.55, .40, .26}, b = {.86, .76, .60},
  y = {.95, .80, .25}, q = {.72, .56, .16}, Y = {1, .85, .2}, w = {1, 1, 1},
  R = {.90, .20, .25}, M = {.75, .35, .20}, m = {.92, .55, .38}, Q = {.50, .27, .12},
  C = {.30, .60, 1}, c = {.75, .90, 1}, a = {.55, .55, .58}, A = {.36, .36, .40}, L = {.80, .80, .82},
  T = {.52, .36, .20}, t = {.36, .24, .12}, l = {.78, .58, .32},
  G = {.30, .62, .38}, g = {.18, .42, .26}, N = {.62, .20, .18}, n = {.40, .10, .10},
  P = {.28, .65, .25}, p = {.45, .80, .35}, d = {.12, .38, .18}, J = {.15, .50, .35}, j = {.30, .65, .45},
  o = {.95, .50, .10}, W = {1, .95, .60},
  E = {.42, .50, .26}, e = {.26, .32, .16}, O = {.85, .50, .15},
  D = {.38, .27, .17},
}

local PL_BASE = {"...kkkk...", "..khhhhk..", ".khhhhhhk.", ".khssshhk.", ".kskssksk.", ".kssssssk.",
  "..kSSSSk..", ".ksssssSk.", "ksssFFsssk", "ksSkFFkSsk", "..kFFFFk..", "..kFffFk.."}
local function playerRows(l1, l2)
  local r = {}
  for i, v in ipairs(PL_BASE) do r[i] = v end
  r[13], r[14] = l1, l2
  return r
end

local SPR = {
  playerA = playerRows("..ksskssk.", "..kkk.kkk."),
  playerB = playerRows("...kssk...", "...kkkk..."),
  saddle = {"...kkkkkk...", "..kTTTTTTk..", ".kTTlllTTTk.", "kTTTTTTTTTTk", "kttTTTTTTttk", ".kttkkkkttk.", "..kk....kk.."},
  tree = {"....kkkkkk....", "...kppppppk...", "..kppPPppPpk..", ".kppPPPPpPPPk.", ".kpPPPPPPPPdk.",
          "kpPPPPPPPPPddk", "kPPPPddPPPdddk", "kPPPddddPPdddk", ".kPPdddddddddk", ".kddddddddddk.",
          "..kkddddddkk..", "....kkTTkk....", ".....kTtk.....", ".....kTtk.....", ".....kTtk.....",
          "....kTTtk.....", "...kTTTttk...."},
  rock = {"....kkkk....", "..kkLLLLkk..", ".kLLLLaaaak.", "kLLLaaaaaaak", "kLLaaaaaaaak", "kLaaaaaaAAAk",
          "kaaaaaAAAAAk", ".kaaAAAAAAk.", "..kkkkkkkk.."},
  bush = {"...kkkkkk...", "..kddPPddk..", ".kdPPRPPpdk.", "kdPpPPPRPPdk", "kPPPRPPPpPPk",
          "kdPPPPRPPPdk", ".kddPPPPPddk", "..kkdddddkk.", "....kkkkk..."},
  fire = {".....o....", "....oyo...", "...oyyyo..", "..oyyWyyo.", "..oyyyyyo.", "..kooyook.",
          ".kLTtTtLk.", "kLLTTTTLLk", ".kkkkkkkk."},
  -- иконки 8x8
  ic_wood = {"........", "..kkkkk.", ".kTTTTTk", "kTtTTllk", "kTTTTlLk", ".kTTTTTk", "..kkkkk.", "........"},
  ic_stone = {"........", "..kkkk..", ".kLLaak.", "kLaaaaAk", "kaaaaAAk", ".kAAAAk.", "..kkkk..", "........"},
  ic_thatch = {"..y..y..", ".yqyyqy.", "yqyyyyqy", "tttttttt", "yyqyyyqy", ".yyyyyy.", "..yyyy..", "........"},
  ic_fiber = {"..P..P..", ".PP.PP..", ".P.PP.P.", "P..PP..P", ".P.PP.P.", "..PPPP..", "...PP...", "........"},
  ic_flint = {"........", "...kk...", "..kAAk..", ".kAALAk.", ".kALAAk.", "..kAAk..", "...kk...", "........"},
  ic_hide = {"........", ".kkkkkk.", "kBBBBBBk", "kBbBBbBk", "kBBBBBBk", "kBbBBbBk", ".kBBBBk.", "..kkkk.."},
  ic_berry = {"...PP...", "..kRRk..", ".kRwRRk.", ".kRRRRk.", "..kRRk..", "...kk...", "........", "........"},
  ic_meat = {"..kkkk..", ".kMMMMk.", "kMmmMMMk", "kMMMMMMk", ".kMMMMk.", "..kkwk..", "...kwwk.", "...kkkk."},
  ic_saddle = {"........", "..kkkk..", ".kBBBBk.", "kBBBBBBk", "kBkkkkBk", "kBk..kBk", ".kk..kk.", "........"},
  ic_club = {"......kk", ".....kTk", "....kTtk", "...kTtk.", "..kTtk..", ".kTtk...", "kTTk....", "kkk....."},
  ic_hatchet = {"kkkk....", "kaaak...", "kaAAkk..", ".kkkkTk.", "....kTtk", "...kTtk.", "..kTtk..", "..kkk..."},
  ic_pick = {".kkkkkk.", "kaaaaaak", "kAAkkAAk", "..kkTkk.", "...kTk..", "...kTk..", "...kTk..", "...kkk.."},
  ic_spear = {"......kk", ".....kLk", "....kLk.", "...kTk..", "..kTk...", ".kTk....", "kTk.....", "kk......"},
  ic_armor = {"........", ".kk..kk.", "kBBkkBBk", "kBBBBBBk", "kBbBBbBk", "kBBBBBBk", ".kBBBBk.", "..kkkk.."},
  hud_heart = {".kk..kk.", "kRRkkRRk", "kRwRRRRk", "kRRRRRRk", ".kRRRRk.", "..kRRk..", "...kk..."},
  hud_bolt = {"...kkkk.", "..kYYYk.", ".kYYYk..", "kYYYYYk.", ".kkYYYk.", "...kYYk.", "..kYYk..", "..kkk..."},
  hud_drop = {"...kk...", "...kk...", "..kCCk..", ".kCCCCk.", "kCcCCCCk", "kCcCCCCk", ".kCCCCk.", "..kkkk.."},
  hud_weight = {"..kkkk..", ".k....k.", ".kkkkkk.", "kaaaaaak", "kaaaaaAk", "kaaaaAAk", ".kAAAAk.", "..kkkk.."},
}

local ANIM = {
  dodo = {
    walk = {
      {".......................", "..............kkk......", ".............kBBBk.....", "......kkkkkkkBBBBBkkk..", "..kkkkBBBBBBkBBwkyyyyk.", ".kDDBBBBBBBBBBBBBykyyk.", "kDDDBBDDDDBBBbbbBoooyk.", "kDDBBDDDDDDBBbbbkkkkk..", "kDDBBDDDDDDBBbbk.......", ".kkBBBDDDDBBBbbk.......", "...kBbbbbbbbbbk........", "....kbbbbbbbbk.........", ".....kbobbbok..........", "......kokkkok..........", ".....koookkok..........", "......kkkkoook.........", "..........kkk..........", "......................."},
      {".......................", ".......................", ".............kkkk......", ".......kkkk.kBBBBk.....", ".....kkBBBBkkBBwkykkk..", ".kkkkBBBBBBBBBBBBykyyk.", "kDDDBBBBBBBBBBBBBooook.", "kDDDBBDDDDBBBbbbkkkok..", "kDDBBDDDDDDBBbbk...k...", "kDDBBDDDDDDBBbbk.......", ".kkkBBDDDDBBBbk........", "...kBbbbbbbbbbk........", "....kbbobbbobk.........", ".....kkkobook..........", ".......kokok...........", ".......koook...........", "........kkk............", "......................."},
      {".......................", "..............kkk......", ".............kBBBk.....", "......kkkkkkkBBBBBkkk..", "..kkkkBBBBBBkBBwkyyyyk.", ".kDDBBBBBBBBBBBBBykyyk.", "kDDDBBDDDDBBBbbbBoooyk.", "kDDBBDDDDDDBBbbbkkkkk..", "kDDBBDDDDDDBBbbk.......", ".kkBBBDDDDBBBbbk.......", "...kBbbbbbbbbbk........", "....kbbbbbbbbk.........", ".....kbobbbok..........", "......kokkkok..........", "......kokkoook.........", ".....koookkkk..........", "......kkk..............", "......................."},
      {".......................", ".......................", ".............kkkk......", ".......kkkk.kBBBBk.....", ".....kkBBBBkkBBwkykkk..", ".kkkkBBBBBBBBBBBBykyyk.", "kDDDBBBBBBBBBBBBBooook.", "kDDDBBDDDDBBBbbbkkkok..", "kDDBBDDDDDDBBbbk...k...", "kDDBBDDDDDDBBbbk.......", ".kkkBBDDDDBBBbk........", "...kBbbbbbbbbbk........", "....kbbobbbobk.........", ".....koobbkkok.........", ".....kokkk.kok.........", "....kook...kook........", ".....kk.....kk.........", "......................."},
    },
    idle = {
      {".......................", "..............kkk......", ".............kBBBk.....", "......kkkkkkkBBBBBkkk..", "..kkkkBBBBBBkBBwkyyyyk.", ".kDDBBBBBBBBBBBBBykyyk.", "kDDDBBDDDDBBBbbbBoooyk.", "kDDBBDDDDDDBBbbbkkkkk..", "kDDBBDDDDDDBBbbk.......", ".kkBBBDDDDBBBbbk.......", "...kBbbbbbbbbbk........", "....kbbbbbbbbk.........", ".....kbobbbok..........", "......kokkkok..........", "......kok.kok..........", ".....koookoook.........", "......kkk.kkk..........", "......................."},
    },
    peck = {
      {".......................", ".......................", ".......................", "......kkkkkk...........", "..kkkkBBBBBBkk..kkk....", ".kDDBBBBBBBBBBkkBBBk...", "kDDDBBDDDDBBBbbbBBBBkk.", "kDDBBDDDDDDBBbbbBwkyyyk", "kDDBBDDDDDDBBbbbBBBykyy", ".kkBBBDDDDBBBbbkBBBoooo", "...kBbbbbbbbbbk.kkkkkkk", "....kbbbbbbbbk.........", ".....kbobbbok..........", "......kokkkok..........", "......kok.kok..........", ".....koookoook.........", "......kkk.kkk..........", "......................."},
      {".......................", ".......................", ".......................", "......kkkkkk....kk.....", "..kkkkBBBBBBkk.kBBk....", ".kDDBBBBBBBBBBkBBBBkkk.", "kDDDBBDDDDBBBbbbwkByyyk", "kDDBBDDDDDDBBbbbBBBkyyy", "kDDBBDDDDDDBBbbbBBBoook", ".kkBBBDDDDBBBbbkkkkkkk.", "...kBbbbbbbbbbk........", "....kbbbbbbbbk.........", ".....kbobbbok..........", "......kokkkok..........", "......kok.kok..........", ".....koookoook.........", "......kkk.kkk..........", "......................."},
    },
  },
  raptor = {
    walk = {
      {"...............................kkkk.........", "..............................kGGGGk........", ".............................kGGGwkGk.......", "............................kGGGGGGGGk......", "............................kGGGGGwGwk......", ".................kk..kkkkkkkGGGGkkkkk.......", "..........kkkkkkkGgkkGGGGGGGGGGk............", "......kkkkGGgGGgGGgGGgGGgGGGbbGk............", "...kkkgGGgGGgGGgGGgGGgGGgGGGbbk.............", ".kkgGGgGGgGGgGGgGGgGGgGGgGGGbbkk............", "kGGgGGgGGgGGgGGgGGgGGgGGgGGGGGGGk...........", ".kkkkkkGGgGGgGGgGGgGGbbbbbbbbkkGwk..........", ".......kkkkkkkkkkkkkGGGGGGkkk..kk...........", "...................kGGGGGGggk...............", "..................kkGGGGGkggk...............", ".................kgGGGGGGkggk...............", ".................kgGGGGGGwggk...............", "..................kkkkkkkkggkkk.............", ".......................kgggggggk............", "........................kkkkkkwk............", "..............................k............."},
      {"............................................", "...............................kkkk.........", "..............................kGGGGk........", ".............................kGGGwkGk.......", ".............................kGGGGGGGk......", "............................kGGGGGwGwk......", "................kkk..kkkkkkkGGGGGGkkk.......", "............kkkkGGgkkgGGgGGGGGGkkk..........", "........kkkkgGGgGGgGGgGGgGGGbbbk............", ".....kkkGgGGgGGgGGgGGgGGgGGGbbk.............", "..kkkGgGGgGGgGGgGGgGGgGGgGGGbbkk............", ".kGgGGgGGgGGgGGgGGgGGbbbbbbbbGGGk...........", "kGGgGGgGGgGGgGGgGGgGGbbbbbbbkkkkwk..........", ".kkkkkkkkkkkkkkkkkkkGGGGGGggk...k...........", "....................kGGGGkggk...............", ".....................kGGkkgggk..............", "....................kGGGGGGGk...............", "....................kGGGGGGwk...............", ".....................kggggggk...............", "......................kkkkkwk...............", "...........................k................"},
      {"................................kk..........", "...............................kGGk.........", "..............................kGGwkkk.......", ".............................kGGGGGGGk......", "............................kGGGGGwGwk......", "............................kGGGGGGkk.......", ".................kk..kkkkkkkGGGkkkk.........", "............kkkkkGgkkgGGgGGGbbGk............", "..........kkgGGgGGgGGgGGgGGGbbbk............", ".......kkkGGgGGgGGgGGgGGgGGGbbk.............", "....kkkGGgGGgGGgGGgGGgGGgGGGbbkk............", "..kkGGgGGgGGgGGgGGgGGbbbbbbbbGGGk...........", ".kGgGGgGGgGGgGGgGGgGGbbbbbbbkkkkwk..........", "kGkkkkkkkkkkkkkkkkkkGGGGGGggk...k...........", ".k..................kGGGGkggk...............", ".....................kGGkkgggk..............", ".....................kGGgggkk...............", "....................kGGGGGGwk...............", "....................kGGGGGGGk...............", ".....................kkkkkkwk...............", "...........................k................"},
      {"...............................kkkk.........", "..............................kGGGGk........", ".............................kGGGwkGk.......", "............................kGGGGGGGGk......", "............................kGGGGGwGwk......", "..................k..kkkkkkkGGGGkkkkk.......", ".............kkkkkgkkGGGGGGGGGGk............", "..........kkkGGgGGgGGgGGgGGGbbGk............", ".......kkkGGgGGgGGgGGgGGgGGGbbk.............", ".....kkGGgGGgGGgGGgGGgGGgGGGbbkk............", "...kkGgGGgGGgGGgGGgGGgGGgGGGGGGGk...........", ".kkgGGgGGgGGgGGgGGgGGbbbbbbbbkkGwk..........", "kGGgGkkkkkkkkkkkkkkkGGGGGGkkk..kk...........", ".kkkk..............kGGGGGGggk...............", "....................kGGGGkggk...............", "....................kGGkkkggkkk.............", "..................kkGGkkggggggwk............", ".................kgGGGGGGkkkkkk.............", ".................kgGGGGGGk..................", "..................kkkkkkkwk.................", ".........................k.................."},
      {"............................................", "...............................kkkk.........", "..............................kGGGGk........", ".............................kGGGwkGk.......", ".............................kGGGGGGGk......", "............................kGGGGGwGwk......", "................kkk..kkkkkkkGGGGGGkkk.......", "...........kkkkkGGgkkgGGgGGGGGGkkk..........", ".......kkkkGgGGgGGgGGgGGgGGGbbbk............", "...kkkkGGgGGgGGgGGgGGgGGgGGGbbk.............", ".kkgGGgGGgGGgGGgGGgGGgGGgGGGbbkk............", "kGGgGGgGGgGGgGGgGGgGGbbbbbbbbGGGk...........", ".kkkkkkGGgGGgGGgGGgGGbbbbbbbkkkkwk..........", ".......kkkkkkkkkkkkkGGGGGGggk...k...........", "....................kGGGGkggk...............", "...................kGGGGkkggkk..............", "...............kkkkGGkkk..kkggkkkk..........", "..............kgGGgGGGk...kggggggwk.........", "..............kgGGgGGGk....kkkkkkk..........", "...............kkkkkkkwk....................", "......................k....................."},
      {"................................kk..........", "...............................kGGk.........", "..............................kGGwkkk.......", ".............................kGGGGGGGk......", "............................kGGGGGwGwk......", "............................kGGGGGGkk.......", "...............kkkk..kkkkkkkGGGkkkk.........", "........kkkkkkkgGGgkkgGGgGGGbbGk............", "....kkkkGgGGgGGgGGgGGgGGgGGGbbbk............", ".kkkGGgGGgGGgGGgGGgGGgGGgGGGbbk.............", "kGGgGGgGGgGGgGGgGGgGGgGGgGGGbbkk............", ".kkkGGgGGgGGgGGgGGgGGbbbbbbbbGGGk...........", "....kkkkkkGGgGGgGGgGGbbbbbbbkkkkwk..........", "..........kkkkkkkkkkGGGGGGggk...k...........", "...................kkGGGGkggk...............", "...............kkkkGGkGGkkggkk..............", "..............kgGGgGGGkk..kgggk.............", "..............kgGGgGGGwk...kgggkkk..........", "...............kkkkkkkk...kgggggggk.........", "...........................kkkkkkwk.........", ".................................k.........."},
    },
    idle = {
      {"............................................", "...............................kkkk.........", "..............................kGGGGkk.......", ".............................kGGGwkGGk......", "............................kGGGGGGGGk......", "............................kGGGGGwGwk......", "................kkk..kkkkkkkGGGGkkkkk.......", "...........kkkkkGGgkkgGGgGGGbbGk............", ".......kkkkGgGGgGGgGGgGGgGGGbbbk............", "....kkkGGgGGgGGgGGgGGgGGgGGGbbk.............", ".kkkGGgGGgGGgGGgGGgGGgGGgGGGbbkk............", "kGGgGGgGGgGGgGGgGGgGGbbbbbbbbGGGk...........", ".kkkkGgGGgGGgGGgGGgGGbbbbbbbkkkkwk..........", ".....kkkkkkkkkkkkkkkGGGGGGggk...k...........", "....................kGGGGkggk...............", "....................kGGGkkggk...............", "..................kkGGGkkkggk...............", ".................kgGGGGGGkggkkk.............", ".................kgGGGGGGggggggk............", "..................kkkkkkkwkkkkwk............", ".........................k....k............."},
      {"............................................", "................................kk..........", "...............................kGGk.........", "..............................kGGwkkk.......", ".............................kGGGGGGGk......", "......................kkkkk.kGGGGGwGwk......", "................kkk.kkGGGGGkGGGGGGGkk.......", "...........kkkkkGGgkGgGGgGGGGGGkkkk.........", ".......kkkkGgGGgGGgGGgGGgGGGbbbk............", "....kkkGGgGGgGGgGGgGGgGGgGGGbbk.............", ".kkkGGgGGgGGgGGgGGgGGgGGgGGGbbkk............", "kGGgGGgGGgGGgGGgGGgGGbbbbbbbbGGGk...........", ".kkkkGgGGgGGgGGgGGgGGbbbbbbbbkkkwk..........", ".....kkkkkkkkkkkkkkkGGGGGGggk...k...........", "....................kGGGGkggk...............", "....................kGGGkkggk...............", "..................kkGGGkkkggk...............", ".................kgGGGGGGkggkkk.............", ".................kgGGGGGGggggggk............", "..................kkkkkkkwkkkkwk............", ".........................k....k............."},
    },
    attack = {
      {"............................................", "..................................kkkk......", ".................................kGGGGkk....", "................................kGGGwkGGk...", "..............................kkGGGGGGGGk...", ".............................kGGGGGGGwGwk...", "................kkk..kkkkkkkkGGGGGkknnnnk...", "...........kkkkkGGgkkgGGgGGGGGGbbk.kGwGwk...", ".......kkkkGgGGgGGgGGgGGgGGGGGGbk...kGGGk...", "....kkkGGgGGgGGgGGgGGgGGgGGGGGGk.....kkk....", ".kkkGGgGGgGGgGGgGGgGGgGGgGGGGGkk............", "kGGgGGgGGgGGgGGgGGgGGbbbbbbbbGGGk...........", ".kkkkGgGGgGGgGGgGGgGGbbbbbbbkkkkwk..........", ".....kkkkkkkkkkkkkkkGGGGGGggk...k...........", "....................kGGGGkggk...............", "....................kGGGkkggk...............", "..................kkGGGkkkggk...............", ".................kgGGGGGGkggkkk.............", ".................kgGGGGGGggggggk............", "..................kkkkkkkwkkkkwk............", ".........................k....k............."},
    },
  },
  rex = {
    walk = {
      {"....................................................................", "....................................................................", "................................................kkkkkkkkkkkkkk......", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEykEEEEEkEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "..............................................kEEEEEEEEEEEEEEEk.....", "..............................................kEEEEEEEEEEEEEEEk.....", ".............................................kEEEEEwEwEwEwEwEwk.....", ".............................................kEEEEEbbbbbbbbbkk......", "............................................kEEEEEEbbbbbbbbbk.......", "...................................kkkkkkkk.kEEEEbbbbbkkkkkk........", ".................................kkEEEEOEEEkEOEEEbbbbbk.............", "................................kEEEEEOEEEEEOEEEEbbbbk..............", "...............................kEEEEEOEEEEEOEEEEEbbbbk..............", ".............................kkEEEEEOEEEEEOEEEEEbbbbbk..............", "......................kkkkkkkOEEEEEOEEEEEOEEEEEEbbbbbk..............", ".................kkkkkOEEEEEOEEEEEOEEEEEOEEEEEEEbbbbk...............", "..............kkkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEbbbbbk...............", "...........kkkOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEbbbbbk...............", "........kkkEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbbbbk...............", "......kkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbkwkwk...............", "....kkEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbbk.k.k................", "..kkEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbk.....................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbk......................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEeeek......................", "..kkkkkkkkkkkkkkkkkkkkkkkkkkkkEEEEEEEEEEEEeeek......................", "..............................kEEEEEEEEEEeeeek......................", "..............................kEEEEEEEEEEeeeek......................", "..............................kEEEEEEEEEeeeeek......................", ".............................kEEEEEEEEEEEEEEekkkkk..................", ".........................k...kEEEEEEEEEEEEEEeeeeeek.................", "........................kwk..kEEEEEEEEEEEEEEeeeeeek.................", ".........................k....kkkkkkkkkkkeeeeeeeeek.................", "........................................keeeeeeeewk.................", ".........................................kkkkkkkkk..................", "....................................................................", "...................................................................."},
      {"....................................................................", "....................................................................", "................................................kkkkkkkkkkkkkk......", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEykEEEEEkEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "..............................................kEEEEEEEEEEEEEEEk.....", "..............................................kEEEEEEEEEEEEEEEk.....", ".............................................kEEEEEwEwEwEwEwEwk.....", ".............................................kEEEEEbbbbbbbbbkk......", "............................................kEEEEEEbbbbbbbbbk.......", "...................................kkkkkkkk.kEEEEbbbbbkkkkkk........", ".................................kkEEEEOEEEkEOEEEbbbbbk.............", "................................kEEEEEOEEEEEOEEEEbbbbk..............", "...............................kEEEEEOEEEEEOEEEEEbbbbk..............", "..............................kEEEEEOEEEEEOEEEEEbbbbbk..............", "........................kkkkkkEEEEEOEEEEEOEEEEEEbbbbbk..............", "..................kkkkkkEEEEOEEEEEOEEEEEOEEEEEEEbbbbk...............", "...............kkkEEEOEEEEEOEEEEEOEEEEEOEEEEEOEbbbbbk...............", ".............kkEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEbbbbbk...............", "...........kkOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbbbbk...............", "........kkkEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbkwkwk...............", ".......kEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbbk.k.k................", ".....kkEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbk.....................", "....kEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbk......................", "..kkEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEeeek......................", ".kEEEEEEEEkkkkkkkkkkkkkkkkkkkkEEEEEEEEEEEEeeek......................", ".kEEkkkkkk....................kEEEEEEEEEEeeeek......................", "..kk..........................kEEEEEEEEEEeeeek......................", "...............................kEEEEEEEEeeeeek......................", "................................kEEEEEEEekkkkk......................", ".................................kEEEEEEeeeeeek.....................", "..................................kEEEEEEeeeeekk....................", ".................................kEEEEEEEEEEEEEEk...................", ".............................k...kEEEEEEEEEEEwEEk...................", "............................kwk..kEEEEEEEEEEEEEEk...................", ".............................k....kkkkkkkkkkkkkk....................", "...................................................................."},
      {"....................................................................", "....................................................................", "................................................kkkkkkkkkkkkkk......", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEykEEEEEkEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "..............................................kEEEEEEEEEEEEEEEk.....", "..............................................kEEEEEEEEEEEEEEEk.....", ".............................................kEEEEEwEwEwEwEwEwk.....", ".............................................kEEEEEbbbbbbbbbkk......", "............................................kEEEEEEbbbbbbbbbk.......", "...................................kkkkkkkk.kEEEEbbbbbkkkkkk........", ".................................kkEEEEOEEEkEOEEEbbbbbk.............", "................................kEEEEEOEEEEEOEEEEbbbbk..............", "...............................kEEEEEOEEEEEOEEEEEbbbbk..............", ".............................kkEEEEEOEEEEEOEEEEEbbbbbk..............", "......................kkkkkkkOEEEEEOEEEEEOEEEEEEbbbbbk..............", ".................kkkkkOEEEEEOEEEEEOEEEEEOEEEEEEEbbbbk...............", "..............kkkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEbbbbbk...............", "...........kkkOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEbbbbbk...............", "........kkkEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbbbbk...............", "......kkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbkwkwk...............", "....kkEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbbk.k.k................", "..kkEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbk.....................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbk......................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEeeek......................", "..kkkkkkkkkkkkkkkkkkkkkkkkkkkkEEEEEEEEEEEEeeek......................", "..............................kEEEEEEEEEEeeeekkkkk..................", "..............................kEEEEEEEEEEeeeeeeeeek.................", "...............................kEEEEEEEEeeeeeeeeeek.................", "...............................kEEEEEEkkkeeeeeeeeek.................", "..............................kEEEEEEEk.keeeeeeeewk.................", "..............................kEEEEEEkkkkkkkkkkkkk..................", ".............................kEEEEEEEEEEEEEEk.......................", ".........................k...kEEEEEEEEEEEEEEk.......................", "........................kwk..kEEEEEEEEEEEEEEk.......................", ".........................k....kkkkkkkkkkkkkk........................", "...................................................................."},
      {"....................................................................", "....................................................................", "................................................kkkkkkkkkkkkkk......", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEykEEEEEkEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "..............................................kEEEEEEEEEEEEEEEk.....", "..............................................kEEEEEEEEEEEEEEEk.....", ".............................................kEEEEEwEwEwEwEwEwk.....", ".............................................kEEEEEbbbbbbbbbkk......", "............................................kEEEEEEbbbbbbbbbk.......", "...................................kkkkkkkk.kEEEEbbbbbkkkkkk........", ".................................kkEEEEOEEEkEOEEEbbbbbk.............", "................................kEEEEEOEEEEEOEEEEbbbbk..............", "...............................kEEEEEOEEEEEOEEEEEbbbbk..............", "............................kkkEEEEEOEEEEEOEEEEEbbbbbk..............", "...................kkkkkkkkkEOEEEEEOEEEEEOEEEEEEbbbbbk..............", "...............kkkkEEEOEEEEEOEEEEEOEEEEEOEEEEEEEbbbbk...............", "...........kkkkOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEbbbbbk...............", ".......kkkkEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEbbbbbk...............", ".....kkOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbbbbk...............", "..kkkEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbkwkwk...............", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbbk.k.k................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbk.....................", "..kkEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbk......................", "....kkkkkkEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEeeek......................", "..........kkkkkkkkkkkkkkkkkkkkEEEEEEEEEEEEeeeek.....................", "..............................kEEEEEEEEEEeeeeeek....................", "..............................kEEEEEEEEEEeeeeeek....................", "..............................kEEEEEEEEEeeeeeeeek...................", ".............................kEEEEEEEEkkkkkkeeeeekkkkk..............", "............................kEEEEEEkkk......keeeeeeeeek.............", "..........................kkEEEEEEkkkkkk....keeeeeeeeek.............", ".........................kEEEEEEEEEEEEEEk...keeeeeeeeek.............", ".....................k...kEEEEEEEEEEEEEEk...keeeeeeeewk.............", "....................kwk..kEEEEEEEEEEEEEEk....kkkkkkkkk..............", ".....................k....kkkkkkkkkkkkkk............................", "...................................................................."},
    },
    idle = {
      {"....................................................................", "....................................................................", "................................................kkkkkkkkkkkkkk......", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEykEEEEEkEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "..............................................kEEEEEEEEEEEEEEEk.....", "..............................................kEEEEEEEEEEEEEEEk.....", ".............................................kEEEEEwEwEwEwEwEwk.....", ".............................................kEEEEEbbbbbbbbbkk......", "............................................kEEEEEEbbbbbbbbbk.......", "...................................kkkkkkkk.kEEEEbbbbbkkkkkk........", ".................................kkEEEEOEEEkEOEEEbbbbbk.............", "................................kEEEEEOEEEEEOEEEEbbbbk..............", "...............................kEEEEEOEEEEEOEEEEEbbbbk..............", ".............................kkEEEEEOEEEEEOEEEEEbbbbbk..............", "......................kkkkkkkOEEEEEOEEEEEOEEEEEEbbbbbk..............", ".................kkkkkOEEEEEOEEEEEOEEEEEOEEEEEEEbbbbk...............", "..............kkkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEbbbbbk...............", "...........kkkOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEbbbbbk...............", "........kkkEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbbbbk...............", "......kkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbkwkwk...............", "....kkEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbbk.k.k................", "..kkEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbk.....................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbk......................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEeeek......................", "..kkkkkkkkkkkkkkkkkkkkkkkkkkkkEEEEEEEEEEEEeeek......................", "..............................kEEEEEEEEEEeeeek......................", "..............................kEEEEEEEEEEeeeek......................", "...............................kEEEEEEEEeeeeek......................", "...............................kEEEEEEkkeeeeekkkkk..................", "..............................kEEEEEEEk.keeeeeeeeek.................", "..............................kEEEEEEkkkkeeeeeeeeek.................", ".............................kEEEEEEEEEEEEEEeeeeeek.................", ".........................k...kEEEEEEEEEEEEEEeeeeewk.................", "........................kwk..kEEEEEEEEEEEEEEkkkkkk..................", ".........................k....kkkkkkkkkkkkkk........................", "...................................................................."},
      {"....................................................................", "....................................................................", "....................................................................", "................................................kkkkkkkkkkkkkk......", "...............................................kEEEEEEEEEEEEEEk.....", "...............................................kEEEEEEykEEEEEkk.....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "...............................................kEEEEEEEEEEEEEEEk....", "..............................................kEEEEEEEEEEEEEEEk.....", "..............................................kEEEEwEwEwEwEwEwk.....", ".............................................kEEEEEEEEEEEEEEEk......", "............................................kEEEEEEbbbbbbbbbk.......", "..................................kkkkkkkkkkkEEEEbbbbbbbbbbbk.......", ".................................kEEEEEOEEEEEOEEEbbbbbkkkkkk........", "...............................kkEEEEEOEEEEEOEEEEbbbbk..............", "..............................kOEEEEEOEEEEEOEEEEEbbbbk..............", ".............................kkEEEEEOEEEEEOEEEEEbbbbbk..............", "......................kkkkkkkOEEEEEOEEEEEOEEEEEEbbbbbk..............", ".................kkkkkOEEEEEOEEEEEOEEEEEOEEEEEEEbbbbk...............", "..............kkkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEbbbbbk...............", "...........kkkOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEbbbbbk...............", "........kkkEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbbbbk...............", "......kkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbkwkwk...............", "....kkEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbbk.k.k................", "..kkEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbbk....................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbkk.....................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEeeek......................", "..kkkkkkkkkkkkkkkkkkkkkkkkkkkkEEEEEEEEEEEEeeek......................", "..............................kEEEEEEEEEEeeeek......................", "..............................kEEEEEEEEEEeeeek......................", "...............................kEEEEEEEEeeeeek......................", "...............................kEEEEEEkkeeeeekkkkk..................", "..............................kEEEEEEEk.keeeeeeeeek.................", "..............................kEEEEEEkkkkeeeeeeeeek.................", ".............................kEEEEEEEEEEEEEEeeeeeek.................", ".........................k...kEEEEEEEEEEEEEEeeeeewk.................", "........................kwk..kEEEEEEEEEEEEEEkkkkkk..................", ".........................k....kkkkkkkkkkkkkk........................", "...................................................................."},
    },
    attack = {
      {"....................................................................", "....................................................................", "....................................................kkkkkkkkkkkkkk..", "...................................................kEEEEEEEEEEEEEEk.", "...................................................kEEEEEEEEEEEEEEk.", "...................................................kEEEEEEykEEEEEkEk", "...................................................kEEEEEEEEEEEEEEEk", "..................................................kkEEEEEEEEEEEEEEEk", ".................................................kEEEEEEEEEEEEEEEEEk", "................................................kEEEEEEEEEEEEEEEEEk.", "...............................................kEEEEEEnnnnnnnnnnnnk.", "...............................................kEEEEEEEwnwnwnwnwnwk.", "..............................................kEEEEEEEEnnnnnnnnnnnk.", ".............................................kEEEEEEEEEnnnnnnnnnnk..", "...................................kkkkkkkk.kEEEEbbbbbbbwbwbwbwbwk..", ".................................kkEEEEOEEEkkOEEEbbbbbbbbbbbbbbbbk..", "................................kEEEEEOEEEEEOEEEEbbbbbbkkbbbbbbbk...", "...............................kEEEEEOEEEEEOEEEEEbbbbbk..kkkbbbbk...", ".............................kkEEEEEOEEEEEOEEEEEbbbbbbk.....kkkk....", "......................kkkkkkkOEEEEEOEEEEEOEEEEEEbbbbbk..............", ".................kkkkkOEEEEEOEEEEEOEEEEEOEEEEEEEbbbbbk..............", "..............kkkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEbbbbbk...............", "...........kkkOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEbbbbbk...............", "........kkkEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbbbbk...............", "......kkEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEEEOEEEbbkwkwk...............", "....kkEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbbk.k.k................", "..kkEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbbk.....................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEbbbbbbbbbbbbbbk......................", ".kEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEeeek......................", "..kkkkkkkkkkkkkkkkkkkkkkkkkkkkEEEEEEEEEEEEeeek......................", "..............................kEEEEEEEEEEeeeek......................", "..............................kEEEEEEEEEEeeeek......................", "...............................kEEEEEEEEeeeeek......................", "...............................kEEEEEEkkeeeeekkkkk..................", "..............................kEEEEEEEk.keeeeeeeeek.................", "..............................kEEEEEEkkkkeeeeeeeeek.................", ".............................kEEEEEEEEEEEEEEeeeeeek.................", ".........................k...kEEEEEEEEEEEEEEeeeeewk.................", "........................kwk..kEEEEEEEEEEEEEEkkkkkk..................", ".........................k....kkkkkkkkkkkkkk........................", "...................................................................."},
    },
  },
}
SPR.dodo, SPR.raptor, SPR.rex = ANIM.dodo.idle[1], ANIM.raptor.idle[1], ANIM.rex.idle[1]

-- ===== предметы =====
local ITEMS = {"wood", "stone", "thatch", "fiber", "flint", "hide", "berry", "meat", "cooked", "saddle"}
local INAME = {wood = "Дерево", stone = "Камень", thatch = "Солома", fiber = "Волокно", flint = "Кремень",
               hide = "Шкура", berry = "Ягоды", meat = "Сырое мясо", cooked = "Жареное мясо", saddle = "Седло"}
local IDESC = {
  wood = "Прочная древесина. Нужна для построек и инструментов.",
  stone = "Тяжёлый камень. Для инструментов и костра.",
  thatch = "Солома. Для соломенных построек и кровати.",
  fiber = "Волокно растений. Для кровати, брони и седла.",
  flint = "Острый кремень. Нужен для копья.",
  hide = "Шкура. Для кровати, брони и седла.",
  berry = "Сочные ягоды. Лучший корм для додо.",
  meat = "Сырое мясо. Лучше пожарить на костре. Корм для хищников.",
  cooked = "Жареное мясо. Очень сытное. Лучший корм для хищников.",
  saddle = "Седло. Наденьте на прирученного динозавра и езжайте верхом.",
}
local IWT = {wood = 0.5, stone = 1, thatch = 0.2, fiber = 0.2, flint = 0.5, hide = 0.5, berry = 0.2, meat = 1, cooked = 1, saddle = 8}
local FOOD = {berry = 12, meat = 15, cooked = 45}

-- ===== постройки =====
local BD = {
  tfloor = {spr = "tfloor", name = "Соломенный фундамент", floor = true, cost = {thatch = 10}},
  twall  = {spr = "twall",  name = "Соломенная стена", solid = true, mobsolid = true, hp = 20, cost = {thatch = 12, wood = 1}},
  tdoor  = {spr = "tdoor",  name = "Соломенная дверь", mobsolid = true, hp = 12, cost = {thatch = 8, wood = 2}},
  wfloor = {spr = "wfloor", name = "Деревянный фундамент", floor = true, cost = {wood = 4}},
  wwall  = {spr = "wwall",  name = "Деревянная стена", solid = true, mobsolid = true, hp = 50, cost = {wood = 8}},
  wdoor  = {spr = "wdoor",  name = "Деревянная дверь", mobsolid = true, hp = 30, cost = {wood = 6}},
  fire   = {spr = "fire",   name = "Костёр", timer = 180, cost = {wood = 5, stone = 2}},
  bed    = {spr = "bed",    name = "Кровать", cost = {hide = 6, thatch = 10, fiber = 6}},
}

-- ===== инграммы =====
local ENGRAMS = {
  {id = "club",    name = "Деревянная дубинка", lvl = 1, pts = 1, cost = {wood = 4, thatch = 6}, flag = "club", icon = "ic_club",
   desc = "Оглушает динозавров. Бейте, пока шкала торпора не заполнится."},
  {id = "hatchet", name = "Каменный топор", lvl = 1, pts = 1, cost = {wood = 2, stone = 2, thatch = 4}, flag = "hatchet", icon = "ic_hatchet",
   desc = "Рубит деревья: даёт больше дерева."},
  {id = "pick",    name = "Каменная кирка", lvl = 1, pts = 1, cost = {wood = 2, stone = 2, thatch = 4}, flag = "pick", icon = "ic_pick",
   desc = "Добывает больше камня и кремня."},
  {id = "fire",    name = "Костёр", lvl = 2, pts = 1, cost = BD.fire.cost, build = "fire",
   desc = "Греет, лечит и светит ночью. На нём жарят мясо."},
  {id = "tfloor",  name = "Соломенный фундамент", lvl = 2, pts = 1, cost = BD.tfloor.cost, build = "tfloor",
   desc = "Основа для первого дома."},
  {id = "twall",   name = "Соломенная стена", lvl = 3, pts = 2, cost = BD.twall.cost, build = "twall",
   desc = "Слабая стена. Хищники её ломают."},
  {id = "tdoor",   name = "Соломенная дверь", lvl = 3, pts = 2, cost = BD.tdoor.cost, build = "tdoor",
   desc = "Проходите только вы, мобы нет."},
  {id = "spear",   name = "Копьё", lvl = 4, pts = 2, cost = {wood = 6, thatch = 8, flint = 4}, flag = "spear", icon = "ic_spear",
   desc = "Мощное оружие. Убивает, но не оглушает."},
  {id = "bed",     name = "Кровать", lvl = 5, pts = 3, cost = BD.bed.cost, build = "bed",
   desc = "Задаёт точку возрождения."},
  {id = "wfloor",  name = "Деревянный фундамент", lvl = 5, pts = 2, cost = BD.wfloor.cost, build = "wfloor",
   desc = "Крепкая основа для базы."},
  {id = "wwall",   name = "Деревянная стена", lvl = 6, pts = 3, cost = BD.wwall.cost, build = "wwall",
   desc = "Крепкая стена. Защита от хищников."},
  {id = "wdoor",   name = "Деревянная дверь", lvl = 6, pts = 3, cost = BD.wdoor.cost, build = "wdoor",
   desc = "Крепкая дверь. Мобы не пройдут."},
  {id = "armor",   name = "Шкурная броня", lvl = 7, pts = 4, cost = {hide = 8, fiber = 8}, flag = "armor", icon = "ic_armor",
   desc = "Снижает получаемый урон на 40%."},
  {id = "saddle",  name = "Седло", lvl = 8, pts = 5, cost = {hide = 15, fiber = 15}, item = "saddle", icon = "ic_saddle",
   desc = "Позволяет ездить на прирученном динозавре."},
}

local WP = {fists = {dmg = 1, torp = 3}, club = {dmg = 2, torp = 8}, spear = {dmg = 12, torp = 0}}
local WNAME = {fists = "КУЛАКИ", club = "ДУБИНКА", spear = "КОПЬЁ"}

local MOBDEF = {
  dodo    = {name = "Додо",       spr = "dodo",    sc = 1,    r = 3,  hp = 20,  torp = 30,  need = 4,  diet = "herb", meat = 1, hide = 1, dmg = 0,  spd = 40, ride = 55, xp = 4,  xpt = 20,  lv = {1, 10}, sad = {x = -2, y = 13}},
  parasaur= {name = "Паразавр",   spr = "parasaur",sc = 1.05, r = 6,  hp = 65,  torp = 65,  need = 7,  diet = "herb", meat = 3, hide = 3, dmg = 0,  spd = 48, ride = 95, xp = 16, xpt = 90,  lv = {3, 18}, sad = {x = 0, y = 15}},
  trike   = {name = "Трицератопс", spr = "trike",   sc = 1.15, r = 9,  hp = 150, torp = 150, need = 14, diet = "herb", meat = 5, hide = 7, dmg = 12, spd = 22, ride = 70, xp = 35, xpt = 180, lv = {8, 30}, sad = {x = 0, y = 17}},
  stego   = {name = "Стегозавр",  spr = "stego",   sc = 1.2,  r = 9,  hp = 180, torp = 170, need = 16, diet = "herb", meat = 6, hide = 8, dmg = 10, spd = 18, ride = 65, xp = 42, xpt = 210, lv = {10, 35}, sad = {x = 0, y = 18}},
  bronto  = {name = "Бронтозавр", spr = "bronto",  sc = 1.55, r = 13, hp = 360, torp = 320, need = 28, diet = "herb", meat = 10,hide = 14,dmg = 0,  spd = 13, ride = 55, xp = 95, xpt = 450, lv = {20, 55}, sad = {x = 0, y = 24}},
  raptor  = {name = "Раптор",     spr = "raptor",  sc = 1,    r = 6,  hp = 40,  torp = 50,  need = 6,  diet = "carn", meat = 2, hide = 2, dmg = 8,  spd = 30, ride = 85, xp = 12, xpt = 60,  lv = {5, 25}, sad = {x = 1, y = 14}},
  carno   = {name = "Карнотавр",  spr = "carno",   sc = 1.2,  r = 9,  hp = 145, torp = 180, need = 17, diet = "carn", meat = 7, hide = 8, dmg = 18, spd = 28, ride = 78, xp = 65, xpt = 280, lv = {18, 45}, sad = {x = 1, y = 18}},
  ptera   = {name = "Птеранодон", spr = "ptera",   sc = 1.05, r = 6,  hp = 75,  torp = 85,  need = 9,  diet = "carn", meat = 3, hide = 3, dmg = 5,  spd = 42, ride = 105,xp = 28, xpt = 140, lv = {8, 28}, sad = {x = 0, y = 13}},
  rex     = {name = "Рекс",       spr = "rex",     sc = 1,    r = 10, hp = 120, torp = 220, need = 20, diet = "carn", meat = 5, hide = 6, dmg = 25, spd = 24, ride = 65, xp = 80, xpt = 300, lv = {30, 60}, sad = {x = 2, y = 25}},
}

local S = {}
local W, H, Z, font, tinyFont, titleFont
local btn, stick, held = {}, nil, {}
local mobs, res, pops = {}, {}, {}
local patches, tufts, flowers = {}, {}, {}
local bl, grid, floors = {}, {}, {}
local spawnPt = {x = SP.x, y = SP.y}
local player, inv, clock
local prog = {lvl = 1, xp = 0, pts = 3, eng = {}}
local state, started = "menu", false
local menuBtns, pauseBtn = {}, {}
local craftOpen, tab = false, 1
local selIdx = {1, 1, 1, 1}
local creative = false
local toast = {txt = "", t = 0}

local function mkFont(size)
  if love.filesystem.getInfo("font.ttf") then return lg.newFont("font.ttf", size) end
  return lg.newFont(size)
end

local function sprite(rows, swap)
  local h, w = #rows, #rows[1]
  local d = love.image.newImageData(w, h)
  for y = 1, h do
    for x = 1, w do
      local c = rows[y]:sub(x, x)
      if swap and swap[c] then c = swap[c] end
      local p = PAL[c]
      if p then d:setPixel(x - 1, y - 1, p[1], p[2], p[3], 1)
      else d:setPixel(x - 1, y - 1, 0, 0, 0, 0) end
    end
  end
  local img = lg.newImage(d)
  img:setFilter("nearest", "nearest")
  return {img = img, w = w, h = h}
end

local function mkImg(w, h, fn)
  local d = love.image.newImageData(w, h)
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      local r, g, b, a = fn(x, y)
      if r then d:setPixel(x, y, r, g, b, a or 1) else d:setPixel(x, y, 0, 0, 0, 0) end
    end
  end
  local img = lg.newImage(d)
  img:setFilter("nearest", "nearest")
  return {img = img, w = w, h = h}
end
local function shade(c, f) return c[1] * f, c[2] * f, c[3] * f, 1 end
local WOOD, THATCH = {.68, .48, .22}, {.88, .76, .30}

local function mkWall(base, thatch)
  return mkImg(12, 18, function(x, y)
    if x == 0 or x == 11 or y == 0 or y == 17 then return .1, .07, .08, 1 end
    if y <= 5 then
      local f = (y == 1) and 1.25 or 1.1
      if y == 3 then f = 0.85 end
      if thatch and (x + y) % 3 == 0 then f = f * 0.85 end
      return shade(base, f)
    end
    if y == 6 then return shade(base, 0.55) end
    local f = 0.9
    if thatch then f = ((x * 2 + y) % 4 == 0) and 0.65 or 0.95
    else
      if x == 4 or x == 8 then f = 0.65 end
      if (x * 7 + y * 13) % 11 == 0 then f = 0.78 end
    end
    if y >= 15 then f = f * 0.75 end
    return shade(base, f)
  end)
end

local function mkDoor(base, thatch)
  return mkImg(12, 18, function(x, y)
    if x == 0 or x == 11 or y == 0 or y == 17 then return .1, .07, .08, 1 end
    if y <= 5 then return shade(base, (y == 1) and 1.25 or 1.05) end
    if y == 6 then return shade(base, 0.55) end
    if x <= 2 or x >= 9 or y <= 8 then return shade(base, (y >= 15) and 0.6 or 0.8) end
    local f = (x == 5 or x == 6) and 0.72 or 1.0
    if thatch and (x + y) % 3 == 0 then f = f * 0.85 end
    if x == 8 and y == 12 then return .95, .8, .25, 1 end
    return shade(base, f)
  end)
end

local function mkFloor(base, thatch)
  return mkImg(12, 12, function(x, y)
    local f = 1
    local row = math.floor(y / 4)
    if y % 4 == 3 then f = 0.72 end
    local off = (row % 2 == 0) and 0 or 6
    if (x + off) % 12 == 0 then f = 0.75 end
    if (x * 5 + y * 3) % 9 == 0 then f = f * 0.9 end
    if thatch and (x + y) % 3 == 0 then f = f * 0.85 end
    if x == 0 or y == 0 then f = f * 0.85 end
    return shade(base, f)
  end)
end

local function mkBed()
  return mkImg(12, 12, function(x, y)
    if x == 0 or x == 11 or y == 0 or y == 11 then return .1, .07, .08, 1 end
    if y <= 3 and x >= 2 and x <= 9 then return .96, .94, .90, 1 end
    if y >= 4 then
      local f = (y % 4 == 0) and 0.8 or 1
      return .8 * f, .18 * f, .2 * f, 1
    end
    return .5, .35, .2, 1
  end)
end

local function dist(ax, ay, bx, by) local dx, dy = ax - bx, ay - by return math.sqrt(dx * dx + dy * dy) end
local function clamp(v, a, b) return math.max(a, math.min(b, v)) end
local function inLake(x, y, pad)
  return x > LAKE.x - pad and x < LAKE.x + LAKE.w + pad and y > LAKE.y - pad and y < LAKE.y + LAKE.h + pad
end
local function pop(x, y, txt) pops[#pops + 1] = {x = x, y = y, txt = txt, t = 1.3} end
local function say(txt) toast.txt, toast.t = txt, 2.6 end

local function has(cost)
  if creative then return true end
  for k, v in pairs(cost) do if (inv[k] or 0) < v then return false end end
  return true
end
local function spend(cost)
  if creative then return end
  for k, v in pairs(cost) do inv[k] = inv[k] - v end
end
local function costStr(cost)
  local parts = {}
  for _, k in ipairs(ITEMS) do if cost[k] then parts[#parts + 1] = INAME[k] .. " " .. cost[k] end end
  return table.concat(parts, ", ")
end
local function weight()
  local w = 0
  for _, k in ipairs(ITEMS) do w = w + inv[k] * IWT[k] end
  return w
end
local function maxWeight() return 100 + (prog.lvl - 1) * 5 end

local function xpNeed(l) return 8 + 6 * l end
local function gainXP(n)
  prog.xp = prog.xp + n
  while prog.xp >= xpNeed(prog.lvl) do
    prog.xp = prog.xp - xpNeed(prog.lvl)
    prog.lvl = prog.lvl + 1
    prog.pts = prog.pts + 3
    say("НОВЫЙ УРОВЕНЬ! Уровень " .. prog.lvl .. " (+3 очка инграмм)")
  end
end

-- ===== сетка / постройки =====
local function key(cx, cy) return cx .. "," .. cy end
local function cellOf(x, y) return math.floor(x / CELL), math.floor(y / CELL) end
local function targetCell() return cellOf(player.x + player.fx * CELL, player.y - 2 + player.fy * CELL) end

local function near(kind, r)
  for _, b in ipairs(bl) do
    if b.kind == kind and dist(b.cx * CELL + CELL / 2, (b.cy + 1) * CELL - CELL / 2, player.x, player.y) < r then return true end
  end
  return false
end

local function addBuilding(kind, cx, cy)
  local d = BD[kind]
  local b = {kind = kind, cx = cx, cy = cy, hp = d.hp or 1, t = d.timer}
  if d.floor then floors[key(cx, cy)] = b else grid[key(cx, cy)] = b end
  bl[#bl + 1] = b
  return b
end

local function removeBuilding(b)
  if BD[b.kind].floor then floors[key(b.cx, b.cy)] = nil else grid[key(b.cx, b.cy)] = nil end
  for i, x in ipairs(bl) do if x == b then table.remove(bl, i) break end end
end

local function solidAt(x, y, mob)
  local b = grid[key(cellOf(x, y))]
  if b then
    local d = BD[b.kind]
    if d.solid or (mob and d.mobsolid) then return b end
  end
  return nil
end

local function blocked(x, y, r, mob)
  return solidAt(x - r, y, mob) or solidAt(x + r, y, mob) or solidAt(x - r, y - r, mob) or solidAt(x + r, y - r, mob)
end

local function tryMove(e, dx, dy, r, mob)
  local hit
  local nx = clamp(e.x + dx, r, WORLD - r)
  local b = blocked(nx, e.y, r, mob)
  if b then hit = b else e.x = nx end
  local ny = clamp(e.y + dy, 8, WORLD - 2)
  b = blocked(e.x, ny, r, mob)
  if b then hit = hit or b else e.y = ny end
  return hit
end

local function canPlace(kind, cx, cy)
  local d = BD[kind]
  if cx < 0 or cy < 0 or cx >= WORLD / CELL or cy >= WORLD / CELL then return false end
  local mx, my = cx * CELL + CELL / 2, cy * CELL + CELL / 2
  if inLake(mx, my, 0) then return false end
  if d.floor then return floors[key(cx, cy)] == nil end
  if grid[key(cx, cy)] then return false end
  for _, r in ipairs(res) do
    if r.alive and dist(r.x, r.y - 3, mx, my) < 9 then return false end
  end
  if d.solid or d.mobsolid then
    local pcx, pcy = cellOf(player.x, player.y - 1)
    if pcx == cx and pcy == cy then return false end
  end
  return true
end

local function place()
  local kind = player.build
  local d = BD[kind]
  local cx, cy = targetCell()
  if not has(d.cost) then say("Не хватает: " .. costStr(d.cost)); player.build = nil; return end
  if not canPlace(kind, cx, cy) then say("Сюда нельзя ставить"); return end
  spend(d.cost)
  addBuilding(kind, cx, cy)
  gainXP(1)
  if kind == "bed" then spawnPt = {x = cx * CELL + CELL / 2, y = cy * CELL + CELL / 2}; say("Точка возрождения задана") end
  if not has(d.cost) then player.build = nil end
end

-- ===== генерация мира =====
local function freeSpot(minSpawn)
  for _ = 1, 50 do
    local x, y = math.random(60, WORLD - 60), math.random(60, WORLD - 60)
    if not inLake(x, y, 16) and dist(x, y, SP.x, SP.y) > (minSpawn or 40) then return x, y end
  end
  return 100, 100
end

local function addMob(kind, px, py)
  local def = MOBDEF[kind]
  local x, y = freeSpot(kind == "dodo" and 40 or 220)
  if px then x, y = px, py end
  local lvl = math.random(def.lv[1], def.lv[2])
  local hp = def.hp * (1 + 0.04 * (lvl - 1))
  local m = {kind = kind, x = x, y = y, vx = 0, vy = 0, wt = 0, dir = 1, hit = 0, atk = 0,
             spr = S[def.spr], sc = def.sc, r = def.r * def.sc, lvl = lvl, hp = hp, maxhp = hp,
             torp = 0, maxtorp = def.torp, need = def.need, diet = def.diet, meat = def.meat, hide = def.hide,
             dmg = def.dmg * (1 + 0.03 * (lvl - 1)), spd = def.spd, ride = def.ride, sad = def.sad,
             xp = math.floor(def.xp * (1 + lvl * 0.05)), xpt = math.floor(def.xpt * (1 + lvl * 0.05)), name = def.name,
             animT = 0, moving = false, atkAnim = 0,
             ko = false, tame = 0, tamed = false, saddled = false, mounted = false}
  mobs[#mobs + 1] = m
end

local function addRes(kind)
  local x, y = freeSpot(30)
  local hp = (kind == "tree" or kind == "rock") and 4 or 2
  local spr = S[kind]
  if kind == "tree" and math.random() < 0.5 then spr = S.tree2 end
  res[#res + 1] = {kind = kind, x = x, y = y, hp = hp, maxhp = hp, spr = spr, alive = true, regrow = 0}
end

local function populate()
  mobs, res = {}, {}
  for _ = 1, 230 do addRes("tree") end
  for _ = 1, 110 do addRes("rock") end
  for _ = 1, 75 do addRes("bush") end
  for _ = 1, 24 do addMob("dodo") end
  for _ = 1, 9 do addMob("parasaur") end
  for _ = 1, 6 do addMob("trike") end
  for _ = 1, 5 do addMob("stego") end
  for _ = 1, 2 do addMob("bronto") end
  for _ = 1, 10 do addMob("raptor") end
  for _ = 1, 4 do addMob("carno") end
  for _ = 1, 5 do addMob("ptera") end
  for _ = 1, 2 do addMob("rex") end
end

local function spawnMob(kind, tamed, saddled)
  local x = clamp(player.x + player.fx * 26, 20, WORLD - 20)
  local y = clamp(player.y + player.fy * 26, 20, WORLD - 20)
  addMob(kind, x, y)
  local m = mobs[#mobs]
  if tamed then m.tamed, m.tame = true, 100 end
  if saddled then m.saddled = true end
  say("Призван: " .. m.name)
end

local function respawn()
  if player and player.mount then player.mount.mounted = false end
  player = {x = spawnPt.x, y = spawnPt.y, dir = 1, fx = 1, fy = 0, hp = 100, food = 100, water = 100, sta = 100, staDelay = 0,
            tools = {}, weap = "fists", build = nil, mount = nil,
            atkcd = 0, swing = 0, flash = 0, step = 0, dead = false, dt = 0}
  inv = {}
  for _, k in ipairs(ITEMS) do inv[k] = 0 end
end

local function newGame()
  bl, grid, floors = {}, {}, {}
  spawnPt = {x = SP.x, y = SP.y}
  prog = {lvl = 1, xp = 0, pts = 3, eng = {}}
  craftOpen = false
  selIdx = {1, 1, 1, 1}
  populate()
  player = nil
  respawn()
  clock = 60
end

-- ===== раскладка =====
local function layout()
  W, H = lg.getDimensions()
  Z = math.max(3, math.floor(H / 130))
  btn = {
    A = {x = W - H * 0.2, y = H - H * 0.2, r = H * 0.13},
    B = {x = W - H * 0.43, y = H - H * 0.11, r = H * 0.09},
    C = {x = W - H * 0.11, y = H - H * 0.43, r = H * 0.09},
    D = {x = W - H * 0.38, y = H - H * 0.37, r = H * 0.08},
    F = {x = W - H * 0.38, y = H - H * 0.37, r = H * 0.08},
  }
  font = mkFont(math.max(12, math.floor(H / 30)))
  tinyFont = mkFont(math.max(10, math.floor(H / 42)))
  titleFont = mkFont(math.floor(H / 10))
  pauseBtn = {x = W / 2, y = H * 0.08, r = H * 0.05}
  local bw, bh = H * 0.9, H * 0.12
  menuBtns = {
    {id = "play", x = W / 2 - bw / 2, y = H * 0.34, w = bw, h = bh},
    {id = "new",  x = W / 2 - bw / 2, y = H * 0.34 + bh * 1.2, w = bw, h = bh},
    {id = "creative", x = W / 2 - bw / 2, y = H * 0.34 + bh * 2.4, w = bw, h = bh},
    {id = "exit", x = W / 2 - bw / 2, y = H * 0.34 + bh * 3.6, w = bw, h = bh},
  }
end

local function panelGeom()
  local px, py, pw, ph = W * 0.04, H * 0.04, W * 0.92, H * 0.92
  local gap = H * 0.015
  local tabs, tabW = {}, H * 0.36
  for i = 1, creative and 4 or 3 do tabs[i] = {x = px + gap + (i - 1) * (tabW + gap), y = py + gap, w = tabW, h = H * 0.085} end
  local close = {x = px + pw - gap - H * 0.26, y = py + gap, w = H * 0.26, h = H * 0.085}
  local gy = py + H * 0.17
  local gh = py + ph - gap - gy
  local cols, rows = 6, 4
  local slot = math.min(gh / rows, H * 0.17)
  local slots = {}
  for i = 1, cols * rows do
    local c, r = (i - 1) % cols, math.floor((i - 1) / cols)
    slots[i] = {x = px + gap + c * slot, y = gy + r * slot, w = slot - 4, h = slot - 4}
  end
  local dx = px + gap + slot * cols + gap * 2
  local detail = {x = dx, y = gy, w = px + pw - gap - dx, h = gh}
  return px, py, pw, ph, tabs, close, slots, detail, gap
end

function love.load()
  math.randomseed(os.time())
  lg.setDefaultFilter("nearest", "nearest")
  for k, rows in pairs(SPR) do S[k] = sprite(rows) end
  S.tree2 = sprite(SPR.tree, {P = "J", p = "j"})
  S.ic_cooked = sprite(SPR.ic_meat, {M = "Q", m = "l"})
  S.wwall, S.wdoor, S.wfloor = mkWall(WOOD, false), mkDoor(WOOD, false), mkFloor(WOOD, false)
  S.twall, S.tdoor, S.tfloor = mkWall(THATCH, true), mkDoor(THATCH, true), mkFloor(THATCH, true)
  S.bed = mkBed()
  S.riderQuad = lg.newQuad(0, 0, 10, 11, S.playerB.img)
  S.anim = {}
  for kind, groups in pairs(ANIM) do
    S.anim[kind] = {}
    for g, list in pairs(groups) do
      S.anim[kind][g] = {}
      for i, rows in ipairs(list) do S.anim[kind][g][i] = sprite(rows) end
    end
  end

  -- Новые динозавры рисуются прямо кодом: никаких внешних картинок не требуется.
  local function makeDino(body, accent, style)
    local dark = {0.09, 0.07, 0.06}
    return mkImg(40, 30, function(x, y)
      local bodyPart = ((x - 19) / 10)^2 + ((y - 15) / 5)^2 <= 1
      local tail = x >= 3 and x <= 12 and y >= 13 - (12 - x) * 0.28 and y <= 17 + (12 - x) * 0.28
      local head = x >= 28 and x <= 36 and y >= 9 and y <= 14
      local neck = style == "bronto" and x >= 25 and x <= 30 and y >= 4 and y <= 15
      local legs = ((x >= 12 and x <= 15) or (x >= 22 and x <= 25)) and y >= 18 and y <= 26
      local shape = bodyPart or tail or head or neck or legs
      if style == "ptera" then
        shape = shape or (x >= 7 and x <= 33 and y >= 3 and y <= 13 and math.abs(y - (13 - math.abs(x - 20) * 0.55)) < 2)
      end
      if not shape then return nil end
      local edge = not (((x - 19) / 9)^2 + ((y - 15) / 4)^2 < 0.88) and bodyPart
      if edge or (tail and (x == 3 or y == 13 or y == 17)) or (head and (x == 28 or x == 36 or y == 9 or y == 14)) then
        return dark[1], dark[2], dark[3], 1
      end
      if style == "stego" and x >= 11 and x <= 27 and y >= 5 and y <= 11 and (x + y) % 4 <= 1 then
        return accent[1], accent[2], accent[3], 1
      end
      if style == "trike" and ((x >= 33 and x <= 38 and y >= 5 and y <= 9) or (x >= 30 and x <= 34 and y >= 6 and y <= 8)) then
        return 0.92, 0.82, 0.58, 1
      end
      if style == "bronto" and neck then return body[1] * 1.08, body[2] * 1.08, body[3] * 1.08, 1 end
      if style == "ptera" and y < 13 then return accent[1], accent[2], accent[3], 1 end
      if (x + y) % 7 == 0 then return body[1] * 0.78, body[2] * 0.78, body[3] * 0.78, 1 end
      return body[1], body[2], body[3], 1
    end)
  end
  local newDinos = {
    parasaur = {{0.45, 0.67, 0.34}, {0.75, 0.82, 0.38}, "parasaur"},
    trike = {{0.43, 0.57, 0.31}, {0.82, 0.68, 0.36}, "trike"},
    stego = {{0.34, 0.57, 0.43}, {0.84, 0.48, 0.27}, "stego"},
    bronto = {{0.62, 0.55, 0.34}, {0.82, 0.72, 0.48}, "bronto"},
    carno = {{0.68, 0.31, 0.22}, {0.92, 0.58, 0.25}, "carno"},
    ptera = {{0.48, 0.43, 0.65}, {0.77, 0.65, 0.86}, "ptera"},
  }
  for kind, data in pairs(newDinos) do
    S[kind] = makeDino(data[1], data[2], data[3])
    S.anim[kind] = {walk = {S[kind], S[kind]}, idle = {S[kind]}}
  end
  layout()
  for _ = 1, 260 do
    patches[#patches + 1] = {x = math.random(0, WORLD), y = math.random(0, WORLD), w = math.random(14, 40), h = math.random(8, 22),
                             l = math.random() < 0.5 and 1 or 0}
  end
  for _ = 1, 700 do tufts[#tufts + 1] = {x = math.random(0, WORLD), y = math.random(0, WORLD)} end
  local fc = {{1, 1, 1}, {1, .9, .3}, {.95, .4, .5}, {.6, .5, 1}}
  for _ = 1, 260 do flowers[#flowers + 1] = {x = math.random(40, WORLD - 40), y = math.random(40, WORLD - 40), c = fc[math.random(1, 4)]} end
  newGame()
end

function love.resize() layout() end

-- ===== действия =====
local function nearestMob(pred, r)
  local best, bd = nil, r
  for _, m in ipairs(mobs) do
    if pred(m) then
      local d = dist(m.x, m.y, player.x, player.y)
      if d < bd then best, bd = m, d end
    end
  end
  return best
end

local function gather(r, list)
  local parts = {}
  for _, it in ipairs(list) do
    inv[it[1]] = inv[it[1]] + it[2]
    parts[#parts + 1] = "+" .. it[2] .. " " .. INAME[it[1]]
  end
  pop(r.x, r.y - 16, table.concat(parts, "  "))
  gainXP(1)
end

local function act(demolish)
  if player.dead then return end
  if player.build then
    if demolish then place() end
    return
  end
  if player.atkcd > 0 then return end
  player.atkcd, player.swing = 0.35, 0.15
  local wp = WP[player.weap]
  local dmg, torp, reach = wp.dmg, wp.torp, (player.weap == "spear") and 8 or 0
  if player.mount then dmg, torp, reach = 15, 0, 8; player.mount.atkAnim = 0.35 end
  local bestD, bestM, bestR = 1e9, nil, nil
  for i, m in ipairs(mobs) do
    if not m.tamed then
      local d = dist(m.x, m.y, player.x, player.y)
      if d < m.r + 12 + reach and d < bestD then bestD, bestM, bestR = d, i, nil end
    end
  end
  for _, r in ipairs(res) do
    if r.alive then
      local d = dist(r.x, r.y, player.x, player.y)
      if d < 18 + reach and d < bestD then bestD, bestM, bestR = d, nil, r end
    end
  end
  if bestM then
    local m = mobs[bestM]
    m.hp = m.hp - dmg
    if torp > 0 then
      m.torp = math.min(m.maxtorp, m.torp + torp)
      if m.torp >= m.maxtorp and not m.ko then
        m.ko, m.tame = true, 0
        pop(m.x, m.y - 24, "Оглушён!")
      end
    end
    if not m.ko then
      m.hit = 3
      local dx, dy = m.x - player.x, m.y - player.y
      local l = math.max(1, math.sqrt(dx * dx + dy * dy))
      m.x, m.y = m.x + dx / l * 4, m.y + dy / l * 4
    end
    if m.hp <= 0 then
      inv.meat = inv.meat + m.meat
      inv.hide = inv.hide + m.hide
      pop(m.x, m.y - 20, "+" .. m.meat .. " мяса  +" .. m.hide .. " шкуры")
      gainXP(m.xp)
      table.remove(mobs, bestM)
    end
  elseif bestR then
    local r = bestR
    r.hp = r.hp - 1
    if r.kind == "tree" then
      if player.tools.hatchet then gather(r, {{"wood", 2}, {"thatch", 1}}) else gather(r, {{"thatch", 2}}) end
    elseif r.kind == "rock" then
      if player.tools.pick then gather(r, {{"stone", 2}, {"flint", 1}})
      elseif math.random() < 0.3 then gather(r, {{"stone", 1}, {"flint", 1}})
      else gather(r, {{"stone", 1}}) end
    else
      gather(r, {{"berry", 1}, {"fiber", 1}})
    end
    if r.hp <= 0 then r.alive = false; r.regrow = r.kind == "bush" and 40 or 90 end
  elseif demolish then
    local cx, cy = targetCell()
    local b = grid[key(cx, cy)] or floors[key(cx, cy)]
    if b then
      for k, v in pairs(BD[b.kind].cost) do inv[k] = inv[k] + math.floor(v / 2) end
      if b.kind == "bed" then spawnPt = {x = SP.x, y = SP.y} end
      removeBuilding(b)
      say("Снесено (вернули половину ресурсов)")
    end
  end
end

local function swapWeapon()
  if player.dead then return end
  local order = {"fists", "club", "spear"}
  local idx = 1
  for i, w in ipairs(order) do if w == player.weap then idx = i end end
  for step = 1, 3 do
    local n = order[(idx + step - 1) % 3 + 1]
    if n == "fists" or player.tools[n] then player.weap = n; say("Оружие: " .. WNAME[n]); return end
  end
end

local function eat(k)
  if player.food >= 100 then say("Вы не голодны"); return false end
  inv[k] = inv[k] - 1
  player.food = math.min(100, player.food + FOOD[k])
  pop(player.x, player.y - 22, "+еда")
  return true
end

local function finishTame(m)
  m.tamed, m.ko, m.torp, m.tame, m.hit = true, false, 0, 100, 0
  gainXP(m.xpt)
  say("Вы приручили: " .. m.name .. "!")
end

local function dismount()
  local m = player.mount
  m.mounted = false
  player.mount = nil
  player.x, player.y = clamp(m.x + 14, 4, WORLD - 4), m.y
  say("Вы слезли")
end

local function use()
  if player.dead then return end
  if player.mount then dismount(); return end
  local ko = nearestMob(function(m) return m.ko and not m.tamed end, 26)
  if ko then
    local fk
    if ko.diet == "herb" then
      if creative or inv.berry > 0 then fk = "berry" end
    else
      fk = (creative or inv.cooked > 0) and "cooked" or (inv.meat > 0 and "meat" or nil)
    end
    if not fk then say(ko.diet == "herb" and "Для приручения нужны ягоды" or "Для приручения нужно мясо"); return end
    if not creative then inv[fk] = inv[fk] - 1 end
    ko.tame = ko.tame + (100 / ko.need) * (fk == "cooked" and 1.5 or 1)
    if ko.tame >= 100 then finishTame(ko)
    else pop(ko.x, ko.y - 26, "Приручение " .. math.floor(ko.tame) .. "%") end
    return
  end
  local pet = nearestMob(function(m) return m.tamed end, 26)
  if pet then
    if pet.saddled then
      pet.mounted = true
      player.mount = pet
      player.x, player.y = pet.x, pet.y
      say("Вы верхом: " .. pet.name)
      return
    elseif creative or inv.saddle > 0 then
      if not creative then inv.saddle = inv.saddle - 1 end
      pet.saddled = true
      say("Седло надето: " .. pet.name)
      return
    end
  end
  if near("fire", 44) and inv.meat > 0 then
    inv.meat = inv.meat - 1; inv.cooked = inv.cooked + 1
    pop(player.x, player.y - 22, "Пожарено!"); gainXP(1)
    return
  end
  if inLake(player.x, player.y, 8) and player.water < 100 then
    player.water = math.min(100, player.water + 40); pop(player.x, player.y - 22, "Пьёте воду")
    return
  end
  if inv.cooked > 0 then eat("cooked")
  elseif inv.berry > 0 then eat("berry")
  elseif inv.meat > 0 then eat("meat")
  else say("Нечего есть") end
end

local function useLabel()
  if player.mount then return "СЛЕЗТЬ" end
  if nearestMob(function(m) return m.ko and not m.tamed end, 26) then return "КОРМИТЬ" end
  local pet = nearestMob(function(m) return m.tamed end, 26)
  if pet then
    if pet.saddled then return "ЕХАТЬ" end
    if creative or inv.saddle > 0 then return "СЕДЛО" end
  end
  return "ДЕЙСТВИЕ"
end

-- ===== сумка / крафт / инграммы =====
local function isUnlocked(e) return creative or prog.eng[e.id] end

local function engOK(e)
  if e.flag and player.tools[e.flag] then return false end
  return has(e.cost)
end

local function tryCraft(e)
  if e.flag and player.tools[e.flag] then say("Уже создано"); return end
  if not has(e.cost) then say("Нужно: " .. costStr(e.cost)); return end
  if e.build then
    player.build = e.build
    craftOpen = false
    say("Встаньте лицом к месту и нажмите ПОСТАВИТЬ")
    return
  end
  spend(e.cost)
  if e.flag then
    player.tools[e.flag] = true
    if e.flag == "club" or e.flag == "spear" then player.weap = e.flag end
  else
    inv[e.item] = inv[e.item] + 1
  end
  say("Создано: " .. e.name)
  gainXP(3)
end

local function unlock(e)
  if isUnlocked(e) then say("Уже изучено") return end
  if prog.lvl < e.lvl then say("Нужен уровень " .. e.lvl) return end
  if prog.pts < e.pts then say("Нужно очков инграмм: " .. e.pts) return end
  prog.pts = prog.pts - e.pts
  prog.eng[e.id] = true
  say("Изучено: " .. e.name)
end

local function engIcon(e)
  if e.icon then return S[e.icon] end
  return S[BD[e.build].spr]
end

local function costLines(cost)
  local lines = {}
  for _, k in ipairs(ITEMS) do
    if cost[k] then
      local ok = creative or inv[k] >= cost[k]
      lines[#lines + 1] = {INAME[k] .. ": " .. inv[k] .. " / " .. cost[k], ok and 0.5 or 1, ok and 1 or 0.4, ok and 0.5 or 0.4}
    end
  end
  return lines
end

local function getEntries()
  local list = {}
  if tab == 1 then
    for _, k in ipairs(ITEMS) do
      if inv[k] > 0 then
        local btns = {}
        if FOOD[k] then btns[#btns + 1] = {label = "СЪЕСТЬ", ok = true, fn = function() eat(k) end} end
        btns[#btns + 1] = {label = "ВЫБРОСИТЬ 1", ok = true, fn = function() inv[k] = inv[k] - 1 end}
        btns[#btns + 1] = {label = "ВЫБРОСИТЬ ВСЕ", ok = true, fn = function() inv[k] = 0 end}
        list[#list + 1] = {icon = S["ic_" .. (k == "meat" and "meat" or k)], count = inv[k], title = INAME[k],
          lines = {{string.format("Вес: %.1f (всего %.1f)", IWT[k], IWT[k] * inv[k]), .8, .8, .8}, {IDESC[k], 1, 1, 1}},
          buttons = btns}
      end
    end
  elseif tab == 2 then
    for _, e in ipairs(ENGRAMS) do
      if isUnlocked(e) then
        local lines = {{e.desc, 1, 1, 1}}
        for _, l in ipairs(costLines(e.cost)) do lines[#lines + 1] = l end
        local owned = e.flag and player.tools[e.flag]
        if owned then lines[#lines + 1] = {"Уже создано", .6, .9, .6} end
        list[#list + 1] = {icon = engIcon(e), title = e.name, lines = lines,
          buttons = {{label = e.build and "ПОСТРОИТЬ" or "СОЗДАТЬ", ok = engOK(e), fn = function() tryCraft(e) end}}}
      end
    end
  elseif tab == 3 then
    for _, e in ipairs(ENGRAMS) do
      local un = isUnlocked(e)
      local lvOk, ptOk = prog.lvl >= e.lvl, prog.pts >= e.pts
      local lines = {{e.desc, 1, 1, 1},
        {"Нужен уровень: " .. e.lvl, lvOk and .5 or 1, lvOk and 1 or .4, lvOk and .5 or .4},
        {"Стоимость: " .. e.pts .. " оч. (у вас " .. prog.pts .. ")", ptOk and .5 or 1, ptOk and 1 or .4, ptOk and .5 or .4}}
      if un then lines[#lines + 1] = {"Изучено", .6, .9, .6} end
      list[#list + 1] = {icon = engIcon(e), title = e.name, lines = lines, dim = not un and not (lvOk and ptOk), done = un,
        buttons = {{label = un and "ИЗУЧЕНО" or "ИЗУЧИТЬ", ok = (not un) and lvOk and ptOk, fn = function() unlock(e) end}}}
    end
  elseif tab == 4 then
    for _, kind in ipairs({"dodo", "parasaur", "trike", "stego", "bronto", "raptor", "carno", "ptera", "rex"}) do
      local def = MOBDEF[kind]
      list[#list + 1] = {icon = S[def.spr], title = def.name,
        lines = {{"Появится рядом с вами.", 1, 1, 1}, {"Приручённый не нападает и идёт за вами.", .8, .8, .8}},
        buttons = {
          {label = "ДИКИЙ", ok = true, fn = function() spawnMob(kind, false, false) end},
          {label = "ПРИРУЧЁННЫЙ", ok = true, fn = function() spawnMob(kind, true, false) end},
          {label = "ПРИРУЧЁННЫЙ С СЕДЛОМ", ok = true, fn = function() spawnMob(kind, true, true) end}}}
    end
  end
  return list
end

local function btnRects(n, detail)
  local bh, g = H * 0.085, H * 0.012
  local r = {}
  for j = 1, n do
    r[j] = {x = detail.x, y = detail.y + detail.h - (n - j + 1) * (bh + g) + g, w = detail.w, h = bh}
  end
  return r
end

local function openBag()
  craftOpen = true
  stick, held = nil, {}
end

-- ===== ввод =====
local function inRect(x, y, r) return x > r.x and x < r.x + r.w and y > r.y and y < r.y + r.h end

local function press(id, x, y)
  if state == "menu" then
    for _, b in ipairs(menuBtns) do
      if inRect(x, y, b) then
        if b.id == "play" then state, started = "game", true
        elseif b.id == "new" then newGame(); state, started = "game", true
        elseif b.id == "creative" then
          creative = not creative
          if not creative and tab > 3 then tab = 1 end
        else love.event.quit() end
      end
    end
    return
  end
  if craftOpen then
    local entries = getEntries()
    local _, _, _, _, tabs, close, slots, detail = panelGeom()
    if inRect(x, y, close) then craftOpen = false return end
    for i, t in ipairs(tabs) do if inRect(x, y, t) then tab = i return end end
    for i = 1, #entries do
      if inRect(x, y, slots[i]) then selIdx[tab] = i return end
    end
    local e = entries[clamp(selIdx[tab], 1, math.max(1, #entries))]
    if e then
      local rects = btnRects(#e.buttons, detail)
      for j, r in ipairs(rects) do
        if inRect(x, y, r) then
          if e.buttons[j].ok then e.buttons[j].fn() else say("Сейчас недоступно") end
          return
        end
      end
    end
    return
  end
  if dist(x, y, pauseBtn.x, pauseBtn.y) <= pauseBtn.r then
    state, stick, held = "menu", nil, {}
    return
  end
  for k, b in pairs(btn) do
    local shown = (k ~= "D" and k ~= "F") or (k == "D" and player.build) or (k == "F" and not player.build and not player.mount)
    if shown and dist(x, y, b.x, b.y) <= b.r then
      held[id] = k
      if k == "A" then act(true)
      elseif k == "B" then use()
      elseif k == "C" then openBag()
      elseif k == "F" then swapWeapon()
      else player.build = nil; say("Отменено") end
      return
    end
  end
  if x < W * 0.5 and not stick then
    stick = {id = id, ox = x, oy = y, x = x, y = y, r = H * 0.12}
  end
end
local function move(id, x, y) if stick and stick.id == id then stick.x, stick.y = x, y end end
local function release(id)
  if stick and stick.id == id then stick = nil end
  held[id] = nil
end

function love.touchpressed(id, x, y) press(id, x, y) end
function love.touchmoved(id, x, y) move(id, x, y) end
function love.touchreleased(id) release(id) end
function love.mousepressed(x, y, b, istouch) if not istouch then press("m", x, y) end end
function love.mousemoved(x, y, _, _, istouch) if not istouch and love.mouse.isDown(1) then move("m", x, y) end end
function love.mousereleased(_, _, _, istouch) if not istouch then release("m") end end
function love.keypressed(k)
  if state == "menu" then
    if k == "return" or k == "kpenter" or k == "space" then
      state, started = "game", true
    elseif k == "n" then
      newGame()
      state, started = "game", true
    elseif k == "c" then
      creative = not creative
      if not creative and tab > 3 then tab = 1 end
    elseif k == "escape" and not started then
      love.event.quit()
    elseif k == "escape" and started then
      state = "game"
    end
    return
  end
  if k == "escape" then
    if craftOpen then craftOpen = false
    elseif state == "game" then state, stick, held = "menu", nil, {}
    elseif started then state = "game" end
    return
  end
  if state ~= "game" then return end
  if craftOpen then if k == "c" then craftOpen = false end return end
  if k == "space" then act(true)
  elseif k == "e" then use()
  elseif k == "c" then openBag()
  elseif k == "q" then swapWeapon()
  elseif k == "x" then player.build = nil end
end

-- ===== обновление =====
local function isNight()
  local t = (clock % 120) / 120
  return 0.55 * (1 + math.cos(2 * math.pi * t)) / 2 > 0.28
end

local function updateMob(m, dt, night)
  m.hit = math.max(0, m.hit - dt)
  m.atk = math.max(0, m.atk - dt)
  m.atkAnim = math.max(0, m.atkAnim - dt)
  if m.mounted then return end
  if m.ko then
    m.moving = false
    m.torp = m.torp - 1.5 * dt
    if m.torp <= 0 then
      m.ko, m.torp, m.tame = false, 0, 0
      pop(m.x, m.y - 20, "Проснулся!")
    end
    return
  end
  if not m.tamed then m.torp = math.max(0, m.torp - 2 * dt) end
  local d = dist(m.x, m.y, player.x, player.y)
  local vx, vy = 0, 0
  local chasing = false
  if m.tamed then
    if d > 30 then
      local k = m.ride * 0.8
      vx, vy = (player.x - m.x) / d * k, (player.y - m.y) / d * k
    end
  elseif m.diet == "herb" then
    if m.hit > 0 then
      vx, vy = (m.x - player.x) / math.max(d, 1) * m.spd, (m.y - player.y) / math.max(d, 1) * m.spd
    else
      m.wt = m.wt - dt
      if m.wt <= 0 then
        local a = math.random() * 6.28
        local on = math.random() < 0.6
        m.vx, m.vy = on and math.cos(a) * 12 or 0, on and math.sin(a) * 12 or 0
        m.wt = 1 + math.random() * 3
      end
      vx, vy = m.vx, m.vy
    end
  else
    local see = d < (night and 120 or 70)
    if see then
      chasing = true
      vx, vy = (player.x - m.x) / math.max(d, 1) * m.spd, (player.y - m.y) / math.max(d, 1) * m.spd
      if d < m.r + 9 and m.atk <= 0 then
        player.hp = player.hp - m.dmg * (player.tools.armor and 0.6 or 1)
        player.flash = 0.25
        m.atk = 1
        m.atkAnim = 0.4
      end
      if d < m.r + 9 then vx, vy = 0, 0 end
    else
      m.wt = m.wt - dt
      if m.wt <= 0 then
        local a = math.random() * 6.28
        local on = math.random() < 0.5
        m.vx, m.vy = on and math.cos(a) * 10 or 0, on and math.sin(a) * 10 or 0
        m.wt = 1 + math.random() * 3
      end
      vx, vy = m.vx, m.vy
    end
  end
  local hb = tryMove(m, vx * dt, vy * dt, m.r, true)
  local spd2 = math.sqrt(vx * vx + vy * vy)
  m.moving = spd2 > 1
  if m.moving then m.animT = m.animT + dt * spd2 / 6 end
  if hb and chasing and hb.hp then
    hb.hp = hb.hp - (m.dmg / 2) * dt
    if hb.hp <= 0 then pop(hb.cx * CELL, hb.cy * CELL, BD[hb.kind].name .. " сломана!"); removeBuilding(hb) end
  end
  if vx ~= 0 then m.dir = vx > 0 and 1 or -1 end
end

function love.update(dt)
  if state == "menu" then return end
  dt = math.min(dt, 0.05)
  toast.t = math.max(0, toast.t - dt)
  if craftOpen then return end
  if player.dead then
    player.dt = player.dt - dt
    if player.dt <= 0 then respawn() end
    return
  end
  clock = clock + dt
  player.atkcd = math.max(0, player.atkcd - dt)
  player.swing = math.max(0, player.swing - dt)
  player.flash = math.max(0, player.flash - dt)

  local mx, my = 0, 0
  if stick then
    local dx, dy = stick.x - stick.ox, stick.y - stick.oy
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 10 then
      local k = math.min(len, stick.r) / stick.r
      mx, my = dx / len * k, dy / len * k
    end
  end
  local kb = love.keyboard
  if kb.isDown("a", "left") then mx = mx - 1 end
  if kb.isDown("d", "right") then mx = mx + 1 end
  if kb.isDown("w", "up") then my = my - 1 end
  if kb.isDown("s", "down") then my = my + 1 end
  local mag = math.sqrt(mx * mx + my * my)
  if mag > 1 then
    mx, my = mx / mag, my / mag
    mag = 1
  end
  local moving = mx ~= 0 or my ~= 0
  local sprintInput = (stick ~= nil and mag > 0.85) or kb.isDown("lshift", "rshift")
  local running = moving and sprintInput and not player.mount and player.sta > 0 and not kb.isDown("lctrl")
  if player.mount then player.mount.moving = moving end
  if moving then
    local spd = player.mount and player.mount.ride or (running and 58 or 36)
    if weight() > maxWeight() and not creative then spd = spd * 0.35 end
    if player.mount then
      local m = player.mount
      tryMove(m, mx * spd * dt, my * spd * dt, m.r, true)
      player.x, player.y = m.x, m.y
      m.animT = m.animT + dt * spd / 6
      if mx ~= 0 then m.dir = mx > 0 and 1 or -1 end
    else
      tryMove(player, mx * spd * dt, my * spd * dt, 3, false)
    end
    if math.abs(mx) > math.abs(my) then player.fx, player.fy = (mx > 0 and 1 or -1), 0
    else player.fx, player.fy = 0, (my > 0 and 1 or -1) end
    if mx ~= 0 then player.dir = mx > 0 and 1 or -1 end
    player.step = player.step + dt * (running and 12 or 8)
  end
  if running then
    player.sta = math.max(0, player.sta - 14 * dt)
    player.staDelay = 0.8
  else
    player.staDelay = player.staDelay - dt
    if player.staDelay <= 0 then player.sta = math.min(100, player.sta + 18 * dt) end
  end

  for _, k in pairs(held) do if k == "A" then act(false) end end
  if kb.isDown("space") then act(false) end

  player.food = math.max(0, player.food - 0.25 * dt)
  player.water = math.max(0, player.water - 0.35 * dt)
  if player.food <= 0 or player.water <= 0 then player.hp = player.hp - 1 * dt
  elseif player.hp < 100 then player.hp = math.min(100, player.hp + 0.3 * dt) end

  for i = #bl, 1, -1 do
    local b = bl[i]
    if b.kind == "fire" then
      b.t = b.t - dt
      if b.t <= 0 then removeBuilding(b)
      elseif dist(b.cx * CELL + CELL / 2, (b.cy + 1) * CELL - CELL / 2, player.x, player.y) < 36 then
        player.hp = math.min(100, player.hp + 2 * dt)
      end
    end
  end

  for _, r in ipairs(res) do
    if not r.alive then
      r.regrow = r.regrow - dt
      if r.regrow <= 0 then r.alive, r.hp = true, r.maxhp end
    end
  end

  local night = isNight()
  for _, m in ipairs(mobs) do updateMob(m, dt, night) end

  for i = #pops, 1, -1 do
    local p = pops[i]
    p.t = p.t - dt
    p.y = p.y - 8 * dt
    if p.t <= 0 then table.remove(pops, i) end
  end

  if creative then player.hp, player.food, player.water, player.sta = 100, 100, 100, 100 end
  if player.hp <= 0 then
    if player.mount then dismount() end
    player.dead, player.dt = true, 3
  end
end

-- ===== отрисовка =====
local function ds(s, x, y, sc, flip, tint)
  sc = sc or 1
  lg.setColor(0, 0, 0, 0.25)
  lg.ellipse("fill", x, y, s.w * 0.4 * sc, 2 * sc)
  if tint then lg.setColor(tint) else lg.setColor(1, 1, 1) end
  lg.draw(s.img, math.floor(x), math.floor(y), 0, sc * (flip or 1), sc, s.w / 2, s.h)
end

local function drawB(b, tint)
  local s = S[BD[b.kind].spr]
  if b.kind == "fire" then
    ds(s, b.cx * CELL + CELL / 2, (b.cy + 1) * CELL - 1, 1, math.floor(clock * 6) % 2 == 0 and 1 or -1, tint)
  else
    if tint then lg.setColor(tint) else lg.setColor(1, 1, 1) end
    lg.draw(s.img, b.cx * CELL, (b.cy + 1) * CELL, 0, 1, 1, 0, s.h)
  end
end

local function mobFrame(m)
  local a = S.anim[m.kind]
  if m.atkAnim > 0 and a.attack then return a.attack[1] end
  if m.moving then return a.walk[math.floor(m.animT) % #a.walk + 1] end
  if a.peck then
    local t = (clock + m.x * 0.13) % 5
    if t < 0.7 then return a.peck[(math.floor(t * 4) % #a.peck) + 1] end
  end
  return a.idle[(math.floor(clock * 1.2 + m.x * 0.1) % #a.idle) + 1]
end

local function drawMob(m)
  if m.ko then
    lg.setColor(0, 0, 0, 0.25)
    lg.ellipse("fill", m.x, m.y, m.spr.w * 0.4 * m.sc, 2 * m.sc)
    lg.setColor(0.65, 0.65, 0.9)
    lg.draw(m.spr.img, math.floor(m.x), math.floor(m.y), 0, m.sc * m.dir, -m.sc, m.spr.w / 2, 0)
  else
    local fr = mobFrame(m)
    local bob = 0
    ds(fr, m.x, m.y - bob, m.sc, m.dir, m.hit > 0 and {1, 0.6, 0.6} or nil)
  end
  if m.saddled and not m.ko then
    local sx, sy = m.x + m.dir * m.sad.x, m.y - m.sad.y
    lg.setColor(1, 1, 1)
    if m.mounted then
      -- наездник сидит: рисуем только верхнюю часть тела, а седло поверх бёдер
      lg.draw(S.playerB.img, S.riderQuad, math.floor(sx), math.floor(sy), 0, player.dir, 1, 5, 11)
      lg.draw(S.saddle.img, math.floor(sx), math.floor(sy), 0, 1, 1, 6, 3)
    else
      lg.draw(S.saddle.img, math.floor(sx), math.floor(sy), 0, 1, 1, 6, 5)
    end
  end
end

local function statRow(i, icon, val, maxv, r, g, b, txt, pad)
  local rh, rw = H * 0.06, H * 0.46
  local sc = math.max(2, math.floor(H * 0.05 / 8))
  local y = H * 0.2 + (i - 1) * H * 0.07
  lg.setColor(0, 0, 0, 0.4)
  lg.rectangle("fill", pad, y, rw, rh, 6)
  lg.setColor(1, 1, 1)
  lg.draw(icon.img, pad + 6, y + (rh - icon.h * sc) / 2, 0, sc, sc)
  local bx = pad + icon.w * sc + 16
  local bw = rw - (bx - pad) - 8
  local by, bh = y + rh * 0.25, rh * 0.5
  lg.setColor(0, 0, 0, 0.6); lg.rectangle("fill", bx, by, bw, bh, 4)
  lg.setColor(r, g, b); lg.rectangle("fill", bx, by, bw * clamp(val / maxv, 0, 1), bh, 4)
  lg.setColor(1, 1, 1)
  lg.setFont(tinyFont)
  lg.printf(txt, bx, by + (bh - tinyFont:getHeight()) / 2, bw, "center")
end

local function drawPanel()
  local entries = getEntries()
  local px, py, pw, ph, tabs, close, slots, detail, gap = panelGeom()
  local sel = clamp(selIdx[tab], 1, math.max(1, #entries))
  selIdx[tab] = sel
  lg.setColor(0.04, 0.06, 0.05, 0.94)
  lg.rectangle("fill", px, py, pw, ph, 14)
  local names = {"СУМКА", "КРАФТ", "ИНГРАММЫ", "СПАВН"}
  lg.setFont(font)
  for i, t in ipairs(tabs) do
    if i == tab then lg.setColor(0.25, 0.55, 0.25) else lg.setColor(0.2, 0.2, 0.2) end
    lg.rectangle("fill", t.x, t.y, t.w, t.h, 10)
    lg.setColor(1, 1, 1)
    lg.printf(names[i], t.x, t.y + t.h / 2 - font:getHeight() / 2, t.w, "center")
  end
  lg.setColor(0.7, 0.2, 0.2)
  lg.rectangle("fill", close.x, close.y, close.w, close.h, 10)
  lg.setColor(1, 1, 1)
  lg.printf("ЗАКРЫТЬ", close.x, close.y + close.h / 2 - font:getHeight() / 2, close.w, "center")
  lg.setFont(tinyFont)
  lg.setColor(1, 0.9, 0.5)
  lg.print(string.format("Ур. %d   Опыт %d/%d   Очки инграмм: %d   Вес %.1f/%d",
    prog.lvl, prog.xp, xpNeed(prog.lvl), prog.pts, weight(), maxWeight()), px + gap, py + H * 0.12)

  for i, s in ipairs(slots) do
    local e = entries[i]
    lg.setColor(0.13, 0.15, 0.14)
    lg.rectangle("fill", s.x, s.y, s.w, s.h, 6)
    if e then
      local ic = e.icon
      local sc = math.max(1, math.floor(s.w * 0.58 / math.max(ic.w, ic.h)))
      lg.setColor(1, 1, 1, e.dim and 0.35 or 1)
      lg.draw(ic.img, math.floor(s.x + (s.w - ic.w * sc) / 2), math.floor(s.y + (s.h - ic.h * sc) / 2), 0, sc, sc)
      if e.count then
        lg.setColor(1, 1, 1)
        lg.printf("x" .. e.count, s.x, s.y + s.h - tinyFont:getHeight() - 2, s.w - 6, "right")
      end
      if e.done then lg.setColor(0.4, 1, 0.4); lg.rectangle("fill", s.x + 5, s.y + 5, 10, 10, 3) end
    end
    if i == sel and e then lg.setColor(1, 0.85, 0.2) else lg.setColor(0.3, 0.33, 0.31) end
    lg.setLineWidth(3)
    lg.rectangle("line", s.x, s.y, s.w, s.h, 6)
  end
  lg.setLineWidth(1)

  lg.setColor(0.1, 0.12, 0.11)
  lg.rectangle("fill", detail.x, detail.y, detail.w, detail.h, 8)
  local e = entries[sel]
  if not e then
    lg.setFont(tinyFont)
    lg.setColor(0.7, 0.7, 0.7)
    lg.printf(tab == 1 and "Сумка пуста. Собирайте ресурсы!" or "Здесь пока ничего нет. Изучите инграммы.",
      detail.x + 10, detail.y + 10, detail.w - 20, "left")
    return
  end
  lg.setFont(font)
  lg.setColor(1, 0.9, 0.4)
  lg.printf(e.title, detail.x + 10, detail.y + 8, detail.w - 20, "left")
  local ty = detail.y + 8 + font:getHeight() * 1.4
  lg.setFont(tinyFont)
  for _, ln in ipairs(e.lines) do
    lg.setColor(ln[2], ln[3], ln[4])
    lg.printf(ln[1], detail.x + 10, ty, detail.w - 20, "left")
    local _, wl = tinyFont:getWrap(ln[1], detail.w - 20)
    ty = ty + #wl * tinyFont:getHeight() + 6
  end
  local rects = btnRects(#e.buttons, detail)
  lg.setFont(tinyFont)
  for j, r in ipairs(rects) do
    local bt = e.buttons[j]
    if bt.ok then lg.setColor(0.2, 0.5, 0.2) else lg.setColor(0.25, 0.25, 0.25) end
    lg.rectangle("fill", r.x, r.y, r.w, r.h, 8)
    lg.setColor(1, 1, 1, bt.ok and 1 or 0.5)
    lg.printf(bt.label, r.x, r.y + r.h / 2 - tinyFont:getHeight() / 2, r.w, "center")
  end
end

function love.draw()
  lg.clear(0.10, 0.35, 0.60)
  local cx, cy = math.floor(player.x), math.floor(player.y - 4)
  local ox, oy = math.floor(W / (2 * Z)) - cx, math.floor(H / (2 * Z)) - cy
  lg.push()
  lg.scale(Z)
  lg.translate(ox, oy)

  -- океан, пляж, трава
  lg.setColor(0.18, 0.5, 0.75)
  for i = 0, 20 do
    local wx = (i * 137 + math.floor(clock * 6)) % (WORLD + 200) - 100
    lg.rectangle("fill", wx, -20 - (i % 3) * 6, 14, 1)
    lg.rectangle("fill", wx, WORLD + 12 + (i % 3) * 6, 14, 1)
    lg.rectangle("fill", -20 - (i % 3) * 6, wx, 1, 14)
    lg.rectangle("fill", WORLD + 12 + (i % 3) * 6, wx, 1, 14)
  end
  lg.setColor(0.93, 0.85, 0.58)
  lg.rectangle("fill", 0, 0, WORLD, WORLD, 20)
  lg.setColor(0.28, 0.62, 0.28)
  lg.rectangle("fill", 32, 32, WORLD - 64, WORLD - 64, 24)

  -- Отдельные природные зоны большого острова.
  lg.setColor(0.72, 0.63, 0.39)
  lg.rectangle("fill", 1320, 32, 848, 850, 28) -- сухое плато
  lg.setColor(0.30, 0.38, 0.27)
  lg.rectangle("fill", 1320, 1010, 848, 1158, 28) -- болотистые низины
  lg.setColor(0.48, 0.49, 0.43)
  lg.rectangle("fill", 32, 32, 570, 560, 28) -- каменистое нагорье
  lg.setColor(0.38, 0.54, 0.30)
  lg.rectangle("fill", 70, 70, 485, 465, 24)

  local vw, vh = W / Z / 2 + 30, H / Z / 2 + 30
  local function vis(x, y) return math.abs(x - player.x) < vw and math.abs(y - player.y) < vh end

  for _, p in ipairs(patches) do
    if vis(p.x, p.y) and p.x > 40 and p.y > 40 and p.x < WORLD - 60 and p.y < WORLD - 50 then
      if p.x > 1320 and p.y < 900 then
        if p.l == 1 then lg.setColor(0.78, 0.69, 0.45) else lg.setColor(0.66, 0.56, 0.34) end
      elseif p.x > 1320 and p.y > 1010 then
        if p.l == 1 then lg.setColor(0.36, 0.45, 0.30) else lg.setColor(0.25, 0.34, 0.23) end
      elseif p.x < 610 and p.y < 600 then
        if p.l == 1 then lg.setColor(0.48, 0.55, 0.39) else lg.setColor(0.40, 0.47, 0.34) end
      elseif p.l == 1 then lg.setColor(0.33, 0.68, 0.30) else lg.setColor(0.22, 0.54, 0.24) end
      lg.rectangle("fill", p.x, p.y, p.w, p.h, 4)
    end
  end
  lg.setColor(0.17, 0.43, 0.2)
  for _, t in ipairs(tufts) do
    if vis(t.x, t.y) and t.x > 40 and t.y > 40 and t.x < WORLD - 40 and t.y < WORLD - 40 then
      lg.rectangle("fill", t.x, t.y, 1, 2); lg.rectangle("fill", t.x + 2, t.y + 1, 1, 1)
    end
  end
  for _, f in ipairs(flowers) do
    if vis(f.x, f.y) then lg.setColor(f.c); lg.rectangle("fill", f.x, f.y, 1, 1) end
  end

  -- озеро
  lg.setColor(0.93, 0.85, 0.58)
  lg.rectangle("fill", LAKE.x - 5, LAKE.y - 5, LAKE.w + 10, LAKE.h + 10, 14)
  lg.setColor(0.15, 0.40, 0.75)
  lg.rectangle("fill", LAKE.x, LAKE.y, LAKE.w, LAKE.h, 12)
  lg.setColor(0.22, 0.50, 0.85)
  lg.rectangle("fill", LAKE.x + 6, LAKE.y + 6, LAKE.w - 12, LAKE.h - 12, 10)
  lg.setColor(0.55, 0.78, 1)
  for i = 0, 8 do
    local wx = LAKE.x + 20 + (i * 53) % (LAKE.w - 40)
    local wy = LAKE.y + 15 + (i * 37) % (LAKE.h - 30)
    lg.rectangle("fill", wx + math.floor(math.sin(clock * 2 + i) * 2), wy, 6, 1)
  end

  for _, b in ipairs(bl) do
    if BD[b.kind].floor and vis(b.cx * CELL, b.cy * CELL) then drawB(b) end
  end

  local items = {}
  for _, r in ipairs(res) do
    if r.alive and vis(r.x, r.y) then
      items[#items + 1] = {y = r.y, f = function() ds(r.spr, r.x, r.y, 1) end}
    end
  end
  for _, b in ipairs(bl) do
    if not BD[b.kind].floor and vis(b.cx * CELL, b.cy * CELL) then
      items[#items + 1] = {y = (b.cy + 1) * CELL, f = function() drawB(b) end}
    end
  end
  for _, m in ipairs(mobs) do
    if vis(m.x, m.y) then items[#items + 1] = {y = m.y, f = function() drawMob(m) end} end
  end
  if not player.mount then
    items[#items + 1] = {y = player.y, f = function()
      local spr = (math.floor(player.step) % 2 == 0) and S.playerA or S.playerB
      local bob = (math.floor(player.step) % 2 == 0) and 0 or 1
      local tint = player.flash > 0 and {1, 0.4, 0.4} or (player.tools.armor and {0.85, 0.7, 0.55} or nil)
      ds(spr, player.x, player.y - bob, 1, player.dir, tint)
      if player.swing > 0 then
        lg.setColor(1, 1, 1, 0.8)
        lg.rectangle("fill", player.x + player.fx * 7, player.y - 8 + player.fy * 7,
          player.fx ~= 0 and 6 * player.fx or 1, player.fy ~= 0 and 6 * player.fy or 1)
      end
    end}
  end
  table.sort(items, function(a, b) return a.y < b.y end)
  for _, it in ipairs(items) do it.f() end

  if player.build and not player.dead then
    local gx, gy = targetCell()
    local okp = canPlace(player.build, gx, gy)
    drawB({kind = player.build, cx = gx, cy = gy}, okp and {0.5, 1, 0.5, 0.65} or {1, 0.4, 0.4, 0.65})
  end
  lg.pop()

  -- ночь и свет костров
  local t = (clock % 120) / 120
  local dark = 0.55 * (1 + math.cos(2 * math.pi * t)) / 2
  lg.setColor(0.02, 0.03, 0.18, dark)
  lg.rectangle("fill", 0, 0, W, H)
  lg.setBlendMode("add")
  for _, b in ipairs(bl) do
    if b.kind == "fire" then
      local sx = (b.cx * CELL + CELL / 2 + ox) * Z
      local sy = ((b.cy + 1) * CELL - CELL / 2 + oy) * Z
      for i = 1, 4 do
        lg.setColor(1, 0.6, 0.2, 0.04 + dark * 0.1)
        lg.circle("fill", sx, sy, Z * 11 * i)
      end
    end
  end
  lg.setBlendMode("alpha")

  -- подписи над мобами и всплывающий текст (в экранных координатах)
  lg.setFont(tinyFont)
  for _, m in ipairs(mobs) do
    if dist(m.x, m.y, player.x, player.y) < 80 and not m.mounted then
      local sx = (m.x + ox) * Z
      local sy = (m.y - m.spr.h * m.sc - 4 + oy) * Z
      local label = (m.tamed and "Ваш " or "") .. m.name .. "  Ур. " .. m.lvl
      local tw = tinyFont:getWidth(label)
      lg.setColor(0, 0, 0, 0.55)
      lg.rectangle("fill", sx - tw / 2 - 6, sy - tinyFont:getHeight() - 22, tw + 12, tinyFont:getHeight() + 4, 4)
      lg.setColor(m.tamed and 0.5 or 1, 1, m.tamed and 0.5 or 1)
      lg.print(label, sx - tw / 2, sy - tinyFont:getHeight() - 20)
      local bw = math.max(40, m.spr.w * m.sc * Z * 0.8)
      local by = sy - 14
      lg.setColor(0, 0, 0, 0.6); lg.rectangle("fill", sx - bw / 2, by, bw, 6)
      lg.setColor(0.9, 0.2, 0.2); lg.rectangle("fill", sx - bw / 2, by, bw * clamp(m.hp / m.maxhp, 0, 1), 6)
      if not m.tamed and m.torp > 0 then
        lg.setColor(0, 0, 0, 0.6); lg.rectangle("fill", sx - bw / 2, by + 8, bw, 6)
        lg.setColor(0.7, 0.3, 0.9); lg.rectangle("fill", sx - bw / 2, by + 8, bw * clamp(m.torp / m.maxtorp, 0, 1), 6)
      end
      if m.ko then
        lg.setColor(0, 0, 0, 0.6); lg.rectangle("fill", sx - bw / 2, by + 16, bw, 6)
        lg.setColor(0.3, 0.9, 0.9); lg.rectangle("fill", sx - bw / 2, by + 16, bw * clamp(m.tame / 100, 0, 1), 6)
      end
    end
  end
  for _, p in ipairs(pops) do
    local sx, sy = (p.x + ox) * Z, (p.y + oy) * Z
    local tw = tinyFont:getWidth(p.txt)
    lg.setColor(0, 0, 0); lg.print(p.txt, math.floor(sx - tw / 2 + 2), math.floor(sy + 2))
    lg.setColor(1, 1, 0.5); lg.print(p.txt, math.floor(sx - tw / 2), math.floor(sy))
  end

  -- интерфейс
  local pad = H * 0.03
  lg.setFont(font)
  lg.setColor(0, 0, 0, 0.5); lg.rectangle("fill", 0, 0, W, H * 0.012)
  lg.setColor(0.65, 0.45, 0.95); lg.rectangle("fill", 0, 0, W * prog.xp / xpNeed(prog.lvl), H * 0.012)
  lg.setColor(1, 1, 1)
  lg.print("Ур. " .. prog.lvl, pad, H * 0.03)
  lg.print("Очки инграмм: " .. prog.pts, pad, H * 0.03 + font:getHeight() + 2)
  if creative then
    lg.setColor(0.5, 1, 0.5)
    lg.print("РЕЖИМ ТВОРЧЕСТВА", pad, H * 0.03 + (font:getHeight() + 2) * 2)
    lg.setColor(1, 1, 1)
  end
  lg.printf(isNight() and "НОЧЬ" or "ДЕНЬ", 0, H * 0.03, W - pad, "right")
  if player.tools.armor or player.tools.hatchet or player.tools.pick then
    local tl = {}
    if player.tools.hatchet then tl[#tl + 1] = "топор" end
    if player.tools.pick then tl[#tl + 1] = "кирка" end
    if player.tools.armor then tl[#tl + 1] = "броня" end
    lg.setFont(tinyFont)
    lg.printf(table.concat(tl, " · "), 0, H * 0.03 + font:getHeight() + 2, W - pad, "right")
    lg.setFont(font)
  end
  local w, mw = weight(), maxWeight()
  statRow(1, S.hud_heart, player.hp, 100, 0.85, 0.15, 0.2, math.floor(player.hp) .. "", pad)
  statRow(2, S.hud_bolt, player.sta, 100, 0.95, 0.8, 0.2, math.floor(player.sta) .. "", pad)
  statRow(3, S.ic_meat, player.food, 100, 0.9, 0.55, 0.15, math.floor(player.food) .. "", pad)
  statRow(4, S.hud_drop, player.water, 100, 0.25, 0.55, 1, math.floor(player.water) .. "", pad)
  statRow(5, S.hud_weight, w, mw, w > mw and 0.95 or 0.6, w > mw and 0.2 or 0.6, w > mw and 0.2 or 0.65,
    string.format("%.0f/%d", w, mw), pad)

  -- кнопки
  lg.setFont(font)
  if stick then
    local dx, dy = stick.x - stick.ox, stick.y - stick.oy
    local l = math.sqrt(dx * dx + dy * dy)
    if l > stick.r then dx, dy = dx / l * stick.r, dy / l * stick.r end
    lg.setColor(1, 1, 1, 0.25); lg.circle("fill", stick.ox, stick.oy, stick.r)
    lg.setColor(1, 1, 1, 0.5); lg.circle("fill", stick.ox + dx, stick.oy + dy, stick.r * 0.45)
  else
    lg.setColor(1, 1, 1, 0.12); lg.circle("fill", W * 0.15, H * 0.72, H * 0.12)
  end
  for k, b in pairs(btn) do
    local shown = (k ~= "D" and k ~= "F") or (k == "D" and player.build) or (k == "F" and not player.build and not player.mount)
    if shown then
      lg.setColor(0.05, 0.05, 0.05, 0.45); lg.circle("fill", b.x, b.y, b.r)
      lg.setColor(1, 1, 1, 0.6); lg.setLineWidth(3); lg.circle("line", b.x, b.y, b.r); lg.setLineWidth(1)
      lg.setColor(1, 1, 1, 0.95)
      local label
      if k == "A" then label = player.build and "ПОСТАВИТЬ" or (player.mount and "УКУС" or "УДАР")
      elseif k == "B" then label = useLabel()
      elseif k == "C" then label = "СУМКА"
      elseif k == "D" then label = "ОТМЕНА"
      else label = WNAME[player.weap] end
      local _, nch = label:gsub("[^\128-\191]", "")
      lg.setFont(nch > 5 and tinyFont or font)
      lg.printf(label, b.x - b.r, b.y - lg.getFont():getHeight() / 2, b.r * 2, "center")
    end
  end
  lg.setFont(font)

  if player.dead then
    lg.setColor(0, 0, 0, 0.7); lg.rectangle("fill", 0, 0, W, H)
    lg.setColor(1, 0.3, 0.3)
    lg.printf("ВЫ ПОГИБЛИ", 0, H / 2 - font:getHeight(), W, "center")
  end

  if craftOpen then drawPanel() end

  local msg
  if toast.t > 0 then msg = toast.txt
  elseif player.build then msg = BD[player.build].name .. " (" .. costStr(BD[player.build].cost) .. ")" end
  if msg then
    lg.setFont(font)
    local tw = font:getWidth(msg) + 28
    lg.setColor(0, 0, 0, 0.65)
    lg.rectangle("fill", (W - tw) / 2, H - pad - font:getHeight() - 8, tw, font:getHeight() + 12, 8)
    lg.setColor(1, 1, 1)
    lg.printf(msg, 0, H - pad - font:getHeight() - 2, W, "center")
  end

  if state == "game" then
    if not craftOpen then
      lg.setColor(0.05, 0.05, 0.05, 0.45)
      lg.circle("fill", pauseBtn.x, pauseBtn.y, pauseBtn.r)
      lg.setColor(1, 1, 1, 0.9)
      local r = pauseBtn.r
      lg.rectangle("fill", pauseBtn.x - r * 0.35, pauseBtn.y - r * 0.45, r * 0.25, r * 0.9)
      lg.rectangle("fill", pauseBtn.x + r * 0.1, pauseBtn.y - r * 0.45, r * 0.25, r * 0.9)
    end
  else
    lg.setColor(0.02, 0.05, 0.02, 0.88)
    lg.rectangle("fill", 0, 0, W, H)
    lg.setFont(titleFont)
    lg.setColor(0.45, 0.95, 0.45)
    lg.printf("ПИКСЕЛЬНЫЙ ОСТРОВ", 0, H * 0.12, W, "center")
    lg.setFont(font)
    local labels = {play = started and "ПРОДОЛЖИТЬ" or "ИГРАТЬ", new = "НОВАЯ ИГРА", exit = "ВЫХОД",
                    creative = "РЕЖИМ ТВОРЧЕСТВА: " .. (creative and "ВКЛ" or "ВЫКЛ")}
    for _, b in ipairs(menuBtns) do
      lg.setColor(1, 1, 1, 0.2)
      lg.rectangle("fill", b.x, b.y, b.w, b.h, 12)
      if b.id == "creative" and creative then lg.setColor(0.5, 1, 0.5) else lg.setColor(1, 1, 1) end
      lg.printf(labels[b.id], b.x, b.y + b.h / 2 - font:getHeight() / 2, b.w, "center")
    end
  end
end
