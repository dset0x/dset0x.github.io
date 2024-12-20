2017-02-21T11:23 linux,viber,apulse,pulseaudio,ld_preload,volume
# Getting Viber for Linux to play nice with apulse

Viber for Linux seems to work fine with apulse,

    $ apulse /opt/viber/Viber


except for taking the liberty of changing my system's volume to 100% shortly
after starting.

After no luck with trying to figure out if it was leveraging apulse itself to
do this,

    $ apulse ltrace -f -e '@libpulse*' /opt/viber/Viber


I started believing it was calling alsa despite being a pulseaudio
application:

    $ apulse ltrace -f -e '@libasound*' /opt/viber/Viber


Unfortunately, this produces too much noise.

Looking at `/usr/include/alsa/mixer.h` it's easy to locate possibly used
functions:

    int snd_mixer_selem_set_playback_volume(...);
    int snd_mixer_selem_set_capture_volume(...);
    int snd_mixer_selem_set_playback_volume_all(...);
    int snd_mixer_selem_set_capture_volume_all(...);
    int snd_mixer_selem_set_playback_volume_range(...);


In fact `strings` hints that this may be the case:

    $ strings /opt/viber/Viber| grep 'volume'
    pa_cvolume_set
    pa_context_set_sink_input_volume
    pa_context_set_source_volume_by_index
    snd_mixer_selem_set_playback_volume_all
    snd_mixer_selem_get_playback_volume
    snd_mixer_selem_has_playback_volume
    snd_mixer_selem_get_playback_volume_range
    snd_mixer_selem_has_capture_volume
    snd_mixer_selem_set_capture_volume_all
    snd_mixer_selem_get_capture_volume
    snd_mixer_selem_get_capture_volume_range


Armed with possible function names, voila:

    $ apulse ltrace -f -e '*set*volume*@libasound*' /opt/viber/Viber
    [...]
    [pid 17824] libasound.so.2->snd_mixer_selem_set_playback_volume(0x7f1f7d0efbf0, 0, 110, 0) = 0
    [pid 17824] libasound.so.2->snd_mixer_selem_set_playback_volume(0x7f1f7d0efbf0, 1, 110, 1) = 0
    [...]


Looks like it sets it to 110% for good measure (and alsa happily obliges)!

Let's go ahead and take that function away from it via `LD_PRELOAD`:

    #include
    int snd_mixer_selem_set_playback_volume(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long value) {
    return 0;
    }

    $ gcc -shared -fPIC viber_unvol.c -o viber_unvol.so


And there you go, no more automatic volume changing:

    $ LD_PRELOAD=$LD_PRELOAD:$PWD/viber_unvol.so apulse /opt/viber/Viber
