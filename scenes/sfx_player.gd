extends AudioStreamPlayer

var current_subsong := 0
var playback : AudioStreamPlaybackMPT
#var play_list : PackedByteArray = [0,1] # needs get_num_subsongs
#var tracker_text : String

var old_row := 0
var old_pattern := 0
var tracker_data_buff : PackedStringArray

@onready var tracker_display = $"../Background/Menu/TrackerDisplay"
@onready var tracker_display_data = $"../Background/Menu/TrackerDisplay2"
@onready var mpt_stream : AudioStreamMPT = stream


func _ready():
    tracker_data_buff.resize(16)


func play_song():
    play()
    # check the playback to make sure not null
    if has_stream_playback():
        print("has playback")
        playback = get_stream_playback()
        current_subsong = playback.get_selected_subsong()
        print("subsong: ", current_subsong)
    else: # oops
        print("No PLAYBACK AAAH!!!")

    update_song_display()


func next_subsong():
    if not has_stream_playback(): # could probably disable process until song plays...
        return

    current_subsong += 1

    # prevent something something... forgetting something... meh...
    if current_subsong >= mpt_stream.get_num_subsongs():
        current_subsong = 0
    playback.select_subsong(current_subsong)

    update_song_display()

    old_pattern = playback.get_current_pattern()
    old_row = playback.get_current_row()

func _process(delta):
    if not has_stream_playback():
        return # could probably disable ditto

    # keeping track of the song position for tracker data view
    var new_row = playback.get_current_row()
    var new_pat = playback.get_current_pattern()
    # keeping track of how the pattern and row values change, could probably modulo?
    if new_pat == old_pattern + 1:
        old_row = 0
    elif new_pat < old_pattern:
        old_pattern = 0
        old_row = 0
    elif old_row > new_row and new_pat == old_pattern: # single pattern loop happen?
        old_row = 0
    # TODO: Think about other ways the patterns and rows could change and how to catch
    # 🙄 ugh... could be better but brain is boobdingus


    if new_row == old_row + 1: # or maybe > old row, but what if pattern jump? hmm...
        # could be for i in however_many_channels_range but for now... \ city
        var data_line : String
        for i in range(0,mpt_stream.get_num_channels()):
            data_line += get_chan_info(i) + " | "

        # row goes in buffer
        tracker_data_buff.append(data_line)
        # remove first element if going to overflow
        if tracker_data_buff.size() > 16:
            tracker_data_buff.remove_at(0)
            tracker_display_data.text = ""

        # update the label text
        for i in tracker_data_buff:
            tracker_display_data.text += i +"\n"

        # get the row and pattern for position alignment
        old_row = playback.get_current_row()
        old_pattern = playback.get_current_pattern()

        #TODO: could show future data and put play position in middle


## returns a string with all of the current row's data given a channel
func get_chan_info(channel) -> String:
    var pat = playback.get_current_pattern()
    var row = playback.get_current_row()
    var chan = channel
    var width = 13
    var pad = true
    var result = mpt_stream.format_pattern_row_channel(pat,row,chan,width,pad)
    # highlight gives type strings rather than the human readable data
    #var result = mpt_stream.highlight_pattern_row_channel(pat,row,chan,width,pad)
    return result


func update_song_display():
    # number and name of subsong, updated in the label
    tracker_display.text = str(current_subsong) +": "+ \
    mpt_stream.get_subsong_names()[current_subsong]
