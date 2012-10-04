#!/bin/sh
SUDO=sudo
if [ "$GNUSTEP_HOST_OS" = "mingw32" ]; then
  SUDO=""
fi
(cd GdsFeelCore; make debug=yes && $SUDO make install GNUSTEP_MAKEFILES="$GNUSTEP_MAKEFILES" PATH="$PATH")
make debug=yes && debugapp --GNU-Debug=dflt ./GdsFeel $*
