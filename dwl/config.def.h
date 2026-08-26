#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
static const int sloppyfocus               = 1;
static const int bypass_surface_visibility = 0;
static const int smartgaps                 = 0;
static int gaps                            = 1;
static const unsigned int gappx            = 3;
static const unsigned int borderpx         = 0;
static const unsigned int barborderpx      = 0;
static const int showbar                   = 1;
static const int topbar                    = 1;
static const char *fonts[]                 = {"FiraCode Nerd Font:style=Bold:size=16"};
static const float rootcolor[]             = COLOR(0x000000ff);

static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

static const uint32_t col_bg    = 0x1a1b26ff;
static const uint32_t col_fg    = 0xa9b1d6ff;
static const uint32_t col_red   = 0xf7768eff;
static const uint32_t col_grn   = 0x9ece6aff;
static const uint32_t col_ylw   = 0xe0af68ff;
static const uint32_t col_blu   = 0x7aa2f7ff;
static const uint32_t col_mag   = 0xad8ee6ff;
static const uint32_t col_cyn   = 0x0db9d7ff;
static const uint32_t col_brblk = 0x444b6aff;

static const uint32_t barcolors[16] = {
    col_bg,
    col_red,
    col_grn,
    col_ylw,
    col_blu,
    col_mag,
    col_cyn,
    col_fg,
    col_brblk,
    col_red,
    col_grn,
    col_ylw,
    col_blu,
    col_mag,
    col_cyn,
    0xffffffff
};


static uint32_t colors[][3] = {
    [SchemeNorm]  = { col_fg,   col_bg,  col_brblk },
    [SchemeSel]   = { col_blu,  col_bg,  col_mag   },
    [SchemeOcc]   = { col_blu,  col_bg,  col_blu   },
    [SchemeUrg]   = { 0,        0,       0x770000ff },
    [SchemeUnder] = { col_mag,  col_bg,  col_mag   },
    [SchemeBg]    = { col_bg,  col_bg,  col_bg   },
    [SchemeFloat] = { col_ylw,  col_bg,  col_ylw   },
    [SchemeMono]  = { col_grn,  col_bg,  col_grn   },
};

static char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static int log_level = WLR_ERROR;

static const Rule rules[] = {
    { "Gimp_EXAMPLE",     NULL,       0,            1,           -1 },
    { "firefox_EXAMPLE",  NULL,       1 << 8,       0,           -1 },
};

static const Layout layouts[] = {
    { "[]=",      tile },
    { "><>",      NULL },
    { "[M]",      monocle },
};

