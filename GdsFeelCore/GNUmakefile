include $(GNUSTEP_MAKEFILES)/common.make

LIBRARY_NAME = GdsFeelCore
${LIBRARY_NAME}_OBJC_FILES = \
	NSArray+Points.m \
	NSArray+Elements.m \
	GdsArchiver.m \
	GdsStructure.m \
	GdsZipedStructure.m \
	GdsViewport.m \
	GdsLayer.m \
	GdsLayer+XML.m \
	GdsLibrary.m \
	GdsZipedLibrary.m \
	GdsInform.m \
	GdsElement.m \
	GdsElement+XML.m

# https://stackoverflow.com/questions/40766055/error-strdup-was-not-declared-in-this-scope
ADDITIONAL_CFLAGS += -std=gnu11
ADDITIONAL_OBJCFLAGS += -std=gnu11

ifeq ($(FOUNDATION_LIB),apple)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif
include $(GNUSTEP_MAKEFILES)/library.make
