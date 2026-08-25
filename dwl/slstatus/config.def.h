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
	{ datetime,            "   %s   ",             "%a, %b %e   %I:%M:%S %p" },
};
