function add_title --description "Renders title text onto an image"
    set -l input_img $argv[1]
    set -l title $argv[2]

    # Validate inputs
    if test (count $argv) -lt 2
        echo "Error: Missing arguments."
        echo "Usage: render_title <image_path> \"<title_text>\""
        return 1
    end

    if not test -f $input_img
        echo "Error: Image file '$input_img' not found."
        return 1
    end

    # Format the output filename (replaces spaces with underscores)
    # set -l clean_title (string replace --all " " "_" $title)
    set -l ext (path extension $input_img)
    set -l output_img "$title$ext"

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
