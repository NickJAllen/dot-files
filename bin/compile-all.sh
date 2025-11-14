#!/bin/sh

./gradlew -Pminimal compileCpp compileJava
./gradlew -Pminimal -PdebugCpp compileCpp
