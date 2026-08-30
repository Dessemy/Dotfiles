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
	{ run_command,   "%s",
	  "b=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null); "
	  "raw=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null); "
	  "case \"$raw\" in "
	  "Charging) s=Chg; sc=32;; "
	  "Full) s=Full; sc=32;; "
	  "Discharging) s=Dis; sc=33;; "
	  "'Not charging') s=Idle; sc=33;; "
	  "*) s=$raw; sc=33;; esac; "
	  "pc=32; [ \"$b\" -lt 60 ] 2>/dev/null && pc=33; [ \"$b\" -lt 20 ] 2>/dev/null && pc=31; "
	  "printf \"\033[37mBAT \033[%sm%s%%\033[0m \033[%sm(%s)\033[0m\" \"$pc\" \"$b\" \"$sc\" \"$s\"" },
	{ datetime,      "\033[37m   %s   \033[0m",                              "%a, %b %e   %I:%M:%S %p" },
};
