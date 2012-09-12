#!/bin/sh
SUDO=sudo
if [ "$GNUSTEP_HOST_OS" = "mingw32" ]; then
  SUDO=""
fi
(cd GdsFeelCore; make  && $SUDO make install GNUSTEP_MAKEFILES="$GNUSTEP_MAKEFILES" PATH="$PATH")
make && openapp ./GdsFeel $*
