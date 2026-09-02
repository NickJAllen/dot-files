function audio2video --description "Convert an audio file with a single image into an MP4 video"
    if test (count $argv) -lt 3
        echo "Usage: audio2video <audio_file> <image_file> <output_file>"
        return 1
    end

    set audio $argv[1]
    set img $argv[2]
    set output $argv[3]

    ffmpeg -loop 1 -i "$img" -i "$audio" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "$output"
end
