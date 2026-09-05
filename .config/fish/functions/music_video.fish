function music_video --description "Generates a video for YouTube / Instagram from an audio recording"
    argparse 't/title=' -- $argv

    set -l audio_file $argv[1]
    set -l title ""
    set -l audio_name (basename "$audio_file" | string replace -r '\.[^.]+$' '')

    if set -q _flag_title 
        set title $_flag_title
    else
        set title $audio_name
    end

    # Validate inputs
    if test (count $argv) -lt 1
        echo "Error: Missing argument."
        echo "Usage: music_video <audio_file>"
        return 1
    end

    set -l image_file "$HOME/Documents/Guitar/Characture.jpeg"
    set -l titled_image_file "$HOME/Documents/Guitar/Videos/$audio_name.jpeg"
    set -l output_video "$HOME/Documents/Guitar/Videos/$audio_name.mp4"

    add_title "$image_file" "$title" "$titled_image_file"

    audio2video "$audio_file" "$titled_image_file" "$output_video"

    echo "Generated $output_video"

end