static const MonitorRule monrules[] = {
    { NULL,       0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
};

static const struct xkb_rule_names xkb_rules = {
    .options = NULL,
};

static const int repeat_rate = 35;
static const int repeat_delay = 200;

static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;

static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;

static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

#define WMENU_THEME "-i -N '#1a1b26ff' -n '#a9b1d6ff' -M '#ad8ee6ff' -m '#1a1b26ff' -S '#7aa2f7ff' -s '#1a1b26ff' -f 'FiraCode Nerd Font Medium 16'"

static const Key keys[] = {
	{ MODKEY,                              XKB_KEY_Return,         spawn,            {.v = (const char*[]){ "foot", NULL }} },
    { MODKEY,                              XKB_KEY_q,              spawn,            {.v = (const char*[]){ "qutebrowser", NULL }} },
    { MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_V,              spawn,            SHCMD("$HOME/.config/scripts/vpn") },
    { MODKEY,                              XKB_KEY_s,              spawn,            SHCMD("$HOME/.config/scripts/snip full") },
    { MODKEY|WLR_MODIFIER_CTRL,            XKB_KEY_s,              spawn,            SHCMD("$HOME/.config/scripts/snip area") },
	{ MODKEY|WLR_MODIFIER_CTRL,            XKB_KEY_h,              spawn,            SHCMD("foot -e htop") },
	{ MODKEY,                              XKB_KEY_d,              spawn,            SHCMD("$HOME/.config/scripts/launchr " WMENU_THEME) },
	{ MODKEY,                              XKB_KEY_v,              spawn,            SHCMD("c=$(cliphist list | wmenu " WMENU_THEME " -l 15 -p 'Clipboard>'); [ -n \"$c\" ] && printf '%s' \"$c\" | cliphist decode | wl-copy && notify-send 'Clipboard' 'Item copied'") },
	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_L,              spawn,            SHCMD("$HOME/.config/scripts/walls next") },
	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_H,              spawn,            SHCMD("$HOME/.config/scripts/walls prev") },
	{ MODKEY|WLR_MODIFIER_CTRL,            XKB_KEY_p,              spawn,            SHCMD("foot -e $HOME/.config/scripts/pwrmode " WMENU_THEME) },
	{ MODKEY,                              XKB_KEY_Escape,         spawn,            SHCMD("waylock -init-color 0x1a1b26 -input-color 0x7aa2f7 -input-alt-color 0xad8ee6 -fail-color 0xf7768e") },

	{ 0,                                   XKB_KEY_XF86MonBrightnessUp,   spawn,     SHCMD("brightnessctl set +5% && val=$(brightnessctl -m | cut -d, -f4 | tr -d %) && notify-send -a brightness -h string:x-canonical-private-synchronous:brightness -h int:value:$val -h string:bgcolor:'#e0af68' -h string:fgcolor:'#e0af68' -h string:frcolor:'#e0af68' -t 1500 ' ' ' '") },
	{ 0,                                   XKB_KEY_XF86MonBrightnessDown, spawn,     SHCMD("brightnessctl set 5%- && val=$(brightnessctl -m | cut -d, -f4 | tr -d %) && notify-send -a brightness -h string:x-canonical-private-synchronous:brightness -h int:value:$val -h string:bgcolor:'#e0af68' -h string:fgcolor:'#e0af68' -h string:frcolor:'#e0af68' -t 1500 ' ' ' '") },

	{ 0,                                   XKB_KEY_XF86AudioRaiseVolume,  spawn,     SHCMD("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ && vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf $2*100}' | cut -d. -f1) && notify-send -a volume -h string:x-canonical-private-synchronous:volume -h int:value:$vol -h string:bgcolor:'#7aa2f7' -h string:fgcolor:'#7aa2f7' -h string:frcolor:'#7aa2f7' -t 1500 ' ' ' '") },
	{ 0,                                   XKB_KEY_XF86AudioLowerVolume,  spawn,     SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf $2*100}' | cut -d. -f1) && notify-send -a volume -h string:x-canonical-private-synchronous:volume -h int:value:$vol -h string:bgcolor:'#7aa2f7' -h string:fgcolor:'#7aa2f7' -h string:frcolor:'#7aa2f7' -t 1500 ' ' ' '") },
	{ 0,                                   XKB_KEY_XF86AudioMute,         spawn,     SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && st=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo Muted || echo Unmuted) && notify-send -a volume -h string:x-canonical-private-synchronous:volume -t 1500 Volume $st") },
	{ 0,                                   XKB_KEY_XF86AudioMicMute,      spawn,     SHCMD("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && st=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo Muted || echo Unmuted) && notify-send -a mic -h string:x-canonical-private-synchronous:mic -t 1500 Microphone $st") },

	{ MODKEY,                              XKB_KEY_j,              focusstack,       {.i = +1} },
	{ MODKEY,                              XKB_KEY_k,              focusstack,       {.i = -1} },

	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_I,              incnmaster,       {.i = +1} },
	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_P,              incnmaster,       {.i = -1} },
	{ MODKEY,                              XKB_KEY_h,              setmfact,         {.f = -0.05f} },
	{ MODKEY,                              XKB_KEY_l,              setmfact,         {.f = +0.05f} },
	{ MODKEY,                              XKB_KEY_space,          cyclelayout,      {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_space,          togglefloating,   {0} },
	{ MODKEY,                              XKB_KEY_e,              togglefullscreen, {0} },
	{ MODKEY,                              XKB_KEY_u,              togglegaps,       {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_B,              togglebar,        {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_Return,         zoom,             {0} },

	{ MODKEY|WLR_MODIFIER_CTRL,            XKB_KEY_c,                killclient,       {0} },

	{ MODKEY,                              XKB_KEY_0,                view,             {.ui = ~0} },
	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_parenright,       tag,              {.ui = ~0} },
	{ MODKEY,                              XKB_KEY_comma,            focusmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                              XKB_KEY_period,           focusmon,         {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_less,             tagmon,           {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_greater,          tagmon,           {.i = WLR_DIRECTION_RIGHT} },
	TAGKEYS(                               XKB_KEY_1,                XKB_KEY_exclam,                     0),
	TAGKEYS(                               XKB_KEY_2,                XKB_KEY_at,                         1),
	TAGKEYS(                               XKB_KEY_3,                XKB_KEY_numbersign,                 2),
	TAGKEYS(                               XKB_KEY_4,                XKB_KEY_dollar,                     3),
	TAGKEYS(                               XKB_KEY_5,                XKB_KEY_percent,                    4),
	TAGKEYS(                               XKB_KEY_6,                XKB_KEY_asciicircum,                5),
	TAGKEYS(                               XKB_KEY_7,                XKB_KEY_ampersand,                  6),
	TAGKEYS(                               XKB_KEY_8,                XKB_KEY_asterisk,                   7),
	TAGKEYS(                               XKB_KEY_9,                XKB_KEY_parenleft,                  8),

	{ MODKEY|WLR_MODIFIER_SHIFT,           XKB_KEY_Q,                quit,           {0} },
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,  XKB_KEY_Terminate_Server, quit,           {0} },

#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
	{ ClkTitle,    0,      BTN_MIDDLE, zoom,           {0} },
	{ ClkStatus,   0,      BTN_MIDDLE, spawn,          {.v = (const char*[]){ "foot", NULL }} },
	{ ClkClient,   MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ ClkClient,   MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ ClkClient,   MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
	{ ClkTagBar,   0,      BTN_LEFT,   view,           {0} },
	{ ClkTagBar,   0,      BTN_RIGHT,  toggleview,     {0} },
	{ ClkTagBar,   MODKEY, BTN_LEFT,   tag,            {0} },
	{ ClkTagBar,   MODKEY, BTN_RIGHT,  toggletag,      {0} },
};
