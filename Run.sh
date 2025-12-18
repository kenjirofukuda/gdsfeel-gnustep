#!/usr/bin/env bash
(cd GdsFeelCore; bear -- make  && make install messages=yes GNUSTEP_INSTALLATION_DOMAIN=USER)
bear -- make && openapp ./GdsFeel $*
