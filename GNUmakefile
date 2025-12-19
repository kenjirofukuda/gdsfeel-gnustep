#
#  Author: Kenjiro Fukuda <kenjirofukuda@gmail.com>
#
ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

GNUSTEP_INSTALLATION_DOMAIN = USER

include $(GNUSTEP_MAKEFILES)/common.make

UNZIP_PATH := $(strip $(shell which unzip 2>/dev/null))
ifeq ($(UNZIP_PATH),)
require_unzip:
	@echo 
	@echo "*** ERROR *** unzip not found. GdsFeel require unzip command."
	@echo "  mingw-get install msys-unzip. if MSYS/MinGW environment. "
	@echo 
	exit 1
endif

ZIP_PATH := $(strip $(shell which zip 2>/dev/null))
ifeq ($(ZIP_PATH),)
require_zip:
	@echo 
	@echo "*** ERROR *** zip not found. GdsFeel require zip command."
	@echo "  mingw-get install msys-zip. if MSYS/MinGW environment. "
	@echo 
	exit 1
endif

SUBPROJECTS = \
  GdsFeelCore 

include $(GNUSTEP_MAKEFILES)/aggregate.make

APP_NAME = GdsFeel

${APP_NAME}_OBJC_FILES = \
	AppDelegate.m \
	GdsStructureView.m \
	GdsElement+Drawing.m \
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
