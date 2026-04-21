# Original Makefile from YTLite
ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME=rootless
else ifeq ($(ROOTHIDE),1)
THEOS_PACKAGE_SCHEME=roothide
endif

DEBUG = 0
FINALPACKAGE = 1
ARCHS = arm64
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouMod
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation SystemConfiguration
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FILES = $(wildcard *.x)

include $(THEOS_MAKE_PATH)/tweak.mk