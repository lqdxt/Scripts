const Highlighter: {
 SyntaxColors: {
  keyword: string,
  string: string,
  value: string,
  comment: string,
  builtin: string,
  property: string,
  method: string,
  identifier: string,
  plain: string
 },
 TokenTypes: {
  [string]: string
 },
 Tokenize: any
} = {
 SyntaxColors = {
  keyword = "#F86D7C",
  string = "#ADF195",
  value = "#FFC600",
  comment = "#666666",
  builtin = "#84D6F7",
  property = "#61A1F1",
  method = "#FDFBAC",
  identifier = "#FFFFFF",
  plain = "#FFFFFF",
 },
 TokenTypes = {
  ["local"] = "keyword",
  ["function"] = "keyword",
  ["end"] = "keyword",
  ["if"] = "keyword",
  ["then"] = "keyword",
  ["else"] = "keyword",
  ["elseif"] = "keyword",
  ["for"] = "keyword",
  ["while"] = "keyword",
  ["do"] = "keyword",
  ["return"] = "keyword",
  ["break"] = "keyword",
  ["continue"] = "keyword",
  ["repeat"] = "keyword",
  ["until"] = "keyword",
  ["in"] = "keyword",
  ["not"] = "keyword",
  ["and"] = "keyword",
  ["or"] = "keyword",
  ["export"] = "keyword",
  ["const"] = "keyword",
  ["type"] = "keyword",
  ["typeof"] = "keyword",
  ["self"] = "keyword",
  ["write"] = "keyword",
  ["read"] = "keyword",

  ["true"] = "value",
  ["false"] = "value",
  ["nil"] = "value",

  ["buffer"] = "builtin",
  ["thread"] = "builtin",
  ["table"] = "builtin",
  ["userdata"] = "builtin",
  ["Axes"] = "builtin",
  ["BrickColor"] = "builtin",
  ["CatalogSearchParams"] = "builtin",
  ["CFrame"] = "builtin",
  ["Color3"] = "builtin",
  ["ColorSequence"] = "builtin",
  ["ColorSequenceKeypoint"] = "builtin",
  ["Content"] = "builtin",
  ["DateTime"] = "builtin",
  ["DockWidgetPluginGuiInfo"] = "builtin",
  ["Faces"] = "builtin",
  ["FloatCurveKey"] = "builtin",
  ["Font"] = "builtin",
  ["Instance"] = "builtin",
  ["NumberRange"] = "builtin",
  ["NumberSequence"] = "builtin",
  ["NumberSequenceKeypoint"] = "builtin",
  ["OverlapParams"] = "builtin",
  ["Path2DControlPoint"] = "builtin",
  ["PathWaypoint"] = "builtin",
  ["PhysicalProperties"] = "builtin",
  ["Random"] = "builtin",
  ["Ray"] = "builtin",
  ["RaycastParams"] = "builtin",
  ["RaycastResult"] = "builtin",
  ["RBXScriptConnection"] = "builtin",
  ["RBXScriptSignal"] = "builtin",
  ["Rect"] = "builtin",
  ["Region3"] = "builtin",
  ["Region3int16"] = "builtin",
  ["RotationCurveKey"] = "builtin",
  ["Secret"] = "builtin",
  ["SecurityCapabilities"] = "builtin",
  ["SharedTable"] = "builtin",
  ["TweenInfo"] = "builtin",
  ["UDim"] = "builtin",
  ["UDim2"] = "builtin",
  ["User"] = "builtin",
  ["ValueCurveKey"] = "builtin",
  ["Vector2"] = "builtin",
  ["Vector2int16"] = "builtin",
  ["Vector3"] = "builtin",
  ["Vector3int16"] = "builtin",
  ["vector"] = "builtin",
  ["_G"] = "builtin",
  ["_VERSION"] = "builtin",
  ["assert"] = "builtin",
  ["bit32"] = "builtin",
  ["collectgarbage"] = "builtin",
  ["coroutine"] = "builtin",
  ["debug"] = "builtin",
  ["delay"] = "builtin",
  ["elapsedTime"] = "builtin",
  ["Enum"] = "builtin",
  ["error"] = "builtin",
  ["game"] = "builtin",
  ["gcinfo"] = "builtin",
  ["getfenv"] = "builtin",
  ["getmetatable"] = "builtin",
  ["ipairs"] = "builtin",
  ["loadstring"] = "builtin",
  ["math"] = "builtin",
  ["newproxy"] = "builtin",
  ["next"] = "builtin",
  ["os"] = "builtin",
  ["pairs"] = "builtin",
  ["pcall"] = "builtin",
  ["plugin"] = "builtin",
  ["PluginManager"] = "builtin",
  ["print"] = "builtin",
  ["printidentity"] = "builtin",
  ["rawequal"] = "builtin",
  ["rawget"] = "builtin",
  ["rawlen"] = "builtin",
  ["rawset"] = "builtin",
  ["require"] = "builtin",
  ["select"] = "builtin",
  ["setfenv"] = "builtin",
  ["setmetatable"] = "builtin",
  ["settings"] = "builtin",
  ["shared"] = "builtin",
  ["script"] = "builtin",
  ["spawn"] = "builtin",
  ["stats"] = "builtin",
  ["task"] = "builtin",
  ["tick"] = "builtin",
  ["time"] = "builtin",
  ["tonumber"] = "builtin",
  ["tostring"] = "builtin",
  ["unpack"] = "builtin",
  ["UserSettings"] = "builtin",
  ["utf8"] = "builtin",
  ["version"] = "builtin",
  ["wait"] = "builtin",
  ["warn"] = "builtin",
  ["workspace"] = "builtin",
  ["EnumItem"] = "builtin",
  ["Enums"] = "builtin",
  ["xpcall"] = "builtin",
  ["ypcall"] = "builtin",

  ["appendfile"] = "builtin",
  ["base64"] = "builtin",
  ["base64decode"] = "builtin",
  ["base64encode"] = "builtin",
  ["bit"] = "builtin",
  ["cache"] = "builtin",
  ["cacheinvalidate"] = "builtin",
  ["cachereplace"] = "builtin",
  ["checkcaller"] = "builtin",
  ["checkcclosure"] = "builtin",
  ["checkclosure"] = "builtin",
  ["checklclosure"] = "builtin",
  ["cleardrawings"] = "builtin",
  ["cleardrawcache"] = "builtin",
  ["clonefunction"] = "builtin",
  ["cloneinstance"] = "builtin",
  ["clonemanager"] = "builtin",
  ["cloneref"] = "builtin",
  ["compareinstances"] = "builtin",
  ["createsecurefunction"] = "builtin",
  ["crypt"] = "builtin",
  ["encrypt"] = "builtin",
  ["decrypt"] = "builtin",
  ["hash"] = "builtin",
  ["generatebytes"] = "builtin",
  ["generatekey"] = "builtin",
  ["decompile"] = "builtin",
  ["delfile"] = "builtin",
  ["delfolder"] = "builtin",
  ["disassemble"] = "builtin",
  ["Drawing"] = "builtin",
  ["filtergc"] = "builtin",
  ["fireclickdetector"] = "builtin",
  ["fireproximityprompt"] = "builtin",
  ["fireproximityhandler"] = "builtin",
  ["firesignal"] = "builtin",
  ["firetouchinterest"] = "builtin",
  ["firetouchhandler"] = "builtin",
  ["getactor"] = "builtin",
  ["getactors"] = "builtin",
  ["getluastate"] = "builtin",
  ["getgamestate"] = "builtin",
  ["getallactors"] = "builtin",
  ["getscriptthread"] = "builtin",
  ["getcallbackvalue"] = "builtin",
  ["getcallbackmember"] = "builtin",
  ["getcallingclosure"] = "builtin",
  ["getcallingscript"] = "builtin",
  ["getclipboard"] = "builtin",
  ["getconnections"] = "builtin",
  ["getconstant"] = "builtin",
  ["getconstants"] = "builtin",
  ["getcustomasset"] = "builtin",
  ["getcustomassets"] = "builtin",
  ["getfpscap"] = "builtin",
  ["getgc"] = "builtin",
  ["getgenv"] = "builtin",
  ["gethiddenproperties"] = "builtin",
  ["gethiddenproperty"] = "builtin",
  ["gethui"] = "builtin",
  ["gethiddenui"] = "builtin",
  ["gethwid"] = "builtin",
  ["getidentity"] = "builtin",
  ["getinstances"] = "builtin",
  ["getloadedmodules"] = "builtin",
  ["getmenv"] = "builtin",
  ["getnamecallmethod"] = "builtin",
  ["getnilinstances"] = "builtin",
  ["getproto"] = "builtin",
  ["getprotos"] = "builtin",
  ["getrawmetatable"] = "builtin",
  ["getreg"] = "builtin",
  ["getregistry"] = "builtin",
  ["getrenderproperty"] = "builtin",
  ["getrenv"] = "builtin",
  ["getrenvbuiltin"] = "builtin",
  ["getrenvshared"] = "builtin",
  ["getrunningscripts"] = "builtin",
  ["getscriptbytecode"] = "builtin",
  ["getscriptclosure"] = "builtin",
  ["getscripthash"] = "builtin",
  ["getscripts"] = "builtin",
  ["getsenv"] = "builtin",
  ["getsimulationradius"] = "builtin",
  ["getspecialinfo"] = "builtin",
  ["getstack"] = "builtin",
  ["getsynasset"] = "builtin",
  ["gettenv"] = "builtin",
  ["getthreadcontext"] = "builtin",
  ["getthreadidentity"] = "builtin",
  ["getupvalue"] = "builtin",
  ["getupvalues"] = "builtin",
  ["hookfunction"] = "builtin",
  ["hookmetamethod"] = "builtin",
  ["hooksignal"] = "builtin",
  ["hookconnection"] = "builtin",
  ["http"] = "builtin",
  ["http_request"] = "builtin",
  ["identifyexecutor"] = "builtin",
  ["iscclosure"] = "builtin",
  ["isexecutorclosure"] = "builtin",
  ["is_synapse_function"] = "builtin",
  ["isfile"] = "builtin",
  ["isfolder"] = "builtin",
  ["isgameactive"] = "builtin",
  ["islclosure"] = "builtin",
  ["isourclosure"] = "builtin",
  ["isrbxactive"] = "builtin",
  ["isreadonly"] = "builtin",
  ["isrenderobj"] = "builtin",
  ["isscriptable"] = "builtin",
  ["iswindowactive"] = "builtin",
  ["isclosure"] = "builtin",
  ["isnetworkowner"] = "builtin",
  ["keyclick"] = "builtin",
  ["keypress"] = "builtin",
  ["keyrelease"] = "builtin",
  ["listfiles"] = "builtin",
  ["loadfile"] = "builtin",
  ["lz4"] = "builtin",
  ["lz4compress"] = "builtin",
  ["lz4decompress"] = "builtin",
  ["makefolder"] = "builtin",
  ["make_readonly"] = "builtin",
  ["make_writeable"] = "builtin",
  ["messagebox"] = "builtin",
  ["mouse1click"] = "builtin",
  ["mouse1press"] = "builtin",
  ["mouse1release"] = "builtin",
  ["mouse1down"] = "builtin",
  ["mouse1up"] = "builtin",
  ["mouse2click"] = "builtin",
  ["mouse2press"] = "builtin",
  ["mouse2release"] = "builtin",
  ["mouse2down"] = "builtin",
  ["mouse2up"] = "builtin",
  ["mousemoveabs"] = "builtin",
  ["mousemoverel"] = "builtin",
  ["mousescroll"] = "builtin",
  ["newcclosure"] = "builtin",
  ["newlclosure"] = "builtin",
  ["protectgui"] = "builtin",
  ["unprotectgui"] = "builtin",
  ["queueonteleport"] = "builtin",
  ["rconsoleclear"] = "builtin",
  ["rconsoleclose"] = "builtin",
  ["rconsoleerr"] = "builtin",
  ["rconsolehide"] = "builtin",
  ["rconsoleinfo"] = "builtin",
  ["rconsoleinput"] = "builtin",
  ["rconsolename"] = "builtin",
  ["rconsoleprint"] = "builtin",
  ["rconsolesettitle"] = "builtin",
  ["rconsoleshow"] = "builtin",
  ["rconsolewarn"] = "builtin",
  ["readfile"] = "builtin",
  ["replicatesignal"] = "builtin",
  ["request"] = "builtin",
  ["restorefunction"] = "builtin",
  ["runonactor"] = "builtin",
  ["runsecurefunction"] = "builtin",
  ["securecall"] = "builtin",
  ["saveinstance"] = "builtin",
  ["saveplace"] = "builtin",
  ["setclipboard"] = "builtin",
  ["setconstant"] = "builtin",
  ["setfpscap"] = "builtin",
  ["setgenv"] = "builtin",
  ["sethiddenproperties"] = "builtin",
  ["sethiddenproperty"] = "builtin",
  ["setidentity"] = "builtin",
  ["setnamecallmethod"] = "builtin",
  ["setproto"] = "builtin",
  ["setrawmetatable"] = "builtin",
  ["setreadonly"] = "builtin",
  ["setrenderproperty"] = "builtin",
  ["setscriptable"] = "builtin",
  ["setsimulationradius"] = "builtin",
  ["setstack"] = "builtin",
  ["setthreadcontext"] = "builtin",
  ["setthreadidentity"] = "builtin",
  ["setupvalue"] = "builtin",
  ["toclipboard"] = "builtin",
  ["WebSocket"] = "builtin",
  ["writeclipboard"] = "builtin",
  ["writefile"] = "builtin",
  ["getexecutorversion"] = "builtin",
  ["getinfo"] = "builtin",
  ["dumpstring"] = "builtin",
  ["getexecutorname"] = "builtin",
  ["setrbxclipboard"] = "builtin",
  ["iskeydown"] = "builtin",
  ["iskeypressed"] = "builtin",
  ["isleftmousedown"] = "builtin",
  ["isrightmousedown"] = "builtin",
  ["getfflag"] = "builtin",
  ["setfflag"] = "builtin",
  ["getthread"] = "builtin",
  ["getthreadid"] = "builtin",
  ["setthread"] = "builtin",
  ["setthreadid"] = "builtin",
  ["getpointerfrominstance"] = "builtin",
  ["getscriptfromthread"] = "builtin",
  ["VirtualUser"] = "builtin",
  ["VirtualInputManager"] = "builtin",
  ["consoleprint"] = "builtin",
  ["consoleclear"] = "builtin",
  ["consolesettitle"] = "builtin",
  ["consolecreate"] = "builtin",
  ["consoledestroy"] = "builtin",
  ["printconsole"] = "builtin",
  ["HttpGet"] = "builtin",
  ["HttpPost"] = "builtin",
  ["DeltaConnection"] = "builtin",
  ["ActorProxy"] = "builtin",
  ["ProtoProxy"] = "builtin",
  ["StopWatch"] = "builtin",
  ["Duration"] = "builtin",
  ["Regex"] = "builtin",
  ["LuaStateProxy"] = "builtin",
  ["getfunctionhash"] = "builtin",
  ["getfunctionbytecode"] = "builtin",
  ["dumpbytecode"] = "builtin",
  ["zstdcompress"] = "builtin",
  ["zstddecompress"] = "builtin",
  ["setupvalues"] = "builtin",
  ["detour_function"] = "builtin",
  ["hookmeta"] = "builtin",
  ["dofile"] = "builtin",
  ["isfunctionhooked"] = "builtin",
  ["getgamedata"] = "builtin",
 }
}

