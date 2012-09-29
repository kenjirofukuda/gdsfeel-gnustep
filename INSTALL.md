INSTALL
===============

GdsFeel icurrentry use Renaissance( User Interfece Object graph) without ProjectCenter and Gorm.

but GSMarkupWindowController subclasses can't recive windowControllerWillLoadNib: message.

1. Install Renaissance
2. Apply patch https://github.com/kenjirofukuda/gnustep-renaissance/compare/myProblemSpike
3. build Renaissance

 make 
 sudo make -E GNUSTEP_MAKEFILES="$GNUSTEP_MAKEFILES" PATH="$PATH"

