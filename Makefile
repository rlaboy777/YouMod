# Original Makefile from YTLite
FINALPACKAGE = 1
ARCHS = arm64
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouMod
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Photos AVFoundation Security SystemConfiguration
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FILES = $(wildcard Files/*.x)

# FFmpegKit stuff
FFMPEGKIT_FRAMEWORK_DIR ?= Files/FFmpegKit/Frameworks
FFMPEGKIT_FRAMEWORKS = ffmpegkit libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale

ifneq ($(wildcard $(FFMPEGKIT_FRAMEWORK_DIR)/ffmpegkit.framework/ffmpegkit),)
$(TWEAK_NAME)_FRAMEWORKS += AudioToolbox CoreMedia CoreVideo VideoToolbox
$(TWEAK_NAME)_LIBRARIES += bz2 iconv z c++
$(TWEAK_NAME)_LDFLAGS += -F$(FFMPEGKIT_FRAMEWORK_DIR)
$(TWEAK_NAME)_LDFLAGS += -Wl,-rpath,/Library/Frameworks -Wl,-rpath,@loader_path/Frameworks -Wl,-rpath,@executable_path/Frameworks
$(TWEAK_NAME)_LDFLAGS += $(foreach framework,$(FFMPEGKIT_FRAMEWORKS),-framework $(framework))

after-stage::
	mkdir -p "$(THEOS_STAGING_DIR)/Library/Application Support/YouMod.bundle/Frameworks"
	rsync -a "$(FFMPEGKIT_FRAMEWORK_DIR)/" "$(THEOS_STAGING_DIR)/Library/Application Support/YouMod.bundle/Frameworks/"
endif

include $(THEOS_MAKE_PATH)/tweak.mk