const B = {
 MINUS = 45,
 DOT = 46,
 Dqt = 34,
 Sqt = 39,
 BACKTICK = 96,
 LBRACKET = 91,
 RBRACKET = 93,
 EQUALS = 61,
 NEWLINE = 10,
 CR = 13,
 LPAREN = 40,
 RPAREN = 41,
 SEMICOLON = 59,
 LBRACE = 123,
 ZERO = 48,
 ONE = 49,
 NINE = 57,
 UNDERSCORE = 95,
 LETTER_A_UPPER = 65,
 LETTER_Z_UPPER = 90,
 LETTER_A_LOWER = 97,
 LETTER_Z_LOWER = 122,
 BACKSLASH = 92,
 SPACE = 32,
 TAB = 9,
 PLUS = 43,
 LETTER_E_UPPER = 69,
 LETTER_E_LOWER = 101,
 LETTER_P_UPPER = 80,
 LETTER_P_LOWER = 112,
 LETTER_X_UPPER = 88,
 LETTER_X_LOWER = 120,
 LETTER_B_UPPER = 66,
 LETTER_B_LOWER = 98,
 LETTER_F_UPPER = 70,
 LETTER_F_LOWER = 102,
}

const s_byte = string.byte
const s_sub = string.sub
const s_find = string.find
const s_rep = string.rep

