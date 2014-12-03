ARCHS = armv7 armv7s arm64
TARGET =: clang
THEOS_PACKAGE_DIR_NAME = debs
THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

include theos/makefiles/common.mk

TWEAK_NAME = Dim
Dim_FILES = Tweak.xm DimWindow.m DimController.m
Dim_FRAMEWORKS = UIKit
Dim_PRIVATE_FRAMEWORKS = GraphicsServices
Dim_LIBRARIES = flipswitch activator

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += switch
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
