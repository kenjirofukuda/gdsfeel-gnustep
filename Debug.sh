#!/usr/bin/env bash
(cd GdsFeelCore; make debug=yes && make install messages=yes GNUSTEP_INSTALLATION_DOMAIN=USER)
make debug=yes && debugapp ./GdsFeel \
                           --GNU-Debug=Connect \
                           --GNU-Debug=_InformInspect $*
