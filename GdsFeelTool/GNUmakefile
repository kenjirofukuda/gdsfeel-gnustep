include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = GdsFeelTool

${TOOL_NAME}_OBJC_FILES = source.m
${TOOL_NAME}_INCLUDE_DIRS = -I../
${TOOL_NAME}_LIB_DIRS = -L../GdsFeelCore/$(GNUSTEP_OBJ_DIR)
${TOOL_NAME}_TOOL_LIBS = -lGdsFeelCore

ifeq ($(FOUNDATION_LIB),apple)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif
include $(GNUSTEP_MAKEFILES)/tool.make
