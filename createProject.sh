#!/bin/bash #
# Create an Android Java App from the command line
#

# ----------------------------------------------
# Edit these values
# ----------------------------------------------
PROJECT_NAME=NewProject
PROJECT_DOMAIN_NAME="org.armstrong.ika"

# ----------------------------------------------
# Do not edit below this line
# ----------------------------------------------
clear
WORKING_DIR="$(pwd)"
PROJECT_DIR_NAME="${PROJECT_NAME,,}"
PROJECT_DIR="${WORKING_DIR}/${PROJECT_NAME}"
PROJECT_MAIN_DIR="${PROJECT_DIR}/app/src/main"
PROJECT_RES_DIR="${PROJECT_MAIN_DIR}/res"
PROJECT_VALUES_DIR="${PROJECT_RES_DIR}/values"
PROJECT_JAVA_DIR="${PROJECT_MAIN_DIR}/java"

PROJECT_PACKAGE_NAME="${PROJECT_DOMAIN_NAME}.${PROJECT_DIR_NAME}"

PROJECT_DOMAIN_NAME_LINK="${PROJECT_DOMAIN_NAME//./\/}"
PROJECT_APP_DIR="${PROJECT_JAVA_DIR}/${PROJECT_DOMAIN_NAME_LINK}/${PROJECT_DIR_NAME}"
PROJECT_APK_DEBUG_DIR="app/build/outputs/apk/debug"

# ----------------------------------------------
# make project dir
# ----------------------------------------------
if [ ! -d ${PROJECT_DIR} ] 
then
	mkdir ${PROJECT_DIR}
else
	echo "---------------------------------------"
	echo >&2 "${PROJECT_DIR} exists. Aborting."
	echo "---------------------------------------"
	exit 1
fi

# ----------------------------------------------
# change to project dir
# ----------------------------------------------
if [ -d ${PROJECT_DIR} ]
then
	cd ${PROJECT_DIR}
else
	echo "---------------------------------------"
	echo >&2 "${PROJECT_DIR} does not exist: Aborting."
	echo "---------------------------------------"
	exit 1
fi

# ----------------------------------------------
# build gradle
# ----------------------------------------------
gradle build

# ----------------------------------------------
# add gradle wrapper
# ----------------------------------------------
gradle wrapper

# ----------------------------------------------
# settings.gradle
# ----------------------------------------------
echo "include ':app'" >> settings.gradle

# ----------------------------------------------
# gradle.properties
# ----------------------------------------------
echo "org.gradle.jvmargs=-Xmx2048m
android.useAndroidX=true
android.enableJetifier=true" >> gradle.properties

# ----------------------------------------------
# build.gradle
# ----------------------------------------------
echo "buildscript {
    repositories {
        google()
        jcenter()
    }
    dependencies {
        classpath \"com.android.tools.build:gradle:4.1.0\"

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        google()
        jcenter()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}" >> build.gradle


# ----------------------------------------------
# app build.gradle
# ----------------------------------------------
if [ ! -d 'app' ]; then 
	mkdir 'app'
fi

if [ -d 'app' ]; then
echo "apply plugin: 'com.android.application'

android {
    compileSdkVersion 29
    buildToolsVersion \"29.0.3\"

    defaultConfig {
        applicationId \"${PROJECT_PACKAGE_NAME}\"
        minSdkVersion 16
        targetSdkVersion 29
        versionCode 1
        versionName \"1.0\"

        testInstrumentationRunner \"androidx.test.runner.AndroidJUnitRunner\"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.2.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.0.2'
}" > app/build.gradle
fi

# ----------------------------------------------
# MainActivity.java
# ----------------------------------------------
if [ ! -d "${PROJECT_APP_DIR}" ]; then 
	mkdir -p "${PROJECT_APP_DIR}"
fi

if [ -d "${PROJECT_APP_DIR}" ]; then 
echo "package ${PROJECT_PACKAGE_NAME};

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }
}" > "${PROJECT_APP_DIR}/MainActivity.java"
fi

# ----------------------------------------------
#  AndroidManifest.xml
# ----------------------------------------------
if [ ! -d "${PROJECT_MAIN_DIR}" ]; then 
	mkdir -p "${PROJECT_MAIN_DIR}"
fi

if [ -d "${PROJECT_MAIN_DIR}" ]; then 
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\"
    package=\"${PROJECT_PACKAGE_NAME}\">

    <application

        android:allowBackup=\"false\"
        android:label=\"@string/app_name\"
        android:theme=\"@style/AppTheme\">
	
        <activity android:name=\".MainActivity\">
            <intent-filter>
                <action android:name=\"android.intent.action.MAIN\" />

                <category android:name=\"android.intent.category.LAUNCHER\" />
            </intent-filter>
        </activity>
    </application>

</manifest>" > "${PROJECT_MAIN_DIR}/AndroidManifest.xml"
fi

# ----------------------------------------------
# copy res and contents
# ----------------------------------------------
cp -R ${WORKING_DIR}/res  ${PROJECT_MAIN_DIR}

# ----------------------------------------------
# strings.xml (must be done before the manifest)
# ----------------------------------------------
if [ -d "${PROJECT_VALUES_DIR}" ]; then 
echo "<resources>
    <string name=\"app_name\">${PROJECT_NAME}</string>
</resources>" > "${PROJECT_VALUES_DIR}/strings.xml" 
fi

# ----------------------------------------------
# add gradle wrapper
# ----------------------------------------------
gradle wrapper

# ----------------------------------------------
# assemble Debug
# ----------------------------------------------
gradlew assembleDebug


echo "---------------------------------------------------------"
echo "If success: debug app available in ${PROJECT_APK_DEBUG_DIR}"
echo "---------------------------------------------------------"
echo

exit 0
