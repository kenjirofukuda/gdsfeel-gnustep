include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECTS = \
  GdsFeelCore 


include $(GNUSTEP_MAKEFILES)/aggregate.make

APP_NAME = GdsFeel

${APP_NAME}_OBJC_FILES = \
	AppDelegate.m \
	GdsStructureView.m \
	GdsElementDrawer.m \
	GdsLibraryDocument.m \
	main.m
${APP_NAME}_RESOURCE_FILES = \
	Window.gsmarkup \
	Menu-GNUstep.gsmarkup \
	Menu-OSX.gsmarkup
${APP_NAME}_LOCALIZED_RESOURCE_FILES = \
	Window.strings
${APP_NAME}_LANGUAGES = Italian

${APP_NAME}_LIB_DIRS = -L./GdsFeelCore/$(GNUSTEP_OBJ_DIR)
${APP_NAME}_TOOL_LIBS += -lGdsFeelCore
# ADDITIONAL_OBJCFLAGS += -Wl,-subsystem,console

ifeq ($(FOUNDATION_LIB),apple)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif

include $(GNUSTEP_MAKEFILES)/application.make
