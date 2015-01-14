ARCHS = armv7 armv7s arm64
THEOS_PACKAGE_DIR_NAME = debs
PACKAGE_VERSION = 1.3

include theos/makefiles/common.mk

TWEAK_NAME = Dim
Dim_FILES = Tweak.xm DimWindow.m DimController.m
Dim_FRAMEWORKS = UIKit
Dim_PRIVATE_FRAMEWORKS = GraphicsServices

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += switch
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
