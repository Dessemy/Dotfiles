/* See LICENSE file for copyright and license details. */
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>

#include "../slstatus.h"
#include "../util.h"

/* fmt: 'c'/'n' (caps/num) in desired order; '?' suffix hides the letter when off */
const char *
keyboard_indicators(const char *fmt)
{
	Display *dpy;
	XKeyboardState state;
	size_t fmtlen, i, n;
	int togglecase, isset;
	char key;

	if (!(dpy = XOpenDisplay(NULL))) {
		warn("XOpenDisplay: Failed to open display");
		return NULL;
	}
	XGetKeyboardControl(dpy, &state);
	XCloseDisplay(dpy);

	fmtlen = strnlen(fmt, 4);
	for (i = n = 0; i < fmtlen; i++) {
		key = tolower(fmt[i]);
		if (key != 'c' && key != 'n')
			continue;

		togglecase = (i + 1 >= fmtlen || fmt[i + 1] != '?');
		isset = (state.led_mask & (1 << (key == 'n')));

		if (togglecase)
			buf[n++] = isset ? toupper(key) : key;
		else if (isset)
			buf[n++] = fmt[i];
	}

	buf[n] = 0;
	return buf;
}
