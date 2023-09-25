srec_cat "test-video.bin" -binary -output test-video.hex -Intel
srec_cat "test-contention.bin" -binary -output test-contention.hex -Intel
srec_cat "delay_routine.bin" -binary -output delay_routine.hex -Intel

srec_cat Spectrum48_ROM.bin -binary -output Spectrum48_ROM.hex -Intel
srec_cat Spectrum128_ROM0.bin -binary -output Spectrum128_ROM0.hex -Intel
srec_cat Spectrum128_ROM1.bin -binary -output Spectrum128_ROM1.hex -Intel

srec_cat Spectrum48_ROM_EDITED.bin -binary -output Spectrum48_ROM_EDITED.hex -Intel

srec_cat Spectrum48_ROM_TEST_MENU2.bin -binary -output Spectrum48_ROM_TEST_MENU2.hex -Intel

srec_cat test-io.bin -binary -output test-io.hex -Intel