const function TypeAlpha(b: number?): boolean
 if not b then return false end
 return (b >= B.LETTER_A_UPPER and b <= B.LETTER_Z_UPPER)
  or (b >= B.LETTER_A_LOWER and b <= B.LETTER_Z_LOWER)
  or b == B.UNDERSCORE
end

const function TypeAlnum(b: number?): boolean
 if not b then return false end
 return TypeAlpha(b) or (b >= B.ZERO and b <= B.NINE)
end

const function TypeDigit(b: number?): boolean
 if not b then return false end
 return b >= B.ZERO and b <= B.NINE
end

const function TypeHexDigit(b: number?): boolean
 if not b then return false end
 return (b >= B.ZERO and b <= B.NINE)
  or (b >= B.LETTER_A_UPPER and b <= B.LETTER_F_UPPER)
  or (b >= B.LETTER_A_LOWER and b <= B.LETTER_F_LOWER)
end

const function TypeDigitSep(b: number?): boolean
 if not b then return false end
 return TypeDigit(b) or b == B.UNDERSCORE
end

const function TypeHexDigitSep(b: number?): boolean
 if not b then return false end
 return TypeHexDigit(b) or b == B.UNDERSCORE
end

const function IsWhitespaceString(txt: string): boolean
 const len: number = #txt
 for idx = 1, len do
  const cb: number? = s_byte(txt, idx)
  if cb ~= B.SPACE and cb ~= B.TAB and cb ~= B.NEWLINE and cb ~= B.CR then
   return false
  end
 end
 return true
