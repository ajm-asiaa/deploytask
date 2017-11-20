#!/bin/bash
#### Script to sign the CARTA Application
echo "App signing script is running"

newappname=Carta
if [ "$cartaversion" != "" ];then
	newappname=CARTA_$cartaversion
fi

### Get the certifcicates
echo "Step 1: Getting the certificates from GitHub"

curl -O -L https://raw.githubusercontent.com/CARTAvis/deploytask/master/signing/developer_ID_app.p12.enc
curl -O -L https://raw.githubusercontent.com/CARTAvis/deploytask/master/signing/AppleWWDRCA.cer

ls -sort ## to check the files

### Decrypt the certificates
echo "Step 2: Decypting the certificates"
openssl enc -aes-256-cbc -base64 -pass pass:$encryption_password -d -p -in developer_ID_app.p12.enc -out developer_ID_app.p12

ls -sort

### Create custom keychain
echo "Step 3: Creating custom keychain"

security list-keychains

security create-keychain -p $keychain_password acdc.carta.keychain
security default-keychain -s acdc.carta.keychain
security unlock-keychain -p $keychain_password acdc.carta.keychain
security set-keychain-settings -lut 3600 acdc.carta.keychain

security list-keychains

### Import Certificates
echo "Step 4: Importing keys"

security import AppleWWDRCA.cer -k acdc.carta.keychain -A
security import developer_ID_app.p12 -k acdc.carta.keychain -P $security_password -A
#security set-key-partition-list -S apple-tool:,apple: -s -k $keychain_password acdc.carta.keychain # if building in 10.12
security find-identity -v -p codesigning

### Do the codesign
echo "Step 5: Codesigning"
codesign -s "$id_key" /tmp/$newappname.app/Contents/MacOS/casarc
codesign -s "$id_key" /tmp/$newappname.app/Contents/MacOS/CARTA
codesign -s "$id_key" /tmp/$newappname.app/Contents/MacOS/setupcartavis.sh
codesign -s "$id_key" /tmp/$newappname.app/Contents/MacOS/carta.sh
codesign -s "$id_key" /tmp/$newappname.app/Contents/MacOS/sqldrivers/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/MacOS/platforms/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/MacOS/imageformats/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/qwt.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtConcurrent.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtCore.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtGui.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtMultimedia.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtMultimediaWidgets.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtNetwork.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtOpenGL.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtPositioning.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtPrintSupport.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtSensors.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtSql.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtSvg.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtWebKit.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtWebKitWidgets.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtWidgets.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtXml.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/QtTest.framework/Versions/*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/lib*
codesign -s "$id_key" /tmp/$newappname.app/Contents/Frameworks/.gitkeep
codesign -s "$id_key" /tmp/$newappname.app/Contents/Info.plist
codesign -s "$id_key" /tmp/$newappname.app/Contents/PkgInfo
codesign -s "$id_key" /tmp/$newappname.app

echo "Checking if codesign worked:"
codesign -dv --verbose=4 /tmp/$newappname.app # for checking it worked

echo "This is the end of the signing script"

