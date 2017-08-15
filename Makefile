THEOS_DEVICE_IP = 20.20.49.26
ARCHS = arm64
TARGET = iphone:latest:9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TwitterSaveVideo
TwitterSaveVideo_FILES = Tweak.xm
TwitterSaveVideo_FILES += ./Headers/TwitterTweakTool.m
TwitterSaveVideo_FILES += ./Headers/YQAssetOperator.m

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Twitter"
