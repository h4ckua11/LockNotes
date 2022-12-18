ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockNotes
LockNotes_CFLAGS = -fobjc-arc

SUBPROJECTS += Prefs LockNotes locknoteslistener
include $(THEOS_MAKE_PATH)/aggregate.mk

before-stage::
	find . -name ".DS_Store" -type f -delete

#after-install::
#	install.exec "killall -9 SpringBoard"