end

const function BracketCloseTarget(lvl: number): string
 if lvl == 0 then
  return "]]"
 end
 return "]" .. s_rep("=", lvl) .. "]"
end

const function ParseBracket(txt: string, pos: number, len: number): (number?, number)
 if s_byte(txt, pos) ~= B.LBRACKET then return nil, pos end
 pos = pos + 1
 local lvl: number = 0
 while pos <= len and s_byte(txt, pos) == B.EQUALS do
  lvl = lvl + 1
  pos = pos + 1
 end
 if pos <= len and s_byte(txt, pos) == B.LBRACKET then
  return lvl, pos + 1
 end
 return nil, pos
end

const function FindBracket(txt: string, pos: number?, len: number, lvl: number): number?
 const trt: string = BracketCloseTarget(lvl)
 const cix: number? = s_find(txt, trt, pos, true)
 if cix then
  return cix + #trt
 end
 return nil
end

export type Token = {
 type: string,
 value: string
}

const function IsAnnotationType(t: {Token}, n: number, txt: string, pos: number, len: number): boolean
 const prev: Token? = t[n]
 if not prev or prev.type ~= "plain" or not s_find(prev.value, ":%s*$") then
  return false
 end
 local j: number = pos
 while j <= len do
  const sb: number? = s_byte(txt, j)
  if sb ~= B.SPACE and sb ~= B.TAB then break end
  j = j + 1
 end
 const nb: number? = s_byte(txt, j)
 if nb == B.LPAREN or nb == B.LBRACE or nb == B.Dqt or nb == B.Sqt or nb == B.BACKTICK then
  return false
 end
 return true
