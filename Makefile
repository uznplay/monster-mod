ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MonsterMod

MonsterMod_FILES = Tweak.xm
MonsterMod_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
