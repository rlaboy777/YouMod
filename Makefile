# Original Makefile from YTLite
DEBUG = 0
FINALPACKAGE = 1
ARCHS = arm64
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouMod
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FILES = Tweak.x Settings.x

include $(THEOS_MAKE_PATH)/tweak.mk