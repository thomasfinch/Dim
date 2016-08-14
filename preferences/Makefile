ARCHS = armv7 arm64
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Dim
Dim_FILES = Dim.mm
Dim_INSTALL_PATH = /Library/PreferenceBundles
Dim_FRAMEWORKS = UIKit
Dim_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Dim.plist$(ECHO_END)
