function add_title --description "Renders title text onto an image"
    set -l input_img $argv[1]
    set -l title $argv[2]
    set -l output_img $argv[3]

    # Validate inputs
    if test (count $argv) -lt 3
        echo "Error: Missing arguments."
        echo "Usage: render_title <image_path> \"<title_text>\" <output_img>"
        return 1
    end

    if not test -f $input_img
        echo "Error: Image file '$input_img' not found."
        return 1
    end

    # Render text onto image using ImageMagick
    magick $input_img \
        -gravity center \
        -font /System/Library/Fonts/Supplemental/Arial.ttf \
        -pointsize 100 \
        -fill white \
        -stroke black \
        -strokewidth 2 \
        -annotate +0+0 "$title" \
        "$output_img"

    if test $status -eq 0
        echo "Successfully created: $output_img"
    else
        echo "Error: ImageMagick failed to process the image."
        return 1
    end
end
