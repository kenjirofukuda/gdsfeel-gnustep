#!/usr/bin/env bash
(cd GdsFeelCore; make  && make install messages=yes GNUSTEP_INSTALLATION_DOMAIN=USER)
make && openapp ./GdsFeel $*
