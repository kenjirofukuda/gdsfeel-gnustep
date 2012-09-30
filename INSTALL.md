INSTALL
===============

GdsFeel currentry use Renaissance(User Interfece Object graph by XML) without ProjectCenter and Gorm.

but GSMarkupWindowController subclasses can't recive windowControllerWillLoadNib: message.

1. get Renaissance source code.
2. Apply patch from 
      <https://github.com/kenjirofukuda/gnustep-renaissance/compare/myProblemSpike>
      or all source code as git hub zip download.
3. build Renaissance

    cd {Renaissance source path}
    make 
    sudo make -E GNUSTEP_MAKEFILES="$GNUSTEP_MAKEFILES" PATH="$PATH"

4. build and run GdsFeel

    cd gdsfeel-gnustep/
    exec ./Run.sh


