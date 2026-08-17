/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

/* see components/ for all available functions and their arguments */
static const struct arg args[] = {
	/* function          format          argument */
	{ battery_perc,        "BAT %s%%",             "BAT0" },
	{ battery_state,       " (%s)",                "BAT0" },
	{ run_command,         " | VOL %s%%",          "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '/MUTED/{print 0; exit} {v=$2*100; if (v>100) v=100; if (v<0) v=0; printf \"%.0f\", v}'" },
	{ datetime,            "   %s   ",             "%a, %b %e   %I:%M:%S %p" },
};
