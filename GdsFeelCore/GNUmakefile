include $(GNUSTEP_MAKEFILES)/common.make

LIBRARY_NAME = GdsFeelCore
${LIBRARY_NAME}_OBJC_FILES = \
	NSArray+Points.m \
	NSArray+Elements.m \
	GdsArchiver.m \
	GdsStructure.m \
	GdsViewport.m \
	GdsLayer.m \
	GdsLibrary.m \
	GdsElement.m 

ifeq ($(FOUNDATION_LIB),apple)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif
include $(GNUSTEP_MAKEFILES)/library.make
