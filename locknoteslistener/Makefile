TARGET := iphone:clang:latest:7.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockNotesListener

LockNotesListener_FILES = Listener.x
LockNotesListener_LIBRARIES = activator
LockNotesListener_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
