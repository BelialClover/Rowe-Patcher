local currentSpecies = 0
local tempSpecies = 0
--Setup here
local scriptdirectory = "F:/Github/ROWECries" -- change this to your folder where you have everything
local enableAnimeCries = false                -- set to true if you want anime cries, if not set it to false
DATA_FOLDER = scriptdirectory .. "./cries"
ANIME_DATA_FOLDER = scriptdirectory .. "./animecries"
local currentMysteryGift = 0
--Addresses
--Cries
local adress_currentcry  = 0x0203fff0      -- DmaFill16(3, VarGet(VAR_CRY_SPECIES), 0x0203fff0, 0x2);
local adress_crymode     = 0x0203ffe0      -- DmaFill16(3, VarGet(VAR_CRY_SPECIES), 0x0203fff0, 0x2);
--Mystery Gift
local adress_mysterygift = 0x0203ffd0
--Outbreak
local adress_outbreak_species     = 0x0203ffc0
local adress_outbreak_mapnum      = 0x0203ffb0
local adress_outbreak_group       = 0x0203ffa0
local adress_outbreak_level       = 0x0203fef0
local adress_outbreak_numbadges   = 0x0203fee0
local adress_outbreak_probability = 0x0203fed0
local adress_outbreak_move1       = 0x0203fec0
--outbreak stuff
local Outbreak_species     = 0
local Outbreak_mapnum      = 0
local Outbreak_mapgroup    = 0
local Outbreak_move1       = 0
local Outbreak_probability = 0
local Outbreak_level       = 0
local Outbreak_badges      = 0
local Outbreak_percent     = 0
--roamer stuff
local Roamer_species = 0
local Roamer_level   = 0
local Roamer_num     = 0
local Roamer_badges  = 0
local Roamer_percent = 0
--Addresses
local adress_roamer_species = 0x0203feb0
local adress_roamer_level   = 0x0203fea0
local adress_roamer_num     = 0x0203fdf0
local adress_roamer_badges  = 0x0203fde0

function globalFunction()
    --Cries
    --if detectCryMode() == 2 then
    --    enableAnimeCries = false
    --elseif detectCryMode() == 3 then
    --    enableAnimeCries = true
    --end 

    --Play Pokémon Cry
    --if not (detectCryMode() == 0) then 
    --    if not (detectCryMode() == 1) then 
    --        detectCry()
    --    end
    --end
end

--this runs a lot of times
function detectCry()
	local cryspecies = emu:read16(adress_currentcry)
	local species = speciesNames[cryspecies]

    local filelocation = DATA_FOLDER .. "/" .. species .. ".mp3"
    local animefilelocation = ANIME_DATA_FOLDER .. "/" .. cryspecies .. ".wav"
	local file = filelocation
    
    if enableAnimeCries == true and cryspecies < 650 then 
        file = animefilelocation
    end

	if species == "??????????" then 
		species = speciesNames[0]
		wait(6000)
    elseif file_exists(file) == true then
		os.execute(file) --Play the Cry
        emu:write16(adress_currentcry, 0) -- Clear the Pokemon Cry value
		wait(6000)
	end
end

