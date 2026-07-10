function audio2vid --description "Convert an audio file with a single image into an MP4 video"
    if test (count $argv) -lt 2
        echo "Usage: audio2vid <audio_file> <image_file>"
        return 1
    end

    set audio $argv[1]
    set img $argv[2]
    
    # Strip extension from the audio filename and append .mp4
    set output (string replace -r '\.[^.]+$' '.mp4' -- $audio)

    ffmpeg -loop 1 -i $img -i $audio -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest $output
end
