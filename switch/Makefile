ARCHS = armv7 armv7s arm64 arm64e
TARGET = iphone:10.2:10.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DimSwitch
DimSwitch_FILES = Switch.x
DimSwitch_FRAMEWORKS = UIKit
DimSwitch_LIBRARIES = flipswitch
DimSwitch_INSTALL_PATH = /Library/Switches

include $(THEOS)/makefiles/bundle.mk