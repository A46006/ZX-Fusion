srec_cat "screen data manic miner dump.bin" -binary -output screenData.hex -Intel
srec_cat "color data manic miner dump.bin" -binary -output colorData.hex -Intel
srec_cat "color data manic miner dump FAKE FLASHING.bin" -binary -output colorDataWFakeFlash.hex -Intel