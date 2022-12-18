ARCHS = arm64 arm64e
TARGET = iphone:clang:13.3:11.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockNotes

LockNotes_FILES = $(wildcard *.xm */*.xm)
LockNotes_CFLAGS = -fobjc-arc
LockNotes_LIBRARIES = sparkcolourpicker

include $(THEOS_MAKE_PATH)/tweak.mk