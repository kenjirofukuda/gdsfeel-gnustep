#!/bin/sh
(cd GdsFeelCore; make debug=yes && make install messages=yes GNUSTEP_INSTALLATION_DOMAIN=USER)
make debug=yes && debugapp ./GdsFeel --GNU-Debug=GdsStructureView $*
