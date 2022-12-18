ARCHS = arm64 arm64e
TARGET = iphone:clang:13.3:11.0

INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LockNotes

LockNotes_FILES =	$(wildcard *.m */*.m)
LockNotes_FRAMEWORKS = UIKit
LockNotes_PRIVATE_FRAMEWORKS = Preferences
LockNotes_INSTALL_PATH = /Library/PreferenceBundles
LockNotes_CFLAGS = -fobjc-arc
LockNotes_LIBRARIES = sparkcolourpicker

include $(THEOS_MAKE_PATH)/bundle.mk