--local function read_file(path)
function read_file(path)
    print_file_exists(path)
    local file = io.popen(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    --return content
end

function file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

function detectCryMode()
	local read = emu:read16(adress_crymode)

    return read
    --0 Disable, 1 Normal cries, 2 Anime Cries
end

function print_file_exists(path)
    if file_exists(path) == true then
        console:log("File " .. path .. " Exist")
    else
        console:log("File " .. path .. " Does Not Exist")
    end
end


function printWelcomeMessage(buffer)
	buffer:clear()
    local filelocation = DATA_FOLDER .. "/abomasnow.mp3"
    if file_exists(filelocation) == true then
        buffer:print(string.format("Welcome to R.O.W.E. Companion everything seems to be set up correctly."))
    else
        buffer:print(string.format("Welcome to R.O.W.E. Companion everything seems to be set up correctly."))
	    --buffer:print(string.format("Welcome to R.O.W.E. Companion, the Cry directory does not seem to be set up correctly."))
    end
end

--callbacks:add("start", detectGame)
callbacks:add("frame", globalFunction) -- Cries support
if emu then
	--this runs first
	if not welcomeBuffer then
		welcomeBuffer = console:createBuffer("Welcome")
	end
	printWelcomeMessage(welcomeBuffer)
end

--This checks the socket data
function socketMsgToFunction(msg)
    --Mystery gift
    mysterygift_b,  mysterygift_e  = string.find(msg, "mysterygift")
    mysterygift_b2, mysterygift_e2 = string.find(msg, "received")
    if mysterygift_b ~= null then
        type   = string.sub(msg, mysterygift_b, mysterygift_e)
        console:log("mysterygift Working: " .. type)
        if type == "mysterygift" then
            number = string.sub(msg, mysterygift_e + 1, mysterygift_b2 - 1)
            setMysteryGift(number)
        end
    end
    --Outbreak
        --species
        outbreakSpecies_b,  outbreakSpecies_e   = string.find(msg, "outbreakspecies")
        outbreakSpecies_b2, outbreakSpecies_e2  = string.find(msg, "received")
        if outbreakSpecies_b ~= null then
            type   = string.sub(msg, outbreakSpecies_b, outbreakSpecies_e)
            if type == "outbreakspecies" then
                number = tonumber(string.sub(msg, outbreakSpecies_e + 1, outbreakSpecies_b2 - 1))
                Outbreak_species = number
                Outbreak_percent = 1
                --console:log("Outbreak Species Working: " .. Outbreak_species .. " Percent: " .. Outbreak_percent)
            end
        end
        --mapnum
        outbreakMapNum_b,  outbreakMapNum_e  = string.find(msg, "outbreakmapnum")
        outbreakMapNum_b2, outbreakMapNum_e2 = string.find(msg, "received")
        if outbreakMapNum_b ~= null then
            type   = string.sub(msg, outbreakMapNum_b, outbreakMapNum_e)
            if type == "outbreakmapnum" then
                number = tonumber(string.sub(msg, outbreakMapNum_e + 1, outbreakMapNum_b2 - 1))
                Outbreak_mapnum = number
                Outbreak_percent = Outbreak_percent + 1
                --console:log("Outbreak MapNum Working: " .. Outbreak_mapnum .. " Percent: " .. Outbreak_percent)
            end
        end
        --mapgroup
        outbreakMapGroup_b,  outbreakMapGroup_e   = string.find(msg, "outbreakmapgroup")
        outbreakMapGroup_b2, outbreakMapGroup_e2 = string.find(msg, "received")
        if outbreakMapGroup_b ~= null then
            type   = string.sub(msg, outbreakMapGroup_b, outbreakMapGroup_e)
            if type == "outbreakmapgroup" then
                number = tonumber(string.sub(msg, outbreakMapGroup_e + 1, outbreakMapGroup_b2 - 1))
                Outbreak_mapgroup = number
                Outbreak_percent = Outbreak_percent + 1
                --console:log("Outbreak MapGroup Working: " .. Outbreak_mapgroup .. " Percent: " .. Outbreak_percent)
            end
        end
        --move1
        outbreakMove1_b, outbreakMove1_e   = string.find(msg, "outbreakmove1")
        outbreakMove1_b2, outbreakMove1_e2 = string.find(msg, "received")
        if outbreakMove1_b ~= null then
            type   = string.sub(msg, outbreakMove1_b, outbreakMove1_e)
            if type == "outbreakmove1" then
                number = tonumber(string.sub(msg, outbreakMove1_e + 1, outbreakMove1_b2 - 1))
                Outbreak_move1 = number
                Outbreak_percent = Outbreak_percent + 1
                --console:log("Outbreak Move 1 Working: " .. Outbreak_move1 .. " Percent: " .. Outbreak_percent)
            end
        end
        --probability
        outbreakProbability_b,  outbreakProbability_e   = string.find(msg, "outbreakprobability")
        outbreakProbability_b2, outbreakProbability_e2 = string.find(msg, "received")
        if outbreakProbability_b ~= null then
            type   = string.sub(msg, outbreakProbability_b, outbreakProbability_e)
            if type == "outbreakprobability" then
                number = tonumber(string.sub(msg, outbreakProbability_e + 1, outbreakProbability_b2 - 1))
                Outbreak_probability = number
                Outbreak_percent = Outbreak_percent + 1
                --console:log("Outbreak Probability Working: " .. Outbreak_probability .. " Percent: " .. Outbreak_percent)
            end
        end
        --level
        outbreakLevel_b, outbreakLevel_e   = string.find(msg, "outbreaklevel")
        outbreakLevel_b2, outbreakLevel_e2 = string.find(msg, "received")
        if outbreakLevel_b ~= null then
            type   = string.sub(msg, outbreakLevel_b, outbreakLevel_e)
            if type == "outbreaklevel" then
                number = tonumber(string.sub(msg, outbreakLevel_e + 1, outbreakLevel_b2 - 1))
                Outbreak_level = number
                Outbreak_percent = Outbreak_percent + 1
                --console:log("Outbreak Level Working: " .. Outbreak_level .. " Percent: " .. Outbreak_percent)
            end
        end
        --badges
        outbreakBadges_b,  outbreakBadges_e  = string.find(msg, "outbreakbadges")
        outbreakBadges_b2, outbreakBadges_e2 = string.find(msg, "received")
        if outbreakBadges_b ~= null then
            type   = string.sub(msg, outbreakBadges_b, outbreakBadges_e)
            if type == "outbreakbadges" then
                number = tonumber(string.sub(msg, outbreakBadges_e + 1, outbreakBadges_b2 - 1))
                Outbreak_badges = number
                Outbreak_percent = Outbreak_percent + 1
                --console:log("Outbreak Badges Working: " .. Outbreak_badges .. " Percent: " .. Outbreak_percent)
            end
        end

        if(Outbreak_percent == 7) then
            createOubreak()
        end
    --Roamer
        --species
        roamerSpecies_b,  roamerSpecies_e  = string.find(msg, "roamerspecies")
        roamerSpecies_b2, roamerSpecies_e2 = string.find(msg, "received")
        if roamerSpecies_b ~= null then
            type   = string.sub(msg, roamerSpecies_b, roamerSpecies_e)
            if type == "roamerspecies" then
                number = tonumber(string.sub(msg, roamerSpecies_e + 1, roamerSpecies_b2 - 1))
                Roamer_species = number
                Roamer_percent = 1
                console:log("Roamer Species Working: " .. Roamer_species .. " Percent: " .. Roamer_percent)
            end
        end
        --level
        roamerLevel_b, roamerLevel_e   = string.find(msg, "roamerlevel")
        roamerLevel_b2, roamerLevel_e2 = string.find(msg, "received")
        if roamerLevel_b ~= null then
            type   = string.sub(msg, roamerLevel_b, roamerLevel_e)
            if type == "roamerlevel" then
                number = tonumber(string.sub(msg, roamerLevel_e + 1, roamerLevel_b2 - 1))
                Roamer_level = number
                Roamer_percent = Roamer_percent + 1
                console:log("Roamer Level Working: " .. Roamer_level .. " Percent: " .. Roamer_percent)
            end
        end
        --number
        roamerNumber_b,  roamerNumber_e  = string.find(msg, "roamernum")
        roamerNumber_b2, roamerNumber_e2 = string.find(msg, "received")
        if roamerNumber_b ~= null then
            type   = string.sub(msg, roamerNumber_b, roamerNumber_e)
            if type == "roamernum" then
                number = tonumber(string.sub(msg, roamerNumber_e + 1, roamerNumber_b2 - 1))
                Roamer_num = number
                Roamer_percent = Roamer_percent + 1
                console:log("Roamer Number Working: " .. Roamer_num .. " Percent: " .. Roamer_percent)
            end
        end
        --badges
        roamerBadges_b,  roamerBadges_e  = string.find(msg, "roamerbadges")
        roamerBadges_b2, roamerBadges_e2 = string.find(msg, "received")
        if roamerBadges_b ~= null then
            type   = string.sub(msg, roamerBadges_b, roamerBadges_e)
            if type == "roamerbadges" then
                number = tonumber(string.sub(msg, roamerBadges_e + 1, roamerBadges_b2 - 1))
                Roamer_badges = number
                Roamer_percent = Roamer_percent + 1
                console:log("Roamer Badges Working: " .. Roamer_badges .. " Percent: " .. Roamer_percent)
            end
        end

        if(Roamer_percent == 4) then
            createRoamer()
        end
end


function setMysteryGift(value)
	local MysteryGift = emu:read16(adress_mysterygift)
    
	currentMysteryGift = tonumber(value)
    
    console:log("New Mystery Gift ID: " .. currentMysteryGift)
    console:log("A Mystery Gift was received!")
    emu:write16(adress_mysterygift, currentMysteryGift) -- Sets the Mystery Gift
end

function createOubreak()
    if not (Outbreak_species == 0) then 
        local species = speciesNames[Outbreak_species]
        console:log("An Outbreak of " .. species .. " was found!")
        --console:log("An Outbreak of was found!")
        emu:write16(adress_outbreak_species,     Outbreak_species)
        emu:write16(adress_outbreak_mapnum,      Outbreak_mapnum)
        emu:write16(adress_outbreak_group,       Outbreak_mapgroup)
        emu:write16(adress_outbreak_level,       Outbreak_level)
        emu:write16(adress_outbreak_numbadges,   Outbreak_badges)
        emu:write16(adress_outbreak_probability, Outbreak_probability)
        emu:write16(adress_outbreak_move1,       Outbreak_move1)
        Outbreak_percent = 0
    end
end

function createRoamer()
    if not (Roamer_species == 0) then 
        local species = speciesNames[Roamer_species]
        console:log("A Roamer " .. species .. " was found!")
        --console:log("An Outbreak of was found!")
        emu:write16(adress_roamer_species,   Roamer_species)
        emu:write16(adress_roamer_level,     Roamer_level)
        emu:write16(adress_roamer_num,       Roamer_num)
        emu:write16(adress_roamer_badges,    Roamer_badges)
        Roamer_percent = 0
    end
end

--Socket Server
lastkeys = nil
server = nil
ST_sockets = {}
nextID = 1

local KEY_NAMES = { "A", "B", "s", "S", "<", ">", "^", "v", "R", "L" }

function ST_stop(id)
	local sock = ST_sockets[id]
	ST_sockets[id] = nil
	sock:close()
end

function ST_format(id, msg, isError)
	local prefix = "Socket " .. id
	if isError then
		prefix = prefix .. " Error: "
	else
		prefix = prefix .. " Received: "
	end

	return prefix .. msg
end

function ST_error(id, err)
	--console:error(ST_format(id, err, true))
	ST_stop(id)
end

function ST_received(id)
	local sock = ST_sockets[id]
	if not sock then return end
	while true do
		local p, err = sock:receive(1024)
		if p then
			--console:log(ST_format(id, p:match("^(.-)%s*$")))
            socketMsgToFunction(p:match("^(.-)%s*$"))
		else
			if err ~= socket.ERRORS.AGAIN then
				--console:error(ST_format(id, err, true))
				ST_stop(id)
			end
			return
		end
	end
end

function ST_scankeys()
	local keys = emu:getKeys()
	if keys ~= lastkeys then
		lastkeys = keys
		local msg = "["
		for i, k in ipairs(KEY_NAMES) do
			if (keys & (1 << (i - 1))) == 0 then
				msg = msg .. " "
			else
				msg = msg .. k;
			end
		end
		msg = msg .. "]\n"
		for id, sock in pairs(ST_sockets) do
			if sock then sock:send(msg) end
		end
	end
end

function ST_accept()
	local sock, err = server:accept()
	if err then
		console:error(ST_format("Accept", err, true))
		return
	end
	local id = nextID
	nextID = id + 1
	ST_sockets[id] = sock
	sock:add("received", function() ST_received(id) end)
	sock:add("error", function() ST_error(id) end)
	--console:log(ST_format(id, "Connected"))
end

callbacks:add("keysRead", ST_scankeys)

local port = 8888
server = nil
while not server do
	server, err = socket.bind(nil, port)
	if err then
		if err == socket.ERRORS.ADDRESS_IN_USE then
			port = port + 1
		else
			console:error(ST_format("Bind", err, true))
			break
		end
	else
		local ok
		ok, err = server:listen()
		if err then
			server:close()
			console:error(ST_format("Listen", err, true))
		else
			console:log("R.O.W.E. Companion server working, ready to connect to your browser")
			server:add("received", ST_accept)
		end
	end
end
--

--this is the filename of each cry
speciesNames = {
	[0] = ("??????????"),
    [1] = ("bulbasaur"),
    [2] = ("ivysaur"),
    [3] = ("venusaur"),
    [4] = ("charmander"),
    [5] = ("charmeleon"),
    [6] = ("charizard"),
    [7] = ("squirtle"),
    [8] = ("wartortle"),
    [9] = ("blastoise"),
    [10] = ("caterpie"),
    [11] = ("metapod"),
    [12] = ("butterfree"),
    [13] = ("weedle"),
    [14] = ("kakuna"),
    [15] = ("beedrill"),
    [16] = ("pidgey"),
    [17] = ("pidgeotto"),
    [18] = ("pidgeot"),
    [19] = ("rattata"),
    [20] = ("raticate"),
    [21] = ("spearow"),
    [22] = ("fearow"),
    [23] = ("ekans"),
    [24] = ("arbok"),
    [25] = ("pikachu"),
    [26] = ("raichu"),
    [27] = ("sandshrew"),
    [28] = ("sandslash"),
    [29] = ("nidoran♀"),
    [30] = ("nidorina"),
    [31] = ("nidoqueen"),
    [32] = ("nidoran♂"),
    [33] = ("nidorino"),
    [34] = ("nidoking"),
    [35] = ("clefairy"),
    [36] = ("clefable"),
    [37] = ("vulpix"),
    [38] = ("ninetales"),
    [39] = ("jigglypuff"),
    [40] = ("wigglytuff"),
    [41] = ("zubat"),
    [42] = ("golbat"),
    [43] = ("oddish"),
    [44] = ("gloom"),
    [45] = ("vileplume"),
    [46] = ("paras"),
    [47] = ("parasect"),
    [48] = ("venonat"),
    [49] = ("venomoth"),
    [50] = ("diglett"),
    [51] = ("dugtrio"),
    [52] = ("meowth"),
    [53] = ("persian"),
    [54] = ("psyduck"),
    [55] = ("golduck"),
    [56] = ("mankey"),
    [57] = ("primeape"),
    [58] = ("growlithe"),
    [59] = ("arcanine"),
    [60] = ("poliwag"),
    [61] = ("poliwhirl"),
    [62] = ("poliwrath"),
    [63] = ("abra"),
    [64] = ("kadabra"),
    [65] = ("alakazam"),
    [66] = ("machop"),
    [67] = ("machoke"),
    [68] = ("machamp"),
    [69] = ("bellsprout"),
    [70] = ("weepinbell"),
    [71] = ("victreebel"),
    [72] = ("tentacool"),
    [73] = ("tentacruel"),
    [74] = ("geodude"),
    [75] = ("graveler"),
    [76] = ("golem"),
    [77] = ("ponyta"),
    [78] = ("rapidash"),
    [79] = ("slowpoke"),
    [80] = ("slowbro"),
    [81] = ("magnemite"),
    [82] = ("magneton"),
    [83] = ("farfetch'd"),
    [84] = ("doduo"),
    [85] = ("dodrio"),
    [86] = ("seel"),
    [87] = ("dewgong"),
    [88] = ("grimer"),
    [89] = ("muk"),
    [90] = ("shellder"),
    [91] = ("cloyster"),
    [92] = ("gastly"),
    [93] = ("haunter"),
    [94] = ("gengar"),
    [95] = ("onix"),
    [96] = ("drowzee"),
    [97] = ("hypno"),
    [98] = ("krabby"),
    [99] = ("kingler"),
    [100] = ("voltorb"),
    [101] = ("electrode"),
    [102] = ("exeggcute"),
    [103] = ("exeggutor"),
    [104] = ("cubone"),
    [105] = ("marowak"),
    [106] = ("hitmonlee"),
    [107] = ("hitmonchan"),
    [108] = ("lickitung"),
    [109] = ("koffing"),
    [110] = ("weezing"),
    [111] = ("rhyhorn"),
    [112] = ("rhydon"),
    [113] = ("chansey"),
    [114] = ("tangela"),
    [115] = ("kangaskhan"),
    [116] = ("horsea"),
    [117] = ("seadra"),
    [118] = ("goldeen"),
    [119] = ("seaking"),
    [120] = ("staryu"),
    [121] = ("starmie"),
    [122] = ("mr. mime"),
    [123] = ("scyther"),
    [124] = ("jynx"),
    [125] = ("electabuzz"),
    [126] = ("magmar"),
    [127] = ("pinsir"),
    [128] = ("tauros"),
    [129] = ("magikarp"),
    [130] = ("gyarados"),
    [131] = ("lapras"),
    [132] = ("ditto"),
    [133] = ("eevee"),
    [134] = ("vaporeon"),
    [135] = ("jolteon"),
    [136] = ("flareon"),
    [137] = ("porygon"),
    [138] = ("omanyte"),
    [139] = ("omastar"),
    [140] = ("kabuto"),
    [141] = ("kabutops"),
    [142] = ("aerodactyl"),
    [143] = ("snorlax"),
    [144] = ("articuno"),
    [145] = ("zapdos"),
    [146] = ("moltres"),
    [147] = ("dratini"),
    [148] = ("dragonair"),
    [149] = ("dragonite"),
    [150] = ("mewtwo"),
    [151] = ("mew"),
    [152] = ("chikorita"),
    [153] = ("bayleef"),
    [154] = ("meganium"),
    [155] = ("cyndaquil"),
    [156] = ("quilava"),
    [157] = ("typhlosion"),
    [158] = ("totodile"),
    [159] = ("croconaw"),
    [160] = ("feraligatr"),
    [161] = ("sentret"),
    [162] = ("furret"),
    [163] = ("hoothoot"),
    [164] = ("noctowl"),
    [165] = ("ledyba"),
    [166] = ("ledian"),
    [167] = ("spinarak"),
    [168] = ("ariados"),
    [169] = ("crobat"),
    [170] = ("chinchou"),
    [171] = ("lanturn"),
    [172] = ("pichu"),
    [173] = ("cleffa"),
    [174] = ("igglybuff"),
    [175] = ("togepi"),
    [176] = ("togetic"),
    [177] = ("natu"),
    [178] = ("xatu"),
    [179] = ("mareep"),
    [180] = ("flaaffy"),
    [181] = ("ampharos"),
    [182] = ("bellossom"),
    [183] = ("marill"),
    [184] = ("azumarill"),
    [185] = ("sudowoodo"),
    [186] = ("politoed"),
    [187] = ("hoppip"),
    [188] = ("skiploom"),
    [189] = ("jumpluff"),
    [190] = ("aipom"),
    [191] = ("sunkern"),
    [192] = ("sunflora"),
    [193] = ("yanma"),
    [194] = ("wooper"),
    [195] = ("quagsire"),
    [196] = ("espeon"),
    [197] = ("umbreon"),
    [198] = ("murkrow"),
    [199] = ("slowking"),
    [200] = ("misdreavus"),
    [201] = ("unown"),
    [202] = ("wobbuffet"),
    [203] = ("girafarig"),
    [204] = ("pineco"),
    [205] = ("forretress"),
    [206] = ("dunsparce"),
    [207] = ("gligar"),
    [208] = ("steelix"),
    [209] = ("snubbull"),
    [210] = ("granbull"),
    [211] = ("qwilfish"),
    [212] = ("scizor"),
    [213] = ("shuckle"),
    [214] = ("heracross"),
    [215] = ("sneasel"),
    [216] = ("teddiursa"),
    [217] = ("ursaring"),
    [218] = ("slugma"),
    [219] = ("magcargo"),
    [220] = ("swinub"),
    [221] = ("piloswine"),
    [222] = ("corsola"),
    [223] = ("remoraid"),
    [224] = ("octillery"),
    [225] = ("delibird"),
    [226] = ("mantine"),
    [227] = ("skarmory"),
    [228] = ("houndour"),
    [229] = ("houndoom"),
    [230] = ("kingdra"),
    [231] = ("phanpy"),
    [232] = ("donphan"),
    [233] = ("porygon2"),
    [234] = ("stantler"),
    [235] = ("smeargle"),
    [236] = ("tyrogue"),
    [237] = ("hitmontop"),
    [238] = ("smoochum"),
    [239] = ("elekid"),
    [240] = ("magby"),
    [241] = ("miltank"),
    [242] = ("blissey"),
    [243] = ("raikou"),
    [244] = ("entei"),
    [245] = ("suicune"),
    [246] = ("larvitar"),
    [247] = ("pupitar"),
    [248] = ("tyranitar"),
    [249] = ("lugia"),
    [250] = ("ho-oh"),
    [251] = ("celebi"),
    [252] = ("treecko"),
    [253] = ("grovyle"),
    [254] = ("sceptile"),
    [255] = ("torchic"),
    [256] = ("combusken"),
    [257] = ("blaziken"),
    [258] = ("mudkip"),
    [259] = ("marshtomp"),
    [260] = ("swampert"),
    [261] = ("poochyena"),
    [262] = ("mightyena"),
    [263] = ("zigzagoon"),
    [264] = ("linoone"),
    [265] = ("wurmple"),
    [266] = ("silcoon"),
    [267] = ("beautifly"),
    [268] = ("cascoon"),
    [269] = ("dustox"),
    [270] = ("lotad"),
    [271] = ("lombre"),
    [272] = ("ludicolo"),
    [273] = ("seedot"),
    [274] = ("nuzleaf"),
    [275] = ("shiftry"),
    [276] = ("taillow"),
    [277] = ("swellow"),
    [278] = ("wingull"),
    [279] = ("pelipper"),
    [280] = ("ralts"),
    [281] = ("kirlia"),
    [282] = ("gardevoir"),
    [283] = ("surskit"),
    [284] = ("masquerain"),
    [285] = ("shroomish"),
    [286] = ("breloom"),
    [287] = ("slakoth"),
    [288] = ("vigoroth"),
    [289] = ("slaking"),
    [290] = ("nincada"),
    [291] = ("ninjask"),
    [292] = ("shedinja"),
    [293] = ("whismur"),
    [294] = ("loudred"),
    [295] = ("exploud"),
    [296] = ("makuhita"),
    [297] = ("hariyama"),
    [298] = ("azurill"),
    [299] = ("nosepass"),
    [300] = ("skitty"),
    [301] = ("delcatty"),
    [302] = ("sableye"),
    [303] = ("mawile"),
    [304] = ("aron"),
    [305] = ("lairon"),
    [306] = ("aggron"),
    [307] = ("meditite"),
    [308] = ("medicham"),
    [309] = ("electrike"),
    [310] = ("manectric"),
    [311] = ("plusle"),
    [312] = ("minun"),
    [313] = ("volbeat"),
    [314] = ("illumise"),
    [315] = ("roselia"),
    [316] = ("gulpin"),
    [317] = ("swalot"),
    [318] = ("carvanha"),
    [319] = ("sharpedo"),
    [320] = ("wailmer"),
    [321] = ("wailord"),
    [322] = ("numel"),
    [323] = ("camerupt"),
    [324] = ("torkoal"),
    [325] = ("spoink"),
    [326] = ("grumpig"),
    [327] = ("spinda"),
    [328] = ("trapinch"),
    [329] = ("vibrava"),
    [330] = ("flygon"),
    [331] = ("cacnea"),
    [332] = ("cacturne"),
    [333] = ("swablu"),
    [334] = ("altaria"),
    [335] = ("zangoose"),
    [336] = ("seviper"),
    [337] = ("lunatone"),
    [338] = ("solrock"),
    [339] = ("barboach"),
    [340] = ("whiscash"),
    [341] = ("corphish"),
    [342] = ("crawdaunt"),
    [343] = ("baltoy"),
    [344] = ("claydol"),
    [345] = ("lileep"),
    [346] = ("cradily"),
    [347] = ("anorith"),
    [348] = ("armaldo"),
    [349] = ("feebas"),
    [350] = ("milotic"),
    [351] = ("castform"),
    [352] = ("kecleon"),
    [353] = ("shuppet"),
    [354] = ("banette"),
    [355] = ("duskull"),
    [356] = ("dusclops"),
    [357] = ("tropius"),
    [358] = ("chimecho"),
    [359] = ("absol"),
    [360] = ("wynaut"),
    [361] = ("snorunt"),
    [362] = ("glalie"),
    [363] = ("spheal"),
    [364] = ("sealeo"),
    [365] = ("walrein"),
    [366] = ("clamperl"),
    [367] = ("huntail"),
    [368] = ("gorebyss"),
    [369] = ("relicanth"),
    [370] = ("luvdisc"),
    [371] = ("bagon"),
    [372] = ("shelgon"),
    [373] = ("salamence"),
    [374] = ("beldum"),
    [375] = ("metang"),
    [376] = ("metagross"),
    [377] = ("regirock"),
    [378] = ("regice"),
    [379] = ("registeel"),
    [380] = ("latias"),
    [381] = ("latios"),
    [382] = ("kyogre"),
    [383] = ("groudon"),
    [384] = ("rayquaza"),
    [385] = ("jirachi"),
    [386] = ("deoxys"),
    [387] = ("turtwig"),
    [388] = ("grotle"),
    [389] = ("torterra"),
    [390] = ("chimchar"),
    [391] = ("monferno"),
    [392] = ("infernape"),
    [393] = ("piplup"),
    [394] = ("prinplup"),
    [395] = ("empoleon"),
    [396] = ("starly"),
    [397] = ("staravia"),
    [398] = ("staraptor"),
    [399] = ("bidoof"),
    [400] = ("bibarel"),
    [401] = ("kricketot"),
    [402] = ("kricketune"),
    [403] = ("shinx"),
    [404] = ("luxio"),
    [405] = ("luxray"),
    [406] = ("budew"),
    [407] = ("roserade"),
    [408] = ("cranidos"),
    [409] = ("rampardos"),
    [410] = ("shieldon"),
    [411] = ("bastiodon"),
    [412] = ("burmy"),
    [413] = ("wormadam"),
    [414] = ("mothim"),
    [415] = ("combee"),
    [416] = ("vespiquen"),
    [417] = ("pachirisu"),
    [418] = ("buizel"),
    [419] = ("floatzel"),
    [420] = ("cherubi"),
    [421] = ("cherrim"),
    [422] = ("shellos"),
    [423] = ("gastrodon"),
    [424] = ("ambipom"),
    [425] = ("drifloon"),
    [426] = ("drifblim"),
    [427] = ("buneary"),
    [428] = ("lopunny"),
    [429] = ("mismagius"),
    [430] = ("honchkrow"),
    [431] = ("glameow"),
    [432] = ("purugly"),
    [433] = ("chingling"),
    [434] = ("stunky"),
    [435] = ("skuntank"),
    [436] = ("bronzor"),
    [437] = ("bronzong"),
    [438] = ("bonsly"),
    [439] = ("mime jr."),
    [440] = ("happiny"),
    [441] = ("chatot"),
    [442] = ("spiritomb"),
    [443] = ("gible"),
    [444] = ("gabite"),
    [445] = ("garchomp"),
    [446] = ("munchlax"),
    [447] = ("riolu"),
    [448] = ("lucario"),
    [449] = ("hippopotas"),
    [450] = ("hippowdon"),
    [451] = ("skorupi"),
    [452] = ("drapion"),
    [453] = ("croagunk"),
    [454] = ("toxicroak"),
    [455] = ("carnivine"),
    [456] = ("finneon"),
    [457] = ("lumineon"),
    [458] = ("mantyke"),
    [459] = ("snover"),
    [460] = ("abomasnow"),
    [461] = ("weavile"),
    [462] = ("magnezone"),
    [463] = ("lickilicky"),
    [464] = ("rhyperior"),
    [465] = ("tangrowth"),
    [466] = ("electivire"),
    [467] = ("magmortar"),
    [468] = ("togekiss"),
    [469] = ("yanmega"),
    [470] = ("leafeon"),
    [471] = ("glaceon"),
    [472] = ("gliscor"),
    [473] = ("mamoswine"),
    [474] = ("porygon-z"),
    [475] = ("gallade"),
    [476] = ("probopass"),
    [477] = ("dusknoir"),
    [478] = ("froslass"),
    [479] = ("rotom"),
    [480] = ("uxie"),
    [481] = ("mesprit"),
    [482] = ("azelf"),
    [483] = ("dialga"),
    [484] = ("palkia"),
    [485] = ("heatran"),
    [486] = ("regigigas"),
    [487] = ("giratina"),
    [488] = ("cresselia"),
    [489] = ("phione"),
    [490] = ("manaphy"),
    [491] = ("darkrai"),
    [492] = ("shaymin"),
    [493] = ("arceus"),
    [494] = ("victini"),
    [495] = ("snivy"),
    [496] = ("servine"),
    [497] = ("serperior"),
    [498] = ("tepig"),
    [499] = ("pignite"),
    [500] = ("emboar"),
    [501] = ("oshawott"),
    [502] = ("dewott"),
    [503] = ("samurott"),
    [504] = ("patrat"),
    [505] = ("watchog"),
    [506] = ("lillipup"),
    [507] = ("herdier"),
    [508] = ("stoutland"),
    [509] = ("purrloin"),
    [510] = ("liepard"),
    [511] = ("pansage"),
    [512] = ("simisage"),
    [513] = ("pansear"),
    [514] = ("simisear"),
    [515] = ("panpour"),
    [516] = ("simipour"),
    [517] = ("munna"),
    [518] = ("musharna"),
    [519] = ("pidove"),
    [520] = ("tranquill"),
    [521] = ("unfezant"),
    [522] = ("blitzle"),
    [523] = ("zebstrika"),
    [524] = ("roggenrola"),
    [525] = ("boldore"),
    [526] = ("gigalith"),
    [527] = ("woobat"),
    [528] = ("swoobat"),
    [529] = ("drilbur"),
    [530] = ("excadrill"),
    [531] = ("audino"),
    [532] = ("timburr"),
    [533] = ("gurdurr"),
    [534] = ("conkeldurr"),
    [535] = ("tympole"),
    [536] = ("palpitoad"),
    [537] = ("seismitoad"),
    [538] = ("throh"),
    [539] = ("sawk"),
    [540] = ("sewaddle"),
    [541] = ("swadloon"),
    [542] = ("leavanny"),
    [543] = ("venipede"),
    [544] = ("whirlipede"),
    [545] = ("scolipede"),
    [546] = ("cottonee"),
    [547] = ("whimsicott"),
    [548] = ("petilil"),
    [549] = ("lilligant"),
    [550] = ("basculin"),
    [551] = ("sandile"),
    [552] = ("krokorok"),
    [553] = ("krookodile"),
    [554] = ("darumaka"),
    [555] = ("darmanitan"),
    [556] = ("maractus"),
    [557] = ("dwebble"),
    [558] = ("crustle"),
    [559] = ("scraggy"),
    [560] = ("scrafty"),
    [561] = ("sigilyph"),
    [562] = ("yamask"),
    [563] = ("cofagrigus"),
    [564] = ("tirtouga"),
    [565] = ("carracosta"),
    [566] = ("archen"),
    [567] = ("archeops"),
    [568] = ("trubbish"),
    [569] = ("garbodor"),
    [570] = ("zorua"),
    [571] = ("zoroark"),
    [572] = ("minccino"),
    [573] = ("cinccino"),
    [574] = ("gothita"),
    [575] = ("gothorita"),
    [576] = ("gothitelle"),
    [577] = ("solosis"),
    [578] = ("duosion"),
    [579] = ("reuniclus"),
    [580] = ("ducklett"),
    [581] = ("swanna"),
    [582] = ("vanillite"),
    [583] = ("vanillish"),
    [584] = ("vanilluxe"),
    [585] = ("deerling"),
    [586] = ("sawsbuck"),
    [587] = ("emolga"),
    [588] = ("karrablast"),
    [589] = ("escavalier"),
    [590] = ("foongus"),
    [591] = ("amoonguss"),
    [592] = ("frillish"),
    [593] = ("jellicent"),
    [594] = ("alomomola"),
    [595] = ("joltik"),
    [596] = ("galvantula"),
    [597] = ("ferroseed"),
    [598] = ("ferrothorn"),
    [599] = ("klink"),
    [600] = ("klang"),
    [601] = ("klinklang"),
    [602] = ("tynamo"),
    [603] = ("eelektrik"),
    [604] = ("eelektross"),
    [605] = ("elgyem"),
    [606] = ("beheeyem"),
    [607] = ("litwick"),
    [608] = ("lampent"),
    [609] = ("chandelure"),
    [610] = ("axew"),
    [611] = ("fraxure"),
    [612] = ("haxorus"),
    [613] = ("cubchoo"),
    [614] = ("beartic"),
    [615] = ("cryogonal"),
    [616] = ("shelmet"),
    [617] = ("accelgor"),
    [618] = ("stunfisk"),
    [619] = ("mienfoo"),
    [620] = ("mienshao"),
    [621] = ("druddigon"),
    [622] = ("golett"),
    [623] = ("golurk"),
    [624] = ("pawniard"),
    [625] = ("bisharp"),
    [626] = ("bouffalant"),
    [627] = ("rufflet"),
    [628] = ("braviary"),
    [629] = ("vullaby"),
    [630] = ("mandibuzz"),
    [631] = ("heatmor"),
    [632] = ("durant"),
    [633] = ("deino"),
    [634] = ("zweilous"),
    [635] = ("hydreigon"),
    [636] = ("larvesta"),
    [637] = ("volcarona"),
    [638] = ("cobalion"),
    [639] = ("terrakion"),
    [640] = ("virizion"),
    [641] = ("tornadus"),
    [642] = ("thundurus"),
    [643] = ("reshiram"),
    [644] = ("zekrom"),
    [645] = ("landorus"),
    [646] = ("kyurem"),
    [647] = ("keldeo"),
    [648] = ("meloetta"),
    [648] = ("genesect"),
    [650] = ("chespin"),
    [651] = ("quilladin"),
    [652] = ("chesnaught"),
    [653] = ("fennekin"),
    [654] = ("braixen"),
    [655] = ("delphox"),
    [656] = ("froakie"),
    [657] = ("frogadier"),
    [658] = ("greninja"),
    [659] = ("bunnelby"),
    [660] = ("diggersby"),
    [661] = ("fletchling"),
    [662] = ("flechinder"),
    [663] = ("talonflame"),
    [664] = ("scatterbug"),
    [665] = ("spewpa"),
    [666] = ("vivillon"),
    [667] = ("litleo"),
    [668] = ("pyroar"),
    [669] = ("flabébé"),
    [670] = ("floette"),
    [671] = ("florges"),
    [672] = ("skiddo"),
    [673] = ("gogoat"),
    [674] = ("pancham"),
    [675] = ("pangoro"),
    [676] = ("furfrou"),
    [677] = ("espurr"),
    [678] = ("meowstic"),
    [679] = ("honedge"),
    [680] = ("doublade"),
    [681] = ("aegislash"),
    [682] = ("spritzee"),
    [683] = ("aromatisse"),
    [684] = ("swirlix"),
    [685] = ("slurpuff"),
    [686] = ("inkay"),
    [687] = ("malamar"),
    [688] = ("binacle"),
    [689] = ("barbaracle"),
    [690] = ("skrelp"),
    [691] = ("dragalge"),
    [692] = ("clauncher"),
    [693] = ("clawitzer"),
    [694] = ("helioptile"),
    [695] = ("heliolisk"),
    [696] = ("tyrunt"),
    [697] = ("tyrantrum"),
    [698] = ("amaura"),
    [699] = ("aurorus"),
    [700] = ("sylveon"),
    [701] = ("hawlucha"),
    [702] = ("dedenne"),
    [703] = ("carbink"),
    [704] = ("goomy"),
    [705] = ("sliggoo"),
    [706] = ("goodra"),
    [707] = ("klefki"),
    [708] = ("phantump"),
    [709] = ("trevenant"),
    [710] = ("pumpkaboo"),
    [711] = ("gourgeist"),
    [712] = ("bergmite"),
    [713] = ("avalugg"),
    [714] = ("noibat"),
    [715] = ("noivern"),
    [716] = ("xerneas"),
    [717] = ("yveltal"),
    [718] = ("zygarde"),
    [719] = ("diancie"),
    [720] = ("hoopa"),
    [721] = ("volcanion"),
    [722] = ("rowlet"),
    [723] = ("dartrix"),
    [724] = ("decidueye"),
    [725] = ("litten"),
    [726] = ("torracat"),
    [727] = ("incineroar"),
    [728] = ("popplio"),
    [729] = ("brionne"),
    [730] = ("primarina"),
    [731] = ("pikipek"),
    [732] = ("trumbeak"),
    [733] = ("toucannon"),
    [734] = ("yungoos"),
    [735] = ("gumshoos"),
    [736] = ("grubbin"),
    [737] = ("charjabug"),
    [378] = ("vikavolt"),
    [739] = ("crabrawler"),
    [740] = ("crabminabl"),
    [741] = ("oricorio"),
    [742] = ("cutiefly"),
    [743] = ("ribombee"),
    [744] = ("rockruff"),
    [745] = ("lycanroc"),
    [746] = ("wishiwashi"),
    [747] = ("mareanie"),
    [748] = ("toxapex"),
    [749] = ("mudbray"),
    [750] = ("mudsdale"),
    [751] = ("dewpider"),
    [752] = ("araquanid"),
    [753] = ("fomantis"),
    [754] = ("lurantis"),
    [755] = ("morelull"),
    [756] = ("shiinotic"),
    [757] = ("salandit"),
    [758] = ("salazzle"),
    [759] = ("stufful"),
    [760] = ("bewear"),
    [761] = ("bounsweet"),
    [762] = ("steenee"),
    [763] = ("tsareena"),
    [764] = ("comfey"),
    [765] = ("oranguru"),
    [766] = ("passimian"),
    [767] = ("wimpod"),
    [768] = ("golisopod"),
    [769] = ("sandygast"),
    [770] = ("palossand"),
    [771] = ("pyukumuku"),
    [772] = ("type: null"),
    [773] = ("silvally"),
    [774] = ("minior"),
    [775] = ("komala"),
    [776] = ("turtonator"),
    [777] = ("togedemaru"),
    [778] = ("mimikyu"),
    [779] = ("bruxish"),
    [780] = ("drampa"),
    [781] = ("dhelmise"),
    [782] = ("jangmo-o"),
    [783] = ("hakamo-o"),
    [784] = ("kommo-o"),
    [785] = ("tapu koko"),
    [786] = ("tapu lele"),
    [787] = ("tapu bulu"),
    [788] = ("tapu fini"),
    [789] = ("cosmog"),
    [790] = ("cosmoem"),
    [791] = ("solgaleo"),
    [792] = ("lunala"),
    [793] = ("nihilego"),
    [794] = ("buzzwole"),
    [795] = ("pheromosa"),
    [796] = ("xurkitree"),
    [797] = ("celesteela"),
    [798] = ("kartana"),
    [799] = ("guzzlord"),
    [800] = ("necrozma"),
    [801] = ("magearna"),
    [802] = ("marshadow"),
    [803] = ("poipole"),
    [804] = ("naganadel"),
    [805] = ("stakataka"),
    [806] = ("blacefalon"),
    [807] = ("zeraora"),
    [808] = ("meltan"),
    [809] = ("melmetal"),
    [810] = ("grookey"),
    [811] = ("thwackey"),
    [812] = ("rillaboom"),
    [813] = ("scorbunny"),
    [814] = ("raboot"),
    [815] = ("cinderace"),
    [816] = ("sobble"),
    [817] = ("drizzile"),
    [818] = ("inteleon"),
    [819] = ("skwovet"),
    [820] = ("greedent"),
    [821] = ("rookidee"),
    [822] = ("corvisquir"),
    [823] = ("corviknigh"),
    [824] = ("blipbug"),
    [825] = ("dottler"),
    [826] = ("orbeetle"),
    [827] = ("nickit"),
    [828] = ("thievul"),
    [829] = ("gossifleur"),
    [830] = ("eldegoss"),
    [831] = ("wooloo"),
    [832] = ("dubwool"),
    [833] = ("chewtle"),
    [834] = ("drednaw"),
    [835] = ("yamper"),
    [836] = ("boltund"),
    [837] = ("rolycoly"),
    [838] = ("carkol"),
    [839] = ("coalossal"),
    [840] = ("applin"),
    [841] = ("flapple"),
    [842] = ("appletun"),
    [843] = ("silicobra"),
    [844] = ("sandaconda"),
    [845] = ("cramorant"),
    [846] = ("arrokuda"),
    [847] = ("barraskewd"),
    [848] = ("toxel"),
    [849] = ("toxtricity"),
    [850] = ("sizzlipede"),
    [851] = ("centiskorc"),
    [852] = ("clobbopus"),
    [853] = ("grapploct"),
    [854] = ("sinistea"),
    [855] = ("polteageis"),
    [856] = ("hatenna"),
    [857] = ("hattrem"),
    [858] = ("hatterene"),
    [859] = ("impidimp"),
    [860] = ("morgrem"),
    [861] = ("grimmsnarl"),
    [862] = ("obstagoon"),
    [863] = ("perrserker"),
    [864] = ("cursola"),
    [865] = ("sirfetch'd"),
    [866] = ("mr. rime"),
    [867] = ("runerigus"),
    [868] = ("milcery"),
    [869] = ("alcremie"),
    [870] = ("falinks"),
    [871] = ("pincurchin"),
    [872] = ("snom"),
    [873] = ("frosmoth"),
    [874] = ("stonjourne"),
    [875] = ("eiscue"),
    [876] = ("indeedee"),
    [877] = ("morpeko"),
    [878] = ("cufant"),
    [879] = ("copperajah"),
    [880] = ("dracozolt"),
    [881] = ("arctozolt"),
    [882] = ("dracovish"),
    [883] = ("arctovish"),
    [884] = ("duraludon"),
    [885] = ("dreepy"),
    [886] = ("drakloak"),
    [887] = ("dragapult"),
    [888] = ("zacian"),
    [889] = ("zamazenta"),
    [890] = ("eternatus"),
    [891] = ("kubfu"),
    [892] = ("urshifu"),
    [893] = ("zarude"),
    [894] = ("regieleki"),
    [895] = ("regidrago"),
    [896] = ("glastrier"),
    [897] = ("spectrier"),
    [898] = ("calyrex"),
}