end

function Highlighter.Tokenize(txt: string?, cc: boolean?, cl: number?, cs: boolean?, csl: number?): ({Token}, boolean, number, boolean, number)
 const stxt: string = txt or ""

 const t: {Token} = {}
 local n: number = 0
 local i: number = 1
 const len: number = #stxt
 local ec: boolean = false
 local es: boolean = false
 local cml: number = cl or 0
 local sl: number = csl or 0
 local ad: boolean = false
 local adg: boolean = false
 local fnPending: boolean = false
 local pDepth: number = 0
 local retType: boolean = false

 if cc then
  const trt: string = BracketCloseTarget(cml)
  const cix: number? = s_find(stxt, trt, 1, true)
  if cix then
   n = n + 1
   t[n] = {type = "comment", value = s_sub(stxt, 1, cix + #trt - 1)}
   i = cix + #trt
  else
   if len > 0 then
    n = n + 1
    t[n] = {type = "comment", value = stxt}
   end
   return t, true, cml, false, 0
  end
 elseif cs then
  const trt: string = BracketCloseTarget(sl)
  const cix: number? = s_find(stxt, trt, 1, true)
  if cix then
   n = n + 1
   t[n] = {type = "string", value = s_sub(stxt, 1, cix + #trt - 1)}
   i = cix + #trt
  else
   if len > 0 then
    n = n + 1
    t[n] = {type = "string", value = stxt}
   end
   return t, false, 0, true, sl
  end
 end

 while i <= len do
  const b: number = s_byte(stxt, i)

  if b == B.MINUS and s_byte(stxt, i + 1) == B.MINUS then
   const st: number = i
   i = i + 2
   retType = false
   const nb: number? = s_byte(stxt, i)
   if nb == B.LBRACKET then
    const lvl: number?, np: number = ParseBracket(stxt, i, len)
    if lvl then
     i = np
     const ep: number? = FindBracket(stxt, i, len, lvl)
     if ep then
      i = ep
      n = n + 1
      t[n] = {type = "comment", value = s_sub(stxt, st, i - 1)}
     else
      n = n + 1
      t[n] = {type = "comment", value = s_sub(stxt, st)}
      ec = true
      cml = lvl
      break
     end
     continue
    end
   end
   retType = false
   local le: number = i
   while le <= len and s_byte(stxt, le) ~= B.NEWLINE do
    le = le + 1
   end
   n = n + 1
   t[n] = {type = "comment", value = s_sub(stxt, st, le - 1)}
   i = le
   continue
  end

  if b == B.LBRACKET then
   const lvl: number?, np: number = ParseBracket(stxt, i, len)
   if lvl then
    retType = false
    const ep: number? = FindBracket(stxt, np, len, lvl)
    if ep then
     n = n + 1
     t[n] = {type = "string", value = s_sub(stxt, i, ep - 1)}
     i = ep
    else
     n = n + 1
     t[n] = {type = "string", value = s_sub(stxt, i)}
     es = true
     sl = lvl
     break
    end
    ad = false
    adg = false
    continue
   end
  end

  if b == B.Dqt or b == B.Sqt or b == B.BACKTICK then
   const qt: number = b
   const st: number = i
   retType = false
   i = i + 1
   while i <= len do
    const cb: number? = s_byte(stxt, i)
    if cb == qt then
     i = i + 1
     break
    end
    if cb == B.NEWLINE or cb == B.CR then
     break
    end
    if cb == B.BACKSLASH then
     i = i + 1
    end
    i = i + 1
   end
   n = n + 1
   t[n] = {type = "string", value = s_sub(stxt, st, i - 1)}
   ad = false
   adg = false
   continue
  end

  if TypeAlpha(b) then
   const st: number = i
   i = i + 1
   while i <= len and TypeAlnum(s_byte(stxt, i)) do
    i = i + 1
   end
   const wrd: string = s_sub(stxt, st, i - 1)
   const wtyp: string? = Highlighter.TokenTypes[wrd]
   if wtyp == "keyword" then
    retType = false
    if wrd == "function" and pDepth == 0 then
     fnPending = true
    end
   end
   const isAnnotType: boolean = (wrd == "thread" or wrd == "userdata")
    and IsAnnotationType(t, n, stxt, i, len)
   if retType and (wtyp ~= "value" or wrd == "nil") then
    n = n + 1
    t[n] = {type = "property", value = wrd}
   elseif isAnnotType then
    n = n + 1
    t[n] = {type = "builtin", value = wrd}
   elseif adg then
    n = n + 1
    t[n] = {type = "builtin", value = wrd}
   elseif ad then
    n = n + 1
    t[n] = {type = "property", value = wrd}
   else
    const typ: string = Highlighter.TokenTypes[wrd]
    if typ then
     n = n + 1
     t[n] = {type = typ, value = wrd}
    else
     local j: number = i
     while j <= len do
      const sb: number? = s_byte(stxt, j)
      if sb ~= B.SPACE and sb ~= B.TAB and sb ~= B.NEWLINE and sb ~= B.CR then break end
      j = j + 1
     end
     if j <= len then
      const sb: number? = s_byte(stxt, j)
      if sb == B.LPAREN or sb == B.LBRACE or sb == B.Dqt or sb == B.Sqt or sb == B.BACKTICK then
       n = n + 1
       t[n] = {type = "method", value = wrd}
      elseif sb == B.LBRACKET then
       const lvl: number? = ParseBracket(stxt, j, len)
       if lvl then
        n = n + 1
        t[n] = {type = "method", value = wrd}
       else
        n = n + 1
        t[n] = {type = "identifier", value = wrd}
       end
      else
       n = n + 1
       t[n] = {type = "identifier", value = wrd}
      end
     else
      n = n + 1
      t[n] = {type = "identifier", value = wrd}
     end
    end
   end
   ad = false
   adg = false
   continue
  end

  const nb: number? = s_byte(stxt, i + 1)
  if TypeDigit(b) or (b == B.DOT and TypeDigit(nb) and s_byte(stxt, i + 2) ~= B.DOT) then
   const st: number = i
   retType = false
   if b == B.ZERO and (nb == B.LETTER_X_LOWER or nb == B.LETTER_X_UPPER) then
    i = i + 2
    local hdt: boolean = false
    while i <= len do
     const cb: number? = s_byte(stxt, i)
     if TypeHexDigitSep(cb) then
      i = i + 1
     elseif cb == B.DOT and not hdt and s_byte(stxt, i + 1) ~= B.DOT then
      hdt = true
      i = i + 1
     else
      break
     end
    end
    const eb: number? = s_byte(stxt, i)
    if eb == B.LETTER_P_LOWER or eb == B.LETTER_P_UPPER then
     local expPos: number = i + 1
     const nextB: number? = s_byte(stxt, expPos)
     if nextB == B.PLUS or nextB == B.MINUS then
      expPos = expPos + 1
     end
     if TypeDigit(s_byte(stxt, expPos)) then
      i = expPos
      while i <= len and TypeDigitSep(s_byte(stxt, i)) do
       i = i + 1
      end
     end
    end
   elseif b == B.ZERO and (nb == B.LETTER_B_LOWER or nb == B.LETTER_B_UPPER) then
    i = i + 2
    while i <= len do
     const cb: number? = s_byte(stxt, i)
     if cb == B.ZERO or cb == B.ONE or cb == B.UNDERSCORE then
      i = i + 1
     else
      break
     end
    end
   else
    local hdt: boolean = false
    if b == B.DOT then
     hdt = true
     i = i + 1
    end
    while i <= len do
     const cb: number? = s_byte(stxt, i)
     if TypeDigitSep(cb) then
      i = i + 1
     elseif cb == B.DOT and not hdt and s_byte(stxt, i + 1) ~= B.DOT then
      hdt = true
      i = i + 1
     else
      break
     end
    end
    const eb: number? = s_byte(stxt, i)
    if eb == B.LETTER_E_LOWER or eb == B.LETTER_E_UPPER then
     local expPos: number = i + 1
     const nextB: number? = s_byte(stxt, expPos)
     if nextB == B.PLUS or nextB == B.MINUS then
      expPos = expPos + 1
     end
     if TypeDigit(s_byte(stxt, expPos)) then
      i = expPos
      while i <= len and TypeDigitSep(s_byte(stxt, i)) do
       i = i + 1
      end
     end
    end
   end
   n = n + 1
   t[n] = {type = "value", value = s_sub(stxt, st, i - 1)}
   ad = false
   adg = false
   continue
  end

  if b == B.DOT then
   const st: number = i
   i = i + 1
   while i <= len and s_byte(stxt, i) == B.DOT do
    i = i + 1
   end
   const val: string = s_sub(stxt, st, i - 1)
   n = n + 1
   t[n] = {type = "plain", value = val}
   if #val == 1 then
    const prev: Token? = t[n - 1]
    ad = not (prev and prev.type == "builtin")
    adg = not ad
   else
    ad = false
    adg = false
   end
   continue
  end

  const st: number = i
  i = i + 1
  while i <= len do
   const cb: number? = s_byte(stxt, i)
   if cb == B.MINUS and s_byte(stxt, i + 1) == B.MINUS then break end
   if cb == B.LBRACKET or cb == B.Dqt or cb == B.Sqt or cb == B.BACKTICK
    or cb == B.DOT or TypeAlpha(cb) or TypeDigit(cb) then
    break
   end
   i = i + 1
  end
  const val: string = s_sub(stxt, st, i - 1)
  n = n + 1
  t[n] = {type = "plain", value = val}
  for k = 1, #val do
   const c: number = s_byte(val, k)
   if retType and (c == B.NEWLINE or c == B.EQUALS or c == B.SEMICOLON) then
    retType = false
   end
   if pDepth > 0 then
    if c == B.LPAREN then
     pDepth = pDepth + 1
    elseif c == B.RPAREN then
     pDepth = pDepth - 1
     if pDepth == 0 and s_find(val, "^[ \t]*:", k + 1) then
      retType = true
     end
    end
   elseif fnPending and c == B.LPAREN then
    fnPending = false
    pDepth = 1
   end
  end
  if not IsWhitespaceString(val) then
   ad = false
   adg = false
  end
 end

 return t, ec, cml, es, sl
end

const INDENT_OPEN: {[string]: boolean} = {
 ["function"] = true,
 ["then"] = true,
 ["do"] = true,
 ["repeat"] = true,
}
const INDENT_CLOSE: {[string]: boolean} = {
 ["end"] = true,
 ["until"] = true,
}
const DEDENT_FIRST: {[string]: boolean} = {
 ["end"] = true,
 ["until"] = true,
 ["else"] = true,
 ["elseif"] = true,
}

function Highlighter.Indent(txt: string?, indentSize: number?): string
 const stxt: string = txt or ""
 const size: number = indentSize or 4
 const unit: string = string.rep(" ", size)

 const lines: {string} = string.split(stxt, "\n")
 const out: {string} = {}

 local level: number = 0
 local cc, cl, cs, csl = false, 0, false, 0

 for idx, line in lines do
  const enteringOpenBlock: boolean = cc or cs

  const tokens, nec, ncl, nes, ncsl = Highlighter.Tokenize(line, cc, cl, cs, csl)
  cc, cl, cs, csl = nec, ncl, nes, ncsl

  if enteringOpenBlock then
   out[idx] = line
   continue
  end

  local firstWord: string? = nil
  for _, tok in tokens do
   if tok.type == "keyword" then
    firstWord = tok.value
    break
   elseif tok.type == "comment" then
    continue
   elseif tok.type == "plain" and IsWhitespaceString(tok.value) then
    continue
   else
    if tok.type == "plain" and tok.value == "}" then
     firstWord = "}"
    end
    break
   end
  end

  const isDedentFirst: boolean = DEDENT_FIRST[firstWord or ""] == true or firstWord == "}"
  const printLevel: number = isDedentFirst and math.max(level - 1, 0) or level

  local skipFirstThen: boolean = (firstWord == "else" or firstWord == "elseif")
  local delta: number = 0
  for _, tok in tokens do
   if tok.type == "keyword" then
    if tok.value == "then" and skipFirstThen then
     skipFirstThen = false
    elseif INDENT_OPEN[tok.value] then
     delta = delta + 1
    elseif INDENT_CLOSE[tok.value] then
     delta = delta - 1
    end
   elseif tok.type == "plain" then
    if tok.value == "{" then
     delta = delta + 1
    elseif tok.value == "}" then
     delta = delta - 1
    end
   end
  end
  level = math.max(level + delta, 0)

  const trimmed: string = line:match("^%s*(.-)%s*$") or ""
  out[idx] = trimmed == "" and "" or (unit:rep(printLevel) .. trimmed)
 end

 return table.concat(out, "\n")
end

const function EscapeRichText(s: string): string
 s = s:gsub("&", "&amp;")
 s = s:gsub("<", "&lt;")
 s = s:gsub(">", "&gt;")
 s = s:gsub("\"", "&quot;")
 s = s:gsub("'", "&apos;")
 return s
end

function Highlighter.Render(txt: string?): string
 const tokens: {Token} = Highlighter.Tokenize(txt)
 const parts: {string} = {}
 for i, tok in tokens do
  const color: string = Highlighter.SyntaxColors[tok.type] or Highlighter.SyntaxColors.plain
  parts[i] = `<font color="{color}">{EscapeRichText(tok.value)}</font>`
 end
 return table.concat(parts)
end

return Highlighter
