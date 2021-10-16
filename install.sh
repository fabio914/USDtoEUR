#!/bin/sh

swift build -c release
mv .build/release/usdToEur /usr/local/bin
